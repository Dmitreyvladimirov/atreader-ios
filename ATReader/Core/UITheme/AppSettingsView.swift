import SwiftUI

struct AppSettingsView: View {
    @AppStorage("app_theme") private var appTheme = "light"
    @AppStorage("app_language") private var appLanguage = "ru"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "settings.section.appearance")) {
                    Picker(String(localized: "settings.theme.title"), selection: $appTheme) {
                        Text(String(localized: "settings.theme.light")).tag("light")
                        Text(String(localized: "settings.theme.dark")).tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                Section(String(localized: "settings.section.language")) {
                    Picker(String(localized: "settings.language.title"), selection: $appLanguage) {
                        Text("Русский").tag("ru")
                        Text("English").tag("en")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(String(localized: "settings.title"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("Settings") {
    AppSettingsView()
}
