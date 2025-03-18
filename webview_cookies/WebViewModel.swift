import WebKit


class WebViewModel: ObservableObject {
    @Published var sessionObject: SessionObject
    
    // A reference to the WKWebView so we can send navigation commands to it
    weak var webView: WKWebView?
    
    init(sessionObject: SessionObject) {
        self.sessionObject = sessionObject
    }
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func reload() {
        webView?.reload()
    }
}
