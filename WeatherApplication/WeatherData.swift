//
//  WeatherData.swift
//  WeatherApplication
//
//  Created by Sakeen Jaleel on 2025-01-12.
//
import SwiftUI

// MARK: - Structs for API Responses

struct WeatherData: Codable, Identifiable {
    var id = UUID()
    let temperature: Double
    let highTemperature: Double
    let lowTemperature: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let weatherDescription: String
    let locationName: String
    let feelsLike: Double
    let windDirection: String
    let visibility: Double
    let sunrise: Date
    let sunset: Date
    let uvIndex: Double
    let airQuality: String
    let cloudCover: Int?
    let precipitation: Double?
    var hourlyForecast: [HourlyForecast]
    var dailyForecast: [DayForecast]
}

struct HourlyForecast: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let temperature: Double
    let description: String
    let precipitation: Double?
    let cloudCover: Int?
}

struct DayForecast: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let temperature: Double
    let description: String
    let pressure: Double
    let humidity: Double
    let windSpeed: Double
    let windDirection: String
    let precipitation: Double?
    let cloudCover: Int?
}

struct ForecastResult {
    let hourly: [HourlyForecast]
    let daily: [DayForecast]
}

struct AirQualityData: Codable {
    let aqi: Int
    let co: Double
    let no2: Double
    let so2: Double
    let o3: Double
    let pm2_5: Double
    let pm10: Double
    
    var qualityDescription: String {
        switch aqi {
        case 1:
            return "Good"
        case 2:
            return "Fair"
        case 3:
            return "Moderate"
        case 4:
            return "Poor"
        case 5:
            return "Very Poor"
        default:
            return "Unknown"
        }
    }
}

// MARK: - API Response Models

struct CurrentWeatherResponse: Codable {
    struct Main: Codable {
        let temp: Double
        let temp_max: Double
        let temp_min: Double
        let humidity: Double
        let pressure: Double
        let feels_like: Double
    }
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
    struct Weather: Codable {
        let description: String
    }
    struct Clouds: Codable {
        let all: Int
    }
    struct Precipitation: Codable {
        let lastThreeHours: Double?
        enum CodingKeys: String, CodingKey {
            case lastThreeHours = "3h"
        }
    }
    struct Sys: Codable {
        let sunrise: Int
        let sunset: Int
    }
    let main: Main
    let wind: Wind
    let weather: [Weather]
    let visibility: Int
    let name: String
    let sys: Sys
    let clouds: Clouds?
    let rain: Precipitation?
    let snow: Precipitation?
}

struct ForecastResponse: Codable {
    struct Forecast: Codable {
        struct Main: Codable {
            let temp: Double
            let pressure: Double
            let humidity: Double
        }
        struct Wind: Codable {
            let speed: Double
            let deg: Int
        }
        struct Weather: Codable {
            let description: String
        }
        struct Precipitation: Codable {
            let lastThreeHours: Double?
            enum CodingKeys: String, CodingKey {
                case lastThreeHours = "3h"
            }
        }
        struct Clouds: Codable {
            let all: Int
        }
        
        let dt: Int
        let main: Main
        let weather: [Weather]
        let wind: Wind
        let rain: [String: Double]?
        let snow: [String: Double]?
        let clouds: Clouds
        
        var precipitation: Double? {
            (rain?["3h"] ?? 0.0) + (snow?["3h"] ?? 0.0)
        }
    }
    let list: [Forecast]
}

struct UVIndexResponse: Codable {
    let value: Double
}

struct AirPollutionResponse: Codable {
    struct Components: Codable {
        let co: Double
        let no2: Double
        let so2: Double
        let o3: Double
        let pm2_5: Double
        let pm10: Double
    }
    struct Main: Codable {
        let aqi: Int
    }
    struct PollutionData: Codable {
        let main: Main
        let components: Components
    }
    let list: [PollutionData]
}

// MARK: - Weather Service Protocol

protocol WeatherService {
    func fetchCurrentWeather(for city: String) async throws -> WeatherData
    func fetchForecast(for city: String) async throws -> ForecastResult
    func fetchUVIndex(lat: Double, lon: Double) async throws -> Double
    func fetchAirQuality(lat: Double, lon: Double) async throws -> AirQualityData
}

// MARK: - OpenWeather Service Implementation

class OpenWeatherService: WeatherService {
    private let apiKey: String
    private let decoder: JSONDecoder
    
    init(apiKey: String = Config.apiKey) {
        self.apiKey = apiKey
        self.decoder = JSONDecoder()
    }
    
    func fetchCurrentWeather(for city: String) async throws -> WeatherData {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedData = try decoder.decode(CurrentWeatherResponse.self, from: data)
        let forecastResult = try await fetchForecast(for: city)
        
        return WeatherData(
            temperature: decodedData.main.temp,
            highTemperature: decodedData.main.temp_max,
            lowTemperature: decodedData.main.temp_min,
            humidity: decodedData.main.humidity,
            pressure: decodedData.main.pressure,
            windSpeed: decodedData.wind.speed,
            weatherDescription: decodedData.weather.first?.description ?? "",
            locationName: decodedData.name,
            feelsLike: decodedData.main.feels_like,
            windDirection: WindDirection.convert(degrees: decodedData.wind.deg),
            visibility: Double(decodedData.visibility) / 1000.0,
            sunrise: Date(timeIntervalSince1970: TimeInterval(decodedData.sys.sunrise)),
            sunset: Date(timeIntervalSince1970: TimeInterval(decodedData.sys.sunset)),
            uvIndex: 0,
            airQuality: "",
            cloudCover: decodedData.clouds?.all,
            precipitation: decodedData.rain?.lastThreeHours ?? decodedData.snow?.lastThreeHours,
            hourlyForecast: forecastResult.hourly,
            dailyForecast: forecastResult.daily
        )
    }
    
    func fetchForecast(for city: String) async throws -> ForecastResult {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=\(encodedCity)&appid=\(apiKey)&units=metric") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedData = try decoder.decode(ForecastResponse.self, from: data)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let hourlyForecasts = decodedData.list.prefix(8).map { forecast in
            HourlyForecast(
                date: Date(timeIntervalSince1970: TimeInterval(forecast.dt)),
                temperature: forecast.main.temp,
                description: forecast.weather.first?.description ?? "",
                precipitation: forecast.precipitation,
                cloudCover: forecast.clouds.all
            )
        }
        
        var dailyForecasts: [Date: [ForecastResponse.Forecast]] = [:]
        for forecast in decodedData.list {
            let forecastDate = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            let startOfDay = calendar.startOfDay(for: forecastDate)
            
            if dailyForecasts[startOfDay] == nil {
                dailyForecasts[startOfDay] = []
            }
            dailyForecasts[startOfDay]?.append(forecast)
        }
        
        var dailyResults: [DayForecast] = []
        for dayOffset in 0..<5 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                continue
            }
            
            if let dayForecasts = dailyForecasts[date] {
                let middayForecast = dayForecasts.first { forecast in
                    let forecastDate = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
                    let hour = calendar.component(.hour, from: forecastDate)
                    return hour >= 11 && hour <= 13
                } ?? dayForecasts[0]
                
                let dayForecast = DayForecast(
                    date: date,
                    temperature: middayForecast.main.temp,
                    description: middayForecast.weather.first?.description ?? "",
                    pressure: middayForecast.main.pressure,
                    humidity: middayForecast.main.humidity,
                    windSpeed: middayForecast.wind.speed,
                    windDirection: WindDirection.convert(degrees: middayForecast.wind.deg),
                    precipitation: middayForecast.precipitation,
                    cloudCover: middayForecast.clouds.all
                )
                dailyResults.append(dayForecast)
            }
        }
        
        return ForecastResult(hourly: hourlyForecasts, daily: dailyResults)
    }
    
    func fetchUVIndex(lat: Double, lon: Double) async throws -> Double {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/uvi?lat=\(lat)&lon=\(lon)&appid=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedData = try decoder.decode(UVIndexResponse.self, from: data)
        return decodedData.value
    }
    
    func fetchAirQuality(lat: Double, lon: Double) async throws -> AirQualityData {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedData = try decoder.decode(AirPollutionResponse.self, from: data)
        
        return AirQualityData(
            aqi: decodedData.list.first?.main.aqi ?? 0,
            co: decodedData.list.first?.components.co ?? 0,
            no2: decodedData.list.first?.components.no2 ?? 0,
            so2: decodedData.list.first?.components.so2 ?? 0,
            o3: decodedData.list.first?.components.o3 ?? 0,
            pm2_5: decodedData.list.first?.components.pm2_5 ?? 0,
            pm10: decodedData.list.first?.components.pm10 ?? 0
        )
    }
}

// MARK: - Helper Types

enum WindDirection {
    static func convert(degrees: Int) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((Double(degrees) + 22.5) / 45.0) % 8
        return directions[index]
    }
}

