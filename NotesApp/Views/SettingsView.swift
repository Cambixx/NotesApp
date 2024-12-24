import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Apariencia") {
                    Toggle("Modo oscuro", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { _ in
                            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                        }
                }
            }
            .navigationTitle("Ajustes")
        }
    }
} 