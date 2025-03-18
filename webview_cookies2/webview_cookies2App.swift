import SwiftUI

@main
struct webview_cookies2App: App {
    var body: some Scene {
        WindowGroup {
            Text("")
                .sheet(isPresented: .constant(true)) {
                    ContentView(session: exampleSession)
                }
            
        }
    }
}


let exampleSession = SessionObject(
    url: "https://delivery.publix.com/store/publix/storefront",
    cookies: [
        "session": [
            "__Host-instacart_sid": "v2.3a7067839f8f7c.Nopp5TBdQxwtYbDw503DDYHLQLviB5dWKyBhi26sMsQ"
        ]
    ],
    localStorage: [:]
)
