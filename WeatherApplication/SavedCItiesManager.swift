//
//  SavedCItiesManager.swift
//  WeatherApplication
//
//  Created by Sakeen Jaleel on 2025-01-12.
//

import SwiftUI

class SavedCitiesManager: ObservableObject {
    @AppStorage("savedCitiesData") var savedCitiesData: Data = Data()
    @Published var savedCities: [String] = []
    
    init() {
        if let decoded = try? JSONDecoder().decode([String].self, from: savedCitiesData) {
            savedCities = decoded
        }
    }
    
    func moveCity(from source: IndexSet, to destination: Int) {
        savedCities.move(fromOffsets: source, toOffset: destination)
        saveChanges()
    }
    
    func addCity(_ city: String) {
        if !savedCities.contains(city) {
            savedCities.append(city)
            saveChanges()
        }
    }
    
    func deleteCity(at offsets: IndexSet) {
        savedCities.remove(atOffsets: offsets)
        saveChanges()
    }
    
    private func saveChanges() {
        if let encoded = try? JSONEncoder().encode(savedCities) {
            savedCitiesData = encoded
        }
    }
}
