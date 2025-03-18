import SwiftUI
import WebKit

struct ContentView: View {
    
    @StateObject private var viewModel: WebViewModel
    @State private var isLoading = false
    
    init(session: SessionObject) {
        _viewModel = StateObject(wrappedValue: WebViewModel(sessionObject: session))
    }
    
    var body: some View {
        NavigationView {
            WebViewContainer(viewModel: viewModel, isLoading: $isLoading)
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    Text("Shop")
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        viewModel.goBack()
                    }) {
                        Image(systemName: "chevron.backward")
                    }
                    .disabled(isLoading)
                    
                    Button(action: {
                        viewModel.goForward()
                    }) {
                        Image(systemName: "chevron.forward")
                    }
                    .disabled(isLoading)
                    
                    Spacer()
                    
                    // Loading indicator in toolbar
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.reload()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
        }
    }
}

// A loading overlay view
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.7))
            )
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: true)
    }
}
