// android/app/src/main/kotlin/mk/upsy/app/MapActivity.kt
package mk.upsy.app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.Spinner
import android.widget.AdapterView
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.*
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.io.IOException
import android.graphics.Color
import android.os.Handler
import android.os.Looper

// Ensure this import is present
import mk.upsy.app.R

class MapActivity : AppCompatActivity(), OnMapReadyCallback {

    private lateinit var mMap: GoogleMap
    private var departureLatLng: LatLng? = null
    private var arrivalLatLng: LatLng? = null
    private lateinit var startDirectionButton: Button
    private lateinit var animateMarkerButton: Button
    private lateinit var transportModeSpinner: Spinner
    private lateinit var recyclerView: RecyclerView
    private var navigationSteps: List<NavigationStep> = listOf()
    private var highlightedPolyline: Polyline? = null
    private var fullRoutePolyline: String = ""
    private var selectedTransportMode: String = "d" // Default to driving

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_map)

        // Initialize UI elements
        startDirectionButton = findViewById(R.id.button_start_direction)
        animateMarkerButton = findViewById(R.id.button_animate_marker)
        transportModeSpinner = findViewById(R.id.spinner_transport_mode)
        recyclerView = findViewById(R.id.recycler_view_directions)

        // Disable buttons initially
        startDirectionButton.isEnabled = false
        animateMarkerButton.isEnabled = false

        // Set up Transportation Mode Spinner
        transportModeSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(
                parent: AdapterView<*>, view: View, position: Int, id: Long
            ) {
                selectedTransportMode = when (position) {
                    0 -> "d" // Driving
                    1 -> "w" // Walking
                    2 -> "b" // Bicycling
                    else -> "d" // Default to driving
                }
                Log.d("MapActivity", "Selected transportation mode: $selectedTransportMode")
            }

            override fun onNothingSelected(parent: AdapterView<*>) {
                // Default to driving if nothing is selected
                selectedTransportMode = "d"
            }
        }

        // Set up Start Direction Button
        startDirectionButton.setOnClickListener {
            if (departureLatLng != null && arrivalLatLng != null) {
                launchGoogleMapsNavigation(departureLatLng!!, arrivalLatLng!!)
            } else {
                Toast.makeText(this, "Departure or arrival location not available.", Toast.LENGTH_SHORT).show()
            }
        }

        // Set up Animate Marker Button
        animateMarkerButton.setOnClickListener {
            animateMarkerAlongRoute()
        }

        // Get data from Intent
        val departure = intent.getStringExtra("departureCity") ?: ""
        val arrival = intent.getStringExtra("arrivalCity") ?: ""

        // Initialize the map
        val mapFragment = supportFragmentManager
            .findFragmentById(R.id.map) as SupportMapFragment
        mapFragment.getMapAsync(this)

        // Convert cities to coordinates using Geocoding API
        getCoordinates(departure) { departureLat ->
            departureLatLng = departureLat
            runOnUiThread {
                if (departureLatLng != null && ::mMap.isInitialized) {
                    mMap.addMarker(MarkerOptions().position(departureLatLng!!).title("Departure: $departure"))
                    mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(departureLatLng!!, 10f))
                    Log.d("MapActivity", "Departure marker added at: $departureLatLng")
                    maybeDrawRoute()
                } else {
                    Log.e("MapActivity", "Failed to add departure marker.")
                    Toast.makeText(this, "Failed to locate departure city.", Toast.LENGTH_SHORT).show()
                }
            }
        }

        getCoordinates(arrival) { arrivalLat ->
            arrivalLatLng = arrivalLat
            runOnUiThread {
                if (arrivalLatLng != null && ::mMap.isInitialized) {
                    mMap.addMarker(MarkerOptions().position(arrivalLatLng!!).title("Arrival: $arrival"))
                    // Optionally, move camera to include both markers
                    departureLatLng?.let { dep ->
                        arrivalLatLng?.let { arr ->
                            val bounds = LatLngBounds.Builder()
                                .include(dep)
                                .include(arr)
                                .build()
                            mMap.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, 100))
                            Log.d("MapActivity", "Camera moved to include both markers.")
                        }
                    }
                    Log.d("MapActivity", "Arrival marker added at: $arrivalLatLng")
                    maybeDrawRoute()
                } else {
                    Log.e("MapActivity", "Failed to add arrival marker.")
                    Toast.makeText(this, "Failed to locate arrival city.", Toast.LENGTH_SHORT).show()
                }
            }
        }

        // Set up RecyclerView LayoutManager
        recyclerView.layoutManager = LinearLayoutManager(this)
    }

    override fun onMapReady(googleMap: GoogleMap) {
        mMap = googleMap

        Log.d("MapActivity", "Map is ready.")
        // Add markers if already available
        departureLatLng?.let {
            mMap.addMarker(MarkerOptions().position(it).title("Departure"))
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(it, 10f))
            Log.d("MapActivity", "Departure marker added in onMapReady at: $it")
        }

        arrivalLatLng?.let {
            mMap.addMarker(MarkerOptions().position(it).title("Arrival"))
            Log.d("MapActivity", "Arrival marker added in onMapReady at: $it")
        }

        // Attempt to draw route if both coordinates are available
        maybeDrawRoute()
    }

    /**
     * Checks if both the map is ready and both coordinates are available.
     * If so, it draws the route between them and enables the Start Direction button.
     */
    private fun maybeDrawRoute() {
        if (::mMap.isInitialized && departureLatLng != null && arrivalLatLng != null) {
            Log.d("MapActivity", "Both coordinates are available. Drawing route.")
            drawRoute(departureLatLng!!, arrivalLatLng!!)
            startDirectionButton.isEnabled = true // Enable the button now
            animateMarkerButton.isEnabled = true // Enable the animate button
        } else {
            Log.d(
                "MapActivity",
                "Cannot draw route yet. Map ready: ${::mMap.isInitialized}, DepartureLatLng: ${departureLatLng != null}, ArrivalLatLng: ${arrivalLatLng != null}"
            )
        }
    }

    private fun drawRoute(start: LatLng, end: LatLng) {
        Log.d("MapActivity", "Fetching directions from $start to $end")
        // Fetch route from Google Directions API
        val apiKey = getString(R.string.google_maps_key)
        val url =
            "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey"

        val client = OkHttpClient()

        val request = Request.Builder()
            .url(url)
            .build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: IOException) {
                e.printStackTrace()
                Log.e("MapActivity", "Directions API call failed: ${e.message}")
                runOnUiThread {
                    Toast.makeText(this@MapActivity, "Failed to fetch directions.", Toast.LENGTH_SHORT).show()
                }
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (!response.isSuccessful) {
                    Log.e("MapActivity", "Unexpected response code: ${response.code}")
                    runOnUiThread {
                        Toast.makeText(this@MapActivity, "Failed to fetch directions.", Toast.LENGTH_SHORT).show()
                    }
                    return
                }

                val responseData = response.body?.string()
                Log.d("MapActivity", "Directions API Response: $responseData")

                if (responseData != null) {
                    val json = JSONObject(responseData)
                    val status = json.getString("status")
                    Log.d("MapActivity", "Directions API Status: $status")

                    if (status == "OK") {
                        val routes = json.getJSONArray("routes")
                        if (routes.length() > 0) {
                            val route = routes.getJSONObject(0)
                            val overviewPolyline = route.getJSONObject("overview_polyline").getString("points")
                            fullRoutePolyline = overviewPolyline // Store the full route polyline
                            val polylineOptions = PolylineOptions()
                                .addAll(decodePolyline(overviewPolyline))
                                .color(Color.parseColor("#6200EE")) // Customize as needed
                                .width(10f)
                            runOnUiThread {
                                mMap.addPolyline(polylineOptions)
                                Log.d("MapActivity", "Route polyline added to the map.")
                                Toast.makeText(this@MapActivity, "Route loaded.", Toast.LENGTH_SHORT).show()
                            }

                            // Extract navigation steps
                            val legs = route.getJSONArray("legs")
                            if (legs.length() > 0) {
                                val leg = legs.getJSONObject(0)
                                val steps = leg.getJSONArray("steps")
                                val stepsList = mutableListOf<NavigationStep>()

                                for (i in 0 until steps.length()) {
                                    val step = steps.getJSONObject(i)
                                    val instructions = step.getString("html_instructions")
                                    val distance = step.getJSONObject("distance").getString("text")
                                    val duration = step.getJSONObject("duration").getString("text")
                                    val startLocation = step.getJSONObject("start_location")
                                    val endLocation = step.getJSONObject("end_location")
                                    val polyline = step.getJSONObject("polyline").getString("points")
                                    stepsList.add(
                                        NavigationStep(
                                            instructions = android.text.Html.fromHtml(
                                                instructions,
                                                android.text.Html.FROM_HTML_MODE_LEGACY
                                            ).toString(),
                                            distance = distance,
                                            duration = duration,
                                            startLocation = LatLng(
                                                startLocation.getDouble("lat"),
                                                startLocation.getDouble("lng")
                                            ),
                                            endLocation = LatLng(
                                                endLocation.getDouble("lat"),
                                                endLocation.getDouble("lng")
                                            ),
                                            polylinePoints = polyline
                                        )
                                    )
                                }

                                navigationSteps = stepsList
                                runOnUiThread {
                                    setupRecyclerView()
                                }
                            }
                        } else {
                            Log.e("MapActivity", "No routes found in the Directions API response.")
                            runOnUiThread {
                                Toast.makeText(this@MapActivity, "No routes found.", Toast.LENGTH_SHORT).show()
                            }
                        }
                    } else {
                        Log.e("MapActivity", "Directions API returned status: $status")
                        runOnUiThread {
                            Toast.makeText(this@MapActivity, "Failed to fetch directions: $status", Toast.LENGTH_SHORT).show()
                        }
                    }
                }
            }
        })
    }

    /**
     * Sets up the RecyclerView with navigation steps.
     */
    private fun setupRecyclerView() {
        val adapter = NavigationStepsAdapter(navigationSteps) { step ->
            // Handle step click: Highlight on map
            highlightStepOnMap(step)
        }
        recyclerView.adapter = adapter
        recyclerView.visibility = View.VISIBLE
    }

    /**
     * Highlights a selected navigation step on the map.
     */
    private fun highlightStepOnMap(step: NavigationStep) {
        // Remove existing highlighted polyline if any
        highlightedPolyline?.remove()

        // Decode the polyline for the selected step
        val points = decodePolyline(step.polylinePoints)

        // Create a new polyline with a different color to highlight
        val polylineOptions = PolylineOptions()
            .addAll(points)
            .color(Color.RED) // Highlight color
            .width(12f)
        highlightedPolyline = mMap.addPolyline(polylineOptions)

        // Move the camera to the start of the step
        mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(step.startLocation, 15f))
        Log.d("MapActivity", "Highlighted step on the map.")
    }

    /**
     * Launches Google Maps with navigation from departure to arrival city based on selected transportation mode.
     */
    private fun launchGoogleMapsNavigation(start: LatLng, end: LatLng) {
        val uri = Uri.parse("https://www.google.com/maps/dir/?api=1" +
                "&origin=${start.latitude},${start.longitude}" +
                "&destination=${end.latitude},${end.longitude}" +
                "&travelmode=${getTravelModeString(selectedTransportMode)}")

        val mapIntent = Intent(Intent.ACTION_VIEW, uri)
        mapIntent.setPackage("com.google.android.apps.maps") // Ensure it opens in Google Maps

        try {
            startActivity(mapIntent)
            Log.d("MapActivity", "Launched Google Maps for navigation from departure to arrival.")
        } catch (e: ActivityNotFoundException) {
            Log.e("MapActivity", "Google Maps app not found. Redirecting to Play Store.")
            // Prompt user to install Google Maps
            AlertDialog.Builder(this)
                .setTitle("Google Maps Not Found")
                .setMessage("Google Maps is not installed on this device. Would you like to install it from the Play Store?")
                .setPositiveButton("Yes") { dialog, which ->
                    val playStoreUri = Uri.parse("market://details?id=com.google.android.apps.maps")
                    val playStoreIntent = Intent(Intent.ACTION_VIEW, playStoreUri)
                    try {
                        startActivity(playStoreIntent)
                    } catch (ex: ActivityNotFoundException) {
                        // If Play Store is not available, open in browser
                        val browserUri = Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.apps.maps")
                        val browserIntent = Intent(Intent.ACTION_VIEW, browserUri)
                        startActivity(browserIntent)
                    }
                }
                .setNegativeButton("No", null)
                .show()
        }
    }

    /**
     * Converts the selected transportation mode from single letter to full string.
     */
    private fun getTravelModeString(mode: String): String {
        return when (mode) {
            "d" -> "driving"
            "w" -> "walking"
            "b" -> "bicycling"
            else -> "driving" // Default to driving
        }
    }

    /**
     * Animates a marker along the full route.
     */
    private lateinit var animatedMarker: Marker

    private fun animateMarkerAlongRoute() {
        if (fullRoutePolyline.isEmpty()) {
            Toast.makeText(this, "Route not loaded yet.", Toast.LENGTH_SHORT).show()
            return
        }

        // Decode the full route polyline
        val routePoints = decodePolyline(fullRoutePolyline)

        // Initialize the marker at the start of the route
        animatedMarker = mMap.addMarker(
            MarkerOptions()
                .position(routePoints.first())
                .title("You are here")
                .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE))
        )!!

        // Handler for animation
        val handler = Handler(Looper.getMainLooper())
        var index = 0
        val delay: Long = 100 // milliseconds between updates

        val runnable = object : Runnable {
            override fun run() {
                if (index < routePoints.size) {
                    animatedMarker.position = routePoints[index]
                    mMap.animateCamera(CameraUpdateFactory.newLatLng(animatedMarker.position))
                    index++
                    handler.postDelayed(this, delay)
                } else {
                    handler.removeCallbacks(this)
                }
            }
        }
        handler.post(runnable)
        Log.d("MapActivity", "Started animating marker along the route.")
    }

    /**
     * Decodes an encoded polyline string into a list of LatLng points.
     */
    private fun decodePolyline(encoded: String): List<LatLng> {
        val poly = ArrayList<LatLng>()
        var index = 0
        val len = encoded.length
        var lat = 0
        var lng = 0

        while (index < len) {
            var b: Int
            var shift = 0
            var result = 0
            do {
                b = encoded[index++].toInt() - 63
                result = result or (b and 0x1f shl shift)
                shift += 5
            } while (b >= 0x20)
            val dlat = if ((result and 1) != 0) (result shr 1).inv() else (result shr 1)
            lat += dlat

            shift = 0
            result = 0
            do {
                b = encoded[index++].toInt() - 63
                result = result or (b and 0x1f shl shift)
                shift += 5
            } while (b >= 0x20)
            val dlng = if ((result and 1) != 0) (result shr 1).inv() else (result shr 1)
            lng += dlng

            val p = LatLng(
                lat / 1E5,
                lng / 1E5
            )
            poly.add(p)
        }

        return poly
    }

    private fun getCoordinates(cityName: String, callback: (LatLng?) -> Unit) {
        Log.d("MapActivity", "Fetching coordinates for city: $cityName")
        val apiKey = getString(R.string.google_maps_key)
        val url = "https://maps.googleapis.com/maps/api/geocode/json?address=${cityName}&key=$apiKey"

        val client = OkHttpClient()
        val request = Request.Builder()
            .url(url)
            .build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: IOException) {
                e.printStackTrace()
                Log.e("MapActivity", "Geocoding API call failed for $cityName: ${e.message}")
                runOnUiThread {
                    Toast.makeText(this@MapActivity, "Failed to locate $cityName.", Toast.LENGTH_SHORT).show()
                }
                callback(null)
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (!response.isSuccessful) {
                    Log.e("MapActivity", "Unexpected response code: ${response.code} for Geocoding API")
                    runOnUiThread {
                        Toast.makeText(this@MapActivity, "Failed to locate $cityName.", Toast.LENGTH_SHORT).show()
                    }
                    callback(null)
                    return
                }

                val responseData = response.body?.string()
                Log.d("MapActivity", "Geocoding API Response for $cityName: $responseData")

                if (responseData != null) {
                    val json = JSONObject(responseData)
                    val status = json.getString("status")
                    Log.d("MapActivity", "Geocoding API Status for $cityName: $status")

                    if (status == "OK") {
                        val results = json.getJSONArray("results")
                        if (results.length() > 0) {
                            val location = results.getJSONObject(0)
                                .getJSONObject("geometry")
                                .getJSONObject("location")
                            val lat = location.getDouble("lat")
                            val lng = location.getDouble("lng")
                            Log.d("MapActivity", "Coordinates for $cityName: ($lat, $lng)")
                            callback(LatLng(lat, lng))
                        } else {
                            Log.e("MapActivity", "No results found for $cityName in Geocoding API.")
                            runOnUiThread {
                                Toast.makeText(this@MapActivity, "No location found for $cityName.", Toast.LENGTH_SHORT).show()
                            }
                            callback(null)
                        }
                    } else {
                        Log.e("MapActivity", "Geocoding API returned status: $status for $cityName")
                        runOnUiThread {
                            Toast.makeText(this@MapActivity, "Failed to locate $cityName: $status", Toast.LENGTH_SHORT).show()
                        }
                        callback(null)
                    }
                }
            }
        })
    }
}
