# ShakeLog

**ShakeLog** is a lightweight, modular logging library for iOS that allows you to view your app's logs directly on the device by simply shaking it. It supports multiple logging destinations (Console, File, Memory) and provides a built-in UI for filtering and searching logs.

## Features

-   📱 **Shake to View**: Access logs instantly by shaking your device.
-   📂 **File Logging**: Automatically saves logs to disk with rotation support.
-   🔍 **Search & Filter**: Built-in UI to filter by log level or search text.
-   📤 **Export**: Easily share or export logs for debugging.
-   ⚡️ **Performance**: Optimized file I/O and thread-safe operations.
-   🎨 **SwiftUI & UIKit**: Supports both UI frameworks.

## Requirements

-   iOS 13.0+
-   Swift 5.5+

## Installation

### Swift Package Manager

1.  Open your project in Xcode.
2.  Go to **File > Add Package Dependencies...**
3.  Enter the repository URL: `https://github.com/Furkanvural10/ShakeLog.git`
4.  Select `ShakeLog` and add it to your target.

## Usage

### 1. Configuration (Optional)

You can configure `ShakeLog` in your `AppDelegate` or `SceneDelegate`. This is optional; by default, it logs everything to the console and memory.

```swift
import ShakeLog

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    var config = ShakeLog.Config()
    
    // Set the minimum log level (default: .verbose)
    // Options: .verbose, .debug, .info, .warning, .error, .critical
    config.minimumLogLevel = .info 
    
    // Set presentation mode (default: .uiKit)
    config.presentationMode = .uiKit 
    
    ShakeLog.configure(config)
    
    return true
}
```

### 2. Logging

Use the static methods on `ShakeLog` to log messages at different levels.

```swift
import ShakeLog

// Standard logs
ShakeLog.verbose("Detailed flow trace")
ShakeLog.debug("Debugging value: \(value)")
ShakeLog.info("User tapped button")
ShakeLog.warning("Resource usage high")
ShakeLog.error("Network request failed")
ShakeLog.critical("Database corruption detected")

// Log objects (Encodable)
let user = User(id: 1, name: "John")
ShakeLog.debug(user, title: "User Info")

// Network Logging helpers
ShakeLog.logRequest(urlRequest)
ShakeLog.logResponse(response, data: data, error: error)
```

### 3. Viewing Logs

Just **shake your device**! 
The log viewer will automatically appear, allowing you to:
-   Scroll through history.
-   Filter by log level (e.g., show only Errors).
-   Search for specific keywords.
-   Clear or Export logs.

## Architecture

-   **Logger**: Singleton that manages log dispatching.
-   **LogDestination**: Protocol for defining where logs go.
    -   `ConsoleLogDestination`: Prints to Xcode console / OSLog.
    -   `FileLogDestination`: Writes to a file in the Documents directory.
    -   `MemoryLogDestination`: Stores recent logs in RAM for the in-app viewer.

## License

This project is available under the MIT License.
