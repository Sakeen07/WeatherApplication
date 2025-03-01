//
//  WeatherPage.swift
//  WeatherApplication
//
//  Created by Sakeen Jaleel on 2025-01-12.
//
import SwiftUI

struct WeatherPage: View {
    let weatherData: WeatherData
    @EnvironmentObject private var citiesManager: SavedCitiesManager
    @EnvironmentObject private var settingsManager: SettingsManager
    
    private func getTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    private func getDateString(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM"
            return formatter.string(from: date)
        }
        
    private func getDayLabel(for index: Int, date: Date) -> String {
        if index == 0 {
            return "Today"
        } else if index == 1 {
            return "Tomorrow"
        } else {
            return getDateString(from: date)
        }
    }
    
    private func calculateProgressValue(current: Double, low: Double, high: Double) -> Double {
        return (current - low) / (high - low)
    }
    
    private func calculateBarWidth(currentTemp: Double, minTemp: Double, maxTemp: Double, totalWidth: CGFloat) -> CGFloat {
        let percentage = (currentTemp - minTemp) / (maxTemp - minTemp)
        return CGFloat(percentage) * totalWidth
    }
    
    private func getUVDescription(_ value: Double) -> String {
        switch value {
        case 0...2: return "Low"
        case 3...5: return "Medium"
        case 6...10: return "High"
        default: return "Extreme"
        }
    }
    
    private func formatTemperature(_ temp: Double) -> Int {
        Int(round(settingsManager.temperatureUnit.convert(temp)))
    }
    
    private func getWeatherIcon(description: String) -> String {
        switch description.lowercased() {
        case let desc where desc.contains("clear"): return "sun.max.fill"
        case let desc where desc.contains("cloud"): return "cloud.fill"
        case let desc where desc.contains("rain"): return "cloud.rain.fill"
        case let desc where desc.contains("snow"): return "cloud.snow.fill"
        case let desc where desc.contains("thunder"): return "cloud.bolt.fill"
        case let desc where desc.contains("haze"): return "sun.haze.fill"
        case let desc where desc.contains("mist"): return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
    
    private func getWindDirectionArrow(_ direction: String) -> String {
        switch direction.uppercased() {
        case "N": return "arrow.up"
        case "NE": return "arrow.up.right"
        case "E": return "arrow.right"
        case "SE": return "arrow.down.right"
        case "S": return "arrow.down"
        case "SW": return "arrow.down.left"
        case "W": return "arrow.left"
        case "NW": return "arrow.up.left"
        default: return "arrow.up" // Default to North if direction is invalid
        }
    }
    
    private func getFeelsLikeDescription(actualTemp: Double, feelsLike: Double) -> String {
            let difference = feelsLike - actualTemp
            if abs(difference) < 1.0 { // If difference is less than 1 degree, consider it similar
                return "Similar to the actual temperature"
            } else if difference > 0 {
                return "It's higher than actual temperature"
            } else {
                return "It's lower than actual temperature"
            }
        }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.gray, .blue]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    // Header section
                    VStack(alignment: .center) {
                        HStack{
                            Spacer()
                            Button(action: {
                                citiesManager.addCity(weatherData.locationName)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                Text("Add")
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        Text(weatherData.locationName)
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(formatTemperature(weatherData.temperature))\(settingsManager.temperatureUnit.symbol)")
                            .font(.system(size: 100, weight: .thin))
                            .foregroundColor(.white)
                        
                        Text(weatherData.weatherDescription.capitalized)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("H: \(formatTemperature(weatherData.highTemperature))\(settingsManager.temperatureUnit.symbol) L: \(formatTemperature(weatherData.lowTemperature))\(settingsManager.temperatureUnit.symbol)")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    
                    // Hourly forecast section
                    VStack(alignment: .center, spacing: 1) {
                        Text("\(weatherData.weatherDescription.capitalized) will continue for now. Wind gusts are up to \(Int(weatherData.windSpeed)) km/h.")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding()
                        
                        Divider().background(Color.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 30) {
                                ForEach(weatherData.hourlyForecast.prefix(6).indices, id: \.self) { index in
                                    let forecast = weatherData.hourlyForecast[index]
                                    VStack {
                                        Text(index == 0 ? "Now" : getTimeString(from: forecast.date))
                                            .font(.system(size: 15))
                                            .foregroundColor(.white)
                                        
                                        Image(systemName: getWeatherIcon(description: forecast.description))
                                            .foregroundColor(.white)
                                        
                                        Text("\(formatTemperature(forecast.temperature))\(settingsManager.temperatureUnit.symbol)")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // 5-day forecast
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("5-DAY FORECAST")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        
                        Divider().background(Color.white)
                        
                        ForEach(weatherData.dailyForecast.indices, id: \.self) { index in
                            let forecast = weatherData.dailyForecast[index]
                            HStack {
                                // Date Section (Left)
                                Text(getDayLabel(for: index, date: forecast.date))
                                    .frame(width: 80, alignment: .leading)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // Cloud Cover Section (Middle)
                                if let cloudCover = forecast.cloudCover {
                                    HStack(spacing: 4) {
                                        Image(systemName: "cloud.fill")
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("\(cloudCover)%")
                                            .font(.footnote)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .frame(width: 80)
                                }
                                
                                Spacer()
                                
                                // Precipitation Section (Right)
                                if let precipitation = forecast.precipitation {
                                    HStack(spacing: 4) {
                                        Image(systemName: "drop.fill")
                                            .foregroundColor(.white.opacity(0.7))
                                        Text(String(format: "%.1f mm", precipitation))
                                            .font(.footnote)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .frame(width: 70, alignment: .trailing)
                                } else {
                                    HStack(spacing: 4) {
                                        Image(systemName: "drop.fill")
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("0.0 mm")
                                            .font(.footnote)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .frame(width: 70, alignment: .trailing)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // First row of info boxes
                    HStack(spacing: 15) {
                        // Sunrise box
                        WeatherInfoCard(
                            icon: "sunrise.fill",
                            title: "SUNRISE",
                            mainValue: getTimeString(from: weatherData.sunrise),
                            description: "Sunset: \(getTimeString(from: weatherData.sunset))"
                        )
                        
                        // Humidity box
                        WeatherInfoCard(
                                icon: "humidity.fill",
                                title: "HUMIDITY",
                                mainValue: "\(Int(weatherData.humidity))%",
                                description: "The dew point is \(Int(weatherData.feelsLike))° right now"
                            )
                    }
                    .padding(.horizontal)
                    
                    // Second row of info boxes
                    HStack(spacing: 15) {
                        // Feels like box
                        WeatherInfoCard(
                                icon: "thermometer.medium",
                                title: "FEELS LIKE",
                                mainValue: "\(formatTemperature(weatherData.feelsLike))\(settingsManager.temperatureUnit.symbol)",
                                description: getFeelsLikeDescription( actualTemp: weatherData.temperature, feelsLike: weatherData.feelsLike)
                            )
                        
                        // UV Index box
                        WeatherInfoCard(
                                icon: "sun.max",
                                title: "UV INDEX",
                                mainValue: "\(Int(weatherData.uvIndex))",
                                description: "\(getUVDescription(weatherData.uvIndex)) for the rest of the day"
                            )
                    }
                    .padding(.horizontal)
                    
                    // Wind box
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "wind")
                            Text("WIND")
                        }
                        .foregroundColor(.white)
                        
                        Divider().background(Color.white)
                        
                        HStack(alignment: .center) {
                            // Left content
                            VStack(alignment: .leading) {
                                Text("Wind: \(Int(weatherData.windSpeed))Km/h")
                                Text("Direction: \(weatherData.windDirection)")
                            }
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Right content with padding
                            HStack(spacing: 5) {
                                Image(systemName: getWindDirectionArrow(weatherData.windDirection))
                                    .font(.system(size: 40))
                                    .rotationEffect(.degrees(0))
                                Text("\(Int(weatherData.windSpeed))Km/h")
                                    .font(.system(size: 20))
                            }
                            .foregroundColor(.white)
                            .padding(.trailing, 10)
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    
                    // Last row of info boxes
                    HStack(spacing: 15) {
                        // Pressure box
                        WeatherInfoCard(
                               icon: "thermometer.snowflake.circle",
                               title: "PRESSURE",
                               mainValue: "\(Int(weatherData.pressure))",
                               description: "hPa"
                           )
                        
                        // Visibility box
                        WeatherInfoCard(
                                icon: "eye.circle.fill",
                                title: "VISIBILITY",
                                mainValue: "\(Int(weatherData.visibility)) km",
                                description: weatherData.visibility >= 10 ? "Perfectly Clear View" : "Limited Visibility"
                            )
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct WeatherInfoCard: View {
    let icon: String
    let title: String
    let mainValue: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.8))
            
            Text(mainValue)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding()
        .frame(width: 170, height: 200)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.2)))
    }
}

