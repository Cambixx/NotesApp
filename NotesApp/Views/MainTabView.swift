import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("Notas", systemImage: "note.text")
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gear")
                }
                .tag(1)
        }
    }
} 