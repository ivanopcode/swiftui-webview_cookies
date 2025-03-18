import SwiftUI

@main
struct webview_cookies: App {
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
