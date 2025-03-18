# WebViewContainer for SwiftUI

A SwiftUI component that wraps a `WKWebView` to display a webpage with session management, including setting cookies and injecting localStorage for session restoration.

## Features
- Loads a specified URL in a `WKWebView`.
- Sets cookies before loading the page to maintain session state.
- Injects localStorage items after the page loads to restore client-side data.
- Manages loading state for user feedback.

## Usage
Integrate `WebViewContainer` into your SwiftUI view with a `WebViewModel` and a loading state binding.

```swift
struct ContentView: View {
    @StateObject var viewModel = WebViewModel(sessionObject: yourSessionObject)
    @State var isLoading = false

    var body: some View {
        WebViewContainer(viewModel: viewModel, isLoading: $isLoading)
    }
}
```

### WebViewModel and SessionObject
- **`WebViewModel`**: Manages the `WKWebView` instance and holds the `SessionObject`.
- **`SessionObject`**: Defines the URL, cookies, and localStorage items.

Example `SessionObject`:

```swift
let exampleSession = SessionObject(
    url: "https://shop.example.com/",
    cookies: [
        "session": [
            "session_id": "abc123",
            "csrf_token": "def456"
        ],
        "analytics": [
            "tracking_id": "ghi789"
        ]
    ],
    localStorage: [
        "cart": "{\"items\": [{\"id\": 1, \"name\": \"Apple\", \"quantity\": 2}]}",
        "user_preferences": "{\"theme\": \"dark\", \"language\": \"en\"}"
    ]
)
```

## Notes
- Cookies are set with a domain from the URL and marked as secure.
- LocalStorage is injected after the page loads and the document is ready.
- Includes no error handling; consider enhancements for production.

## Requirements
- iOS 14.0+
- SwiftUI
- WebKit
