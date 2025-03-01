//
//  SettingsPage.swift
//  WeatherApplication
//
//  Created by Sakeen Jaleel on 2025-01-12.
//
import SwiftUI

enum ThemeMode: String, Codable {
    case light, dark
}

enum TemperatureUnit: String, Codable {
    case celsius, fahrenheit
    
    func convert(_ temperature: Double) -> Double {
        switch self {
        case .celsius:
            return temperature
        case .fahrenheit:
            return (temperature * 9/5) + 32
        }
    }
    
    var symbol: String {
        switch self {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        }
    }
}

class SettingsManager: ObservableObject {
    @AppStorage("themeMode") private var themeModeValue = ThemeMode.dark.rawValue
    @AppStorage("temperatureUnit") private var temperatureUnitValue = TemperatureUnit.celsius.rawValue
    
    @Published var themeMode: ThemeMode
    @Published var temperatureUnit: TemperatureUnit
    
    init() {
        // Initialize the published properties first
        self.themeMode = ThemeMode(rawValue: UserDefaults.standard.string(forKey: "themeMode") ?? ThemeMode.dark.rawValue) ?? .dark
        self.temperatureUnit = TemperatureUnit(rawValue: UserDefaults.standard.string(forKey: "temperatureUnit") ?? TemperatureUnit.celsius.rawValue) ?? .celsius
        
        // Then set up the property observers
        self.addObservers()
    }
    
    private func addObservers() {
        // Set up observers after initialization
        self.objectWillChange.send()
        themeModeValue = themeMode.rawValue
        temperatureUnitValue = temperatureUnit.rawValue
    }
    
    func updateThemeMode(_ mode: ThemeMode) {
        themeMode = mode
        themeModeValue = mode.rawValue
    }
    
    func updateTemperatureUnit(_ unit: TemperatureUnit) {
        temperatureUnit = unit
        temperatureUnitValue = unit.rawValue
    }
}

struct SettingsPage: View {
    @EnvironmentObject private var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: $settingsManager.themeMode) {
                        Text("Light").tag(ThemeMode.light)
                        Text("Dark").tag(ThemeMode.dark)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: settingsManager.themeMode) { newValue in
                        settingsManager.updateThemeMode(newValue)
                    }
                }
                
                Section("Units") {
                    Picker("Temperature", selection: $settingsManager.temperatureUnit) {
                        Text("Celsius").tag(TemperatureUnit.celsius)
                        Text("Fahrenheit").tag(TemperatureUnit.fahrenheit)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: settingsManager.temperatureUnit) { newValue in
                        settingsManager.updateTemperatureUnit(newValue)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(settingsManager.themeMode == .dark ? .dark : .light)
    }
}

#Preview {
    SettingsPage()
        .environmentObject(SettingsManager())
}
