//
//  AppThemeSettingsView.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2025-09-29.
//

import SwiftUI

struct AppThemeSettingsView: View {
    @AppStorage("appTheme") private var appThemeRaw: String = AppTheme.system.rawValue
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Form {
            Section(header: Text("App Theme")) {
                Picker("Theme", selection: $appThemeRaw) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.displayName).tag(theme.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("App Theme")
        .onChange(of: appThemeRaw) { newValue in
            applyTheme(AppTheme(rawValue: newValue) ?? .system)
        }
    }
    
    private func applyTheme(_ theme: AppTheme) {
        switch theme {
        case .system:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
        case .light:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        case .dark:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        }
    }
}

//#Preview {
//    AppThemeSettingsView()
//}
enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}
