//
//  WorldMapPage.swift
//  WeatherApplication
//
//  Created by Sakeen Jaleel on 2025-01-12.
//
import SwiftUI
import MapKit

struct WorldMapPage: View {
    @EnvironmentObject private var settingsManager: SettingsManager
    private let weatherService = OpenWeatherService()
    
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedCity: City?
    @State private var showWeatherPage = false
    @State private var weatherData: WeatherData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position) {
                    ForEach(City.allCases) { city in
                        Annotation(city.name, coordinate: city.coordinate) {
                            VStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title)
                                
                            }
                            .onTapGesture {
                                selectedCity = city
                                withAnimation {
                                    position = .region(MKCoordinateRegion(
                                        center: city.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
                                    ))
                                }
                                Task {
                                    await fetchWeatherData(for: city.name)
                                }
                            }
                        }
                    }
                }
                .mapStyle(.imagery)
                .ignoresSafeArea(edges: [.top, .horizontal])
                
                // Weather Card Overlay at the top
                VStack {
                    if let weather = weatherData {
                        NavigationLink(destination: WeatherPage(weatherData: weather)) {
                            weatherCard(
                                location: weather.locationName,
                                temperature: Int(round(weather.temperature)),
                                condition: weather.weatherDescription.capitalized,
                                highTemp: Int(round(weather.highTemperature)),
                                lowTemp: Int(round(weather.lowTemperature)),
                                time: WeatherUtils.getTimeString(from: Date())
                            )
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Reset button
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                position = .region(MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                    span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 180)
                                ))
                                selectedCity = nil
                                weatherData = nil
                            }
                        }) {
                            Image(systemName: "globe")
                                .font(.title)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
    
    private func fetchWeatherData(for cityName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let currentWeather = try await weatherService.fetchCurrentWeather(for: cityName)
            let forecastResult = try await weatherService.fetchForecast(for: cityName)
            
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
                self.weatherData = nil
            }
        }
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
    
    // Location Manager class
    class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
        private let manager = CLLocationManager()
        @Published var hasLocationPermission = false
        
        override init() {
            super.init()
            manager.delegate = self
        }
        
        func checkPermission() {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                hasLocationPermission = true
            default:
                hasLocationPermission = false
            }
        }
        
        func requestPermission() {
            manager.requestWhenInUseAuthorization()
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            checkPermission()
        }
    }
}

#Preview {
    NavigationView {
        WorldMapPage()
            .environmentObject(SettingsManager())
    }
}

