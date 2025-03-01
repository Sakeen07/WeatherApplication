//
//  SearchPage.swift
//  WeatherApplication
//
//  Created by Sakeen Jaleel on 2025-01-12.
//
import SwiftUI

struct SearchPage: View {
    @EnvironmentObject private var citiesManager: SavedCitiesManager
    @EnvironmentObject private var settingsManager: SettingsManager
    
    @Binding var isEditMode: Bool
    
    @State private var showSettings = false
    @State private var searchText = ""
    @State private var showMenu = false
    @State private var weatherData: WeatherData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuggestions = false
    
    var filteredCities: [City] {
        guard !searchText.isEmpty else { return [] }
        return City.allCases.filter { city in
            city.name.lowercased().hasPrefix(searchText.lowercased())
        }
    }
    
    private let weatherService = OpenWeatherService()
    
    var body: some View {
        NavigationView {
            ZStack {
                settingsManager.themeMode == .dark ? Color.black.ignoresSafeArea() : Color.white.opacity(0.9).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Weather")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(settingsManager.themeMode == .dark ? .white : .black)
                        
                        Spacer()
                        
                        if !isEditMode {
                            Menu {
                                Button(action: {
                                    isEditMode.toggle()
                                }) {
                                    Label("Edit List", systemImage: "list.bullet")
                                }
                                Button(action: {
                                    showSettings = true
                                }) {
                                    Label("Settings", systemImage: "gear")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(settingsManager.themeMode == .dark ? .white : .black)
                            }
                            .sheet(isPresented: $showSettings){
                                SettingsPage()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(settingsManager.themeMode == .dark ? .white : .black)
                            
                            TextField("Search for a city", text: $searchText)
                                .foregroundColor(settingsManager.themeMode == .dark ? .white : .black)
                                .disabled(isEditMode) // Only this line controls the typeability
                                .onChange(of: searchText){
                                    showSuggestions = !searchText.isEmpty
                                }
                                .onSubmit {
                                    Task {
                                        await searchCity()
                                    }
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    weatherData = nil
                                    showSuggestions = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(settingsManager.themeMode == .dark ? .white : .black)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    if showSuggestions && !filteredCities.isEmpty {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(filteredCities) { city in
                                    Button(action: {
                                        searchText = city.name
                                        showSuggestions = false
                                        Task {
                                            await searchCity()
                                        }
                                    }) {
                                        Text(city.name)
                                            .foregroundColor(settingsManager.themeMode == .dark ? .white : .black)
                                            .padding(.horizontal)
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .background(settingsManager.themeMode == .dark ? Color.black : Color.white)
                                    
                                    if city.id != filteredCities.last?.id {
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(settingsManager.themeMode == .dark ? Color.black : Color.white)
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal)
                    }
                    
                    VStack {
                        if isEditMode {
                            if let weather = weatherData {
                                weatherCard(
                                    location: weather.locationName,
                                    temperature: Int(round(weather.highTemperature)),
                                    condition: weather.weatherDescription.capitalized,
                                    highTemp: Int(round(weather.highTemperature)),
                                    lowTemp: Int(round(weather.lowTemperature)),
                                    time: WeatherUtils.getTimeString(from: Date())
                                )
                                .padding(.horizontal)
                            }
                            
                            List {
                                ForEach(citiesManager.savedCities, id: \.self) { city in
                                    if city != weatherData?.locationName {
                                        FutureView(cityName: city)
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .padding(.vertical, 4)
                                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                                Button(role: .destructive) {
                                                    if let index = citiesManager.savedCities.firstIndex(of: city) {
                                                        deleteCities(at: IndexSet([index]))
                                                    }
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                                .tint(.red)
                                            }
                                    }
                                }
                                .onMove(perform: moveCities)
                            }
                            .listStyle(PlainListStyle())
                            .background(Color.clear)
                            .scrollContentBackground(.hidden)
                        } else {
                            ScrollView {
                                VStack(spacing: 12) {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    } else if let error = errorMessage {
                                        Text(error)
                                            .foregroundColor(.red)
                                            .padding()
                                    } else if let weather = weatherData {
                                        NavigationLink(destination: WeatherPage(weatherData: weather)) {
                                            weatherCard(
                                                location: weather.locationName,
                                                temperature: Int(round(weather.highTemperature)),
                                                condition: weather.weatherDescription.capitalized,
                                                highTemp: Int(round(weather.highTemperature)),
                                                lowTemp: Int(round(weather.lowTemperature)),
                                                time: WeatherUtils.getTimeString(from: Date())
                                            )
                                        }
                                    }
                                    
                                    ForEach(citiesManager.savedCities, id: \.self) { city in
                                        if city != weatherData?.locationName {
                                            NavigationLink(destination: AsyncWeatherView(cityName: city)) {
                                                FutureView(cityName: city)
                                            }
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    deleteCities(at: IndexSet([citiesManager.savedCities.firstIndex(of: city)!]))
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    if isEditMode {
                        Button(action: {
                            isEditMode = false
                        }) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func searchCity() async {
        guard !searchText.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let currentWeather = try await weatherService.fetchCurrentWeather(for: searchText)
            let forecastResult = try await weatherService.fetchForecast(for: searchText)
            
            var weatherWithForecasts = currentWeather
            weatherWithForecasts.hourlyForecast = forecastResult.hourly
            weatherWithForecasts.dailyForecast = forecastResult.daily
            
            await MainActor.run {
                self.weatherData = weatherWithForecasts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching weather: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func moveCities(from source: IndexSet, to destination: Int) {
        withAnimation {
            citiesManager.moveCity(from: source, to: destination)
        }
    }
    
    private func deleteCities(at offsets: IndexSet) {
        citiesManager.deleteCity(at: offsets)
    }
    
    private func weatherCard(location: String, temperature: Int, condition: String, highTemp: Int, lowTemp: Int, time: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(location)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        if let time = time {
                            Text("・")
                                .foregroundColor(.white)
                            Text(time)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                Text("\(formatTemperature(Double(temperature)))\(settingsManager.temperatureUnit.symbol)")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(condition)
                    .foregroundColor(.white)
                
                Text("H:\(formatTemperature(Double(highTemp)))\(settingsManager.temperatureUnit.symbol) L:\(formatTemperature(Double(lowTemp)))\(settingsManager.temperatureUnit.symbol)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    settingsManager.themeMode == .dark ? .darkGray : .lightGray,
                    settingsManager.themeMode == .dark ? .darkBlue : .lightBlue
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(15)
    }
    
    private func formatTemperature(_ temp: Double) -> Int {
            Int(round(settingsManager.temperatureUnit.convert(temp)))
        }
}

#Preview {
    SearchPage(isEditMode: .constant(false))
        .environmentObject(SavedCitiesManager())
        .environmentObject(SettingsManager())
}
