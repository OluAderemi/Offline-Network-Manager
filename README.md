
# Offline-Aware Network Manager

A Flutter package that automatically manages network requests when the device is offline. This package detects network status, queues requests, and retries them when the device is back online, ensuring a seamless user experience even without internet connectivity.

---

## Features

* **Network Status Detection**: Detects whether the device is online or offline using `connectivity_plus`.
* **Offline Request Queueing**: Automatically queues HTTP requests when the device is offline using `Hive` for persistent storage.
* **Automatic Retry**: When the device reconnects, the queued requests are automatically retried.
* **Customizable**: Easily extendable and customizable for different types of requests (e.g., POST, PUT).
* **User-Friendly**: Optionally notify the user when they are offline and when a request is being retried.

---

## Getting Started

### Prerequisites

* Flutter SDK (2.x or later)
* Hive for local storage (installed automatically via the package)
* Internet access for network requests

### Installation

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  connectivity_plus: ^5.0.2
  http: ^0.14.0
  hive: ^2.2.3
  path_provider: ^2.1.2
```

Run:

```bash
flutter pub get
```

---

## Usage

To use this package in your Flutter app, follow these steps:

1. **Initialize the Offline Network Manager** in your main app file:

   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await OfflineNetworkManager().init();
     runApp(MyApp());
   }
   ```

2. **Make network requests** as you normally would:

   ```dart
   // POST request example:
   await OfflineNetworkManager().post("https://example.com/api", body: {"key": "value"});
   ```

3. The package will handle offline detection, queuing the request if offline, and retrying once the connection is restored.

---

## Example

To see the package in action, check the `/example` folder, which demonstrates how to use the `OfflineNetworkManager` in a sample Flutter app. It includes both network error handling and automatic request retries.

```dart
import 'package:offline_network_manager/offline_network_manager.dart';

// Inside a button press or network action:
await OfflineNetworkManager().post("https://example.com/api", body: {"key": "value"});
```

---

## Additional Information

* **Contributing**: Contributions are welcome! Feel free to fork this repository and submit pull requests.
* **Bug Reports**: If you encounter any issues, please file an issue on the [GitHub repo](https://github.com/OluAderemi/Offline-Network-Manager/issues).
* **License**: This package is open-source and available under the MIT license.

---

### **Where to Find More Information**

* [Flutter](https://flutter.dev)
* [Dart](https://dart.dev)
* [Hive](https://pub.dev/packages/hive)
* [Connectivity Plus](https://pub.dev/packages/connectivity_plus)

---
