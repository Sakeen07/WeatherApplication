//
//  ContentView.swift
//  WeatherApplication
//
//  Created by Sakeen Jaleel on 2025-01-12.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var citiesManager = SavedCitiesManager()
    @StateObject private var settingsManager = SettingsManager()
    @State private var isEditMode = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                SearchPage(isEditMode: $isEditMode)
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search Page")
                    }
                    .environmentObject(citiesManager)
                    .environmentObject(settingsManager)
                    .preferredColorScheme(settingsManager.themeMode == .dark ? .dark : .light)
                
                WorldMapPage()
                    .tabItem {
                        Image(systemName: "map")
                        Text("Map Page")
                    }
                    .environmentObject(citiesManager)
                    .environmentObject(settingsManager)
            }
            
            if isEditMode {
                Rectangle()
                    .fill(settingsManager.themeMode == .dark ? Color.black : Color.white)
                    .frame(height: 49)
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

#Preview {
    ContentView()
}
