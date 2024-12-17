# Upsy.mk

Upsy.mk is a mobile application designed for users to create and search for rides between cities. The app provides a seamless way to connect riders and drivers, making travel more efficient and convenient.

---

## Features

- **Create Rides**: Easily create ride offers with all necessary details.
- **Search Rides**: Find available rides between your desired locations.
- **User-Friendly Interface**: Intuitive design for quick navigation.
- **Secure**: Built with Firebase for reliable and secure data storage.
- **Maps Integration**: View routes and navigate with integrated maps.
- **In-App Messaging**: Communicate directly with riders/drivers.
- **Ratings and Reviews**: Rate and review users to build trust.
- **Payment Integration**: Secure in-app payments with Stripe.

---

## Screenshots

| Screenshot 1 | Screenshot 2 |
|--------------|--------------|
| ![1](https://github.com/user-attachments/assets/ee39feb6-cc98-466a-8a99-cd67ffcd528d) | ![2](https://github.com/user-attachments/assets/a0516103-546d-4773-8c78-0944e0200dae) |
| Screenshot 3 | Screenshot 4 |
| ![3](https://github.com/user-attachments/assets/f8ced5e1-207e-40cb-b966-1e01acb241a9) | ![4](https://github.com/user-attachments/assets/5e7bc66b-a5ca-43af-a120-fa10955e579c) |
| Screenshot 5 | |
| ![5](https://github.com/user-attachments/assets/da707a0f-69f2-4393-8dc5-252547a9c2cd) | |


---


## Usage

1. **Register/Sign-In**: Log in using Google Sign-In or other available methods.
2. **Create Ride**: Add your ride details and post it to the platform.
3. **Search Rides**: Browse available rides and connect with the drivers.
4. **Book a Ride**: Request seats and confirm bookings.
5. **Communicate**: Use in-app messaging to coordinate with other users.
6. **Make Payments**: Complete transactions securely within the app.

---

## Technologies Used

- **Flutter**: Frontend framework for building the app.
- **Firebase**: Backend for authentication and database.
- **Dart**: Programming language for the app.
- **Google Maps SDK**: Map and navigation functionalities.
- **Stripe**: Payment processing.
- **OkHttp**: Networking library for API calls.

---

## Google Maps SDK Integration

### **Choice of Technology**

We integrated the **Google Maps SDK** into Upsy.mk to provide robust mapping and navigation features essential for a ride-sharing application.

### **Why Google Maps SDK?**

- **Comprehensive Features**: Offers a wide range of functionalities such as map rendering, geocoding, routing, and real-time location tracking.
- **Reliability**: Backed by Google's infrastructure, ensuring high availability and performance.
- **Developer Support**: Extensive documentation and active community support facilitate smoother development processes.

### **Advantages**

- **Ease of Integration**: Seamlessly integrates with Flutter, allowing for efficient development.
- **Customization**: Highly customizable maps with various styling options to match the app's branding.
- **Rich Data**: Access to detailed geographical data, including places, landmarks, and traffic information.
- **Real-Time Updates**: Supports real-time location tracking and dynamic route updates.

### **Disadvantages**

- **Cost**: While it offers a free tier, extensive usage can incur significant costs based on API calls.
- **Dependency**: Reliance on Google services means potential limitations if Google changes its API policies or pricing.
- **Complexity**: Advanced features may require a steep learning curve and additional development time.

### **License**

The Google Maps SDK is governed by the [Google Maps Platform Terms of Service](https://cloud.google.com/maps-platform/terms/). It is free for low-usage applications, but charges apply based on the volume of API requests. We have to ensure compliance with their licensing requirements when deploying the app.

### **Number of Users**

As of 2024, Google Maps SDK serves millions of developers and applications worldwide, making it a trusted choice for location-based services.

### **Project Maintenance**

- **Developers**: Maintained by a dedicated team of developers within our project.
- **Last Update**: Integrated and updated in [Month, Year]. Regular updates are performed to keep the SDK and its integrations current with the latest features and security patches.
- **Community Support**: Active community forums and official support channels are available for troubleshooting and feature requests.

### **Implementation Details**

- **Route Visualization**: Displaying routes between departure and arrival cities using polylines.
- **Marker Placement**: Adding markers for departure and arrival points to enhance user experience.
- **Navigation Launch**: Enabling users to launch Google Maps for detailed navigation from specified points.

---

## License

### Upsy.mk Mobile Application License

#### Copyright © 2024 Gjoko Tashev. All Rights Reserved.

This license governs the use of the Upsy.mk mobile application (the “Application”) created and owned by Gjoko Tashev (“Author”). By using this Application, you agree to the terms and conditions outlined in this license.

---

### 1. Ownership
The Application, including but not limited to its source code, design, features, branding, and associated intellectual property, is the sole property of Gjoko Tashev. All rights are reserved.

---

### 2. License Grant
You are granted a personal, non-transferable, non-exclusive license to use the Application for its intended purpose, which includes searching for or creating rides. This license does not transfer ownership, nor does it grant you permission to modify, distribute, or create derivative works based on the Application.

---

### 3. Restrictions
You agree not to:
1. Edit, alter, or modify any part of the Application or its source code.
2. Claim ownership of the Application or any of its components.
3. Copy, distribute, sublicense, or sell any part of the Application without prior written consent from Gjoko Tashev.
4. Decompile, reverse engineer, or otherwise attempt to derive the source code of the Application.

---

### 4. Disclaimer of Warranty
The Application is provided "as is," without warranties of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement. The Author does not guarantee uninterrupted or error-free functionality of the Application.

---

### 5. Limitation of Liability
Under no circumstances shall Gjoko Tashev be held liable for any damages arising from the use or inability to use the Application, including but not limited to data loss, indirect or consequential damages, or personal injury.

---

### 6. Termination
This license is effective until terminated. Your rights under this license will terminate automatically without notice if you fail to comply with any term herein. Upon termination, you must stop using the Application and destroy all copies in your possession.

---

### 7. Governing Law
This license is governed by the laws of North Macedonia. Any disputes shall be resolved in the courts of Kavadarci, and the parties consent to the jurisdiction of such courts.

---

### 8. Changes to the License
The Author reserves the right to update or modify this license at any time. Continued use of the Application indicates acceptance of the revised license terms.

---

## Contact

If you have any questions or feedback, feel free to contact me:

**Gjoko Tashev**  
**Email:** djoketashev1@gmail.com  
**Location:** Kavadarci, North Macedonia

