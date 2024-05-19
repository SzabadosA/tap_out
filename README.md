## TapOut SOS App

### Overview
TapOut SOS is a mobile application designed to help users quickly send an emergency message along with their real-time 
location to pre-defined contacts by detecting specific patterns of microphone input (taps). This app operates both 
in the foreground and background, ensuring continuous monitoring and quick response in case of emergencies.

### Features
- **Pattern Detection**: Uses microphone input to detect a specific pattern (four taps) to trigger an emergency alert.
- **Emergency Messaging**: Automatically sends an emergency message with the user's location to predefined contacts.
- **Background Service**: Runs as a foreground service to ensure continuous monitoring even when the app is not active.
- **Location Tracking**: Sends the user's real-time location to the server, which can be tracked through a web interface.
- **Permission Handling**: Requests necessary permissions for microphone, geolocation, and SMS.
- **Settings**: Allows users to customize emergency message and manage contacts.

### Prerequisites
- Flutter SDK
- Dart
- Node.js

### Setup and Installation

#### Mobile App
Install the apk in
build/app/outputs/apk/release/app-release.apk
### File Structure

#### Flutter App
```
pubspec.yaml
android/
├── build.gradle
android/app/
├── build.gradle
lib/
├── contacts.dart
├── custom_button.dart
├── custom_scaffold.dart
├── emergency_message.dart
├── foreground_service.dart
├── help_page.dart
├── main.dart
├── pattern_recognition.dart
├── settings_page.dart

```


### File Descriptions

#### `main.dart`
The entry point of the Flutter app. Initializes the app, sets up the theme, and manages the main UI and state.

#### `contacts.dart`
Manages the user's emergency contacts. Allows adding, removing, and saving contacts using SharedPreferences.

#### `custom_button.dart`
Defines a styled button widget used throughout the app.

#### `custom_scaffold.dart`
Defines a custom scaffold widget with a gradient background.

#### `emergency_message.dart`
Allows users to set and save a custom emergency message.

#### `foreground_service.dart`
Handles the foreground service, which sends location updates to the server periodically.

#### `help_page.dart`
A placeholder for the help page, where users can find more information about using the app.

#### `pattern_recognition.dart`
Handles microphone input to detect the specific pattern (four taps) that triggers the emergency alert.

#### `settings_page.dart`
Allows users to access and modify settings, such as contacts and emergency message.

#### `server/index.html`
The web interface for tracking the user's location in real-time.

#### `server/server.js`
The server-side code that handles incoming location data, manages WebSocket connections, and serves the web interface.

### How It Works

#### Mobile App Workflow
1. **Pattern Detection**:
    - The app listens for a 4 tap pattern using the microphone.
    - If the pattern is detected, it triggers an emergency alert.

2. **Emergency Alert**:
    - Sends an SMS with a predefined message and the user's current location to all predefined contacts.

3. **Location Tracking**:
    - Continuously sends location updates to the server.
    - The location can be tracked via a web interface.

4. **Foreground Service**:
    - Runs in the background to ensure continuous monitoring even when the app is not in the foreground.

#### Server Workflow
1. **Start Session**:
    - When an emergency is triggered, the app starts a session by notifying the server.

2. **Update Location**:
    - The app sends periodic location updates to the server.
    - The server broadcasts these updates to any connected WebSocket clients.

3. **End Session**:
    - When the emergency is resolved, the app ends the session by notifying the server.
    - The server stops broadcasting location updates for that session.



### Additional Notes
- Ensure all necessary permissions are granted for the app to function correctly.
- The server requires valid SSL certificates for HTTPS communication.
- The pattern detection algorithm may need adjustments based on the environment and specific use case.

---
