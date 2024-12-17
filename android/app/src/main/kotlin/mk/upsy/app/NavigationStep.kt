package mk.upsy.app

import com.google.android.gms.maps.model.LatLng

data class NavigationStep(
    val instructions: String,
    val distance: String,
    val duration: String,
    val startLocation: LatLng,
    val endLocation: LatLng,
    val polylinePoints: String // Encoded polyline for the step
)
