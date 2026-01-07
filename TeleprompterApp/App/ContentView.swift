import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .record
    
    enum Tab {
        case scripts
        case record
        case settings
    }
    
    init() {
        // Configure tab bar with glass/translucent appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
//        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
//
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ScriptListView()
                .tabItem {
                    Label("Scripts", systemImage: "doc.text")
                }
                .tag(Tab.scripts)
            
            RecordingView()
                .tabItem {
                    Label("Record", systemImage: "video.fill")
                }
                .tag(Tab.record)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
        .tint(.red)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
