struct SessionObject {
    let url: String
    let cookies: [String: [String: String]]  // e.g. ["session": ["__Host-instacart_sid": "<value>"]]
    let localStorage: [String: String]
}
