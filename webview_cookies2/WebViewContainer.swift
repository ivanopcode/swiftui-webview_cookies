import SwiftUI
import WebKit

struct WebViewContainer: UIViewRepresentable {
    
    @ObservedObject var viewModel: WebViewModel
    @Binding var isLoading: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        // Keep a weak reference in the view model so we can call goBack, goForward, reload
        viewModel.webView = webView
        
        // Set cookies BEFORE loading the page
        let dataStore = webView.configuration.websiteDataStore
        
        // Insert any cookies found in sessionObject.cookies
        // E.g., cookies["session"] = ["__Host-instacart_sid": "..."]
        let groupOfCookieDicts = viewModel.sessionObject.cookies
        
        // We only load the page AFTER all relevant cookies are set
        let cookiesToSet = groupOfCookieDicts.flatMap { $0.value }  // -> [(String, String)]
        
        isLoading = true
        setCookies(cookiesToSet, in: dataStore) {
            // Once cookies are set, load the URL
            if let url = URL(string: viewModel.sessionObject.url) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    // MARK: - Cookie Insertion Helper
    
    private func setCookies(
        _ cookies: [(key: String, value: String)],
        in dataStore: WKWebsiteDataStore,
        completion: @escaping () -> Void
    ) {
        let dispatchGroup = DispatchGroup()
        
        for (cookieName, cookieValue) in cookies {
            guard let domain = domainFromUrl(viewModel.sessionObject.url) else { continue }
            
            if let cookie = HTTPCookie(properties: [
                .domain: domain,
                .path: "/",
                .name: cookieName,
                .value: cookieValue,
                .secure: "TRUE",
                .expires: Date(timeIntervalSinceNow: 31536000) // 1 year
            ]) {
                dispatchGroup.enter()
                dataStore.httpCookieStore.setCookie(cookie) {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    // A helper to get the domain from a URL string.
    // For "https://delivery.publix.com/store/publix/storefront" => "delivery.publix.com"
    private func domainFromUrl(_ urlString: String) -> String? {
        guard let host = URL(string: urlString)?.host else { return nil }
        return host
    }
    
    // Escape strings for JavaScript
    private func escapeJavaScriptString(_ string: String) -> String {
        // avoid double escaping
        var escaped = string.replacingOccurrences(of: "\\", with: "\\\\")
        
        // quotes
        escaped = escaped.replacingOccurrences(of: "'", with: "\\'")
        escaped = escaped.replacingOccurrences(of: "\"", with: "\\\"")
        
        //line breaks and other control characters
        escaped = escaped.replacingOccurrences(of: "\n", with: "\\n")
        escaped = escaped.replacingOccurrences(of: "\r", with: "\\r")
        escaped = escaped.replacingOccurrences(of: "\t", with: "\\t")
        escaped = escaped.replacingOccurrences(of: "\u{000C}", with: "\\f") // Form feed
        escaped = escaped.replacingOccurrences(of: "\u{0008}", with: "\\b") // Backspace
        
        return escaped
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewContainer
        
        init(_ parent: WebViewContainer) {
            self.parent = parent
        }
        
        // Called when navigation starts
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        // Called when a navigation finishes, good place to inject local storage
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            
            // Only inject if needed
            guard !parent.viewModel.sessionObject.localStorage.isEmpty else { return }
            
            // Wait for document to be fully ready before injecting
            let readyCheckScript = """
    (function() {
        if (document.readyState === 'complete') {
            return true;
        } else {
            return false;
        }
    })();
    """
            
            webView.evaluateJavaScript(readyCheckScript) { [weak self] (result, error) in
                guard let self else { return }
                if let isReady = result as? Bool, isReady {
                    self.injectLocalStorage(webView, localStorage: self.parent.viewModel.sessionObject.localStorage)
                } else {
                    // Document not ready, wait and try again
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.injectLocalStorage(webView, localStorage: self.parent.viewModel.sessionObject.localStorage)
                    }
                }
            }
        }
        
        private func injectLocalStorage(_ webView: WKWebView, localStorage: [String : String]) {
            for (key, value) in localStorage {
                let escapedKey = parent.escapeJavaScriptString(key)
                let escapedValue = parent.escapeJavaScriptString(value)
                
                let jsCode = "window.localStorage.setItem('\(escapedKey)', '\(escapedValue)');"
                webView.evaluateJavaScript(jsCode) { (result, error) in
                    if let error = error {
                        print("Error setting localStorage: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // Handle navigation failures
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            // error handling
        }
        
        // Handle errors during initial load
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            // error handling
        }
    }
}
