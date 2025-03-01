//
//  WeatherUtils.swift
//  WeatherApplication
//
//  Created by Sakeen Jaleel on 2025-01-12.
//
import SwiftUI

struct WeatherUtils {
    static func getTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    static func getDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
    
    static func weatherCard(location: String, temperature: Double, condition: String, highTemp: Double, lowTemp: Double, time: String?, settingsManager: SettingsManager) -> some View {
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
                                .foregroundColor(.white.opacity(0.7))
                            Text(time)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                
                Spacer()
                
                Text("\(formatTemperature(temperature, settingsManager: settingsManager))\(settingsManager.temperatureUnit.symbol)")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(condition)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("H:\(formatTemperature(highTemp, settingsManager: settingsManager))\(settingsManager.temperatureUnit.symbol) L:\(formatTemperature(lowTemp, settingsManager: settingsManager))\(settingsManager.temperatureUnit.symbol)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [
                settingsManager.themeMode == .dark ? .gray : .lightGray,
                settingsManager.themeMode == .dark ? .blue : .lightBlue
            ]),
                          startPoint: .top,
                           endPoint: .bottom)
        )
        .cornerRadius(15)
    }
    
    static func formatTemperature(_ temp: Double, settingsManager: SettingsManager) -> Int {
        Int(round(settingsManager.temperatureUnit.convert(temp)))
    }
}

struct FutureView: View {
    let cityName: String
    @State private var weatherData: WeatherData?
    @EnvironmentObject private var settingsManager: SettingsManager
    private let weatherService = OpenWeatherService()
    
    var body: some View {
        Group {
            if let weather = weatherData {
                WeatherUtils.weatherCard(
                    location: weather.locationName,
                    temperature: weather.highTemperature,
                    condition: weather.weatherDescription.capitalized,
                    highTemp: weather.highTemperature,
                    lowTemp: weather.lowTemperature,
                    time: WeatherUtils.getTimeString(from: Date()),
                    settingsManager: settingsManager
                )
            } else {
                ProgressView()
                    .task {
                        await loadWeather()
                    }
            }
        }
    }
    
    private func loadWeather() async {
        do {
            let currentWeather = try await weatherService.fetchCurrentWeather(for: cityName)
            let forecastResult = try await weatherService.fetchForecast(for: cityName)
            var weatherWithForecast = currentWeather
            weatherWithForecast.hourlyForecast = forecastResult.hourly
            weatherWithForecast.dailyForecast = forecastResult.daily
            self.weatherData = weatherWithForecast
        } catch {
            print("Error loading weather: \(error)")
        }
    }
}

struct AsyncWeatherView: View {
    let cityName: String
    @State private var weatherData: WeatherData?
    @EnvironmentObject private var citiesManager: SavedCitiesManager
    @EnvironmentObject private var settingsManager: SettingsManager
    private let weatherService = OpenWeatherService()
    
    var body: some View {
        Group {
            if let weather = weatherData {
                WeatherPage(weatherData: weather)
                    .environmentObject(citiesManager)
                    .environmentObject(settingsManager)
            } else {
                ProgressView()
                    .task {
                        await loadWeather()
                    }
            }
        }
    }
    
    private func loadWeather() async {
        do {
            let currentWeather = try await weatherService.fetchCurrentWeather(for: cityName)
            let forecastResult = try await weatherService.fetchForecast(for: cityName)
            var weatherWithForecast = currentWeather
            weatherWithForecast.hourlyForecast = forecastResult.hourly
            weatherWithForecast.dailyForecast = forecastResult.daily
            self.weatherData = weatherWithForecast
        } catch {
            print("Error loading weather: \(error)")
        }
    }
}
