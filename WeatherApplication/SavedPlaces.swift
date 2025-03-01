//
//  SavedPlaces.swift
//  WeatherApplication
//
//  Created by Sakeen Jaleel on 2025-01-12.
//

import SwiftUI
import MapKit

enum City: Identifiable, CaseIterable {
    case newyork
    case losangeles
    case toronto
    case mexicocity
    case buenosaires
    case riodejaneiro
    case london
    case paris
    case madrid
    case berlin
    case rome
    case colombo
    case jakarta
    case kualalumpur
    case capetown
    case lagos
    case nairobi
    case cairo
    case sydney
    case melbourne
    case perth
    case brisbane
    case tokyo
    case seoul
    case beijing
    case shanghai
    case mumbai
    case delhi
    case singapore
    case bangkok
    case moscow
    case istanbul
    case dubai
    case riyadh
    case lima
    case santiago
    case caracas
    case bogota
    case havana
    case athens
    case lisbon
    case warsaw
    case oslo
    case stockholm
    case helsinki
    case reykjavik
    case zurich
    case vienna
    case brussels

    var id: Self {
        return self
    }

    var name: String {
        switch self {
        case .newyork: return "New York"
        case .losangeles: return "Los Angeles"
        case .toronto: return "Toronto"
        case .mexicocity: return "Mexico City"
        case .buenosaires: return "Buenos Aires"
        case .riodejaneiro: return "Rio de Janeiro"
        case .london: return "London"
        case .paris: return "Paris"
        case .madrid: return "Madrid"
        case .berlin: return "Berlin"
        case .rome: return "Rome"
        case .colombo: return "Colombo"
        case .jakarta: return "Jakarta"
        case .kualalumpur: return "Kuala Lumpur"
        case .capetown: return "Cape Town"
        case .lagos: return "Lagos"
        case .nairobi: return "Nairobi"
        case .cairo: return "Cairo"
        case .sydney: return "Sydney"
        case .melbourne: return "Melbourne"
        case .perth: return "Perth"
        case .brisbane: return "Brisbane"
        case .tokyo: return "Tokyo"
        case .seoul: return "Seoul"
        case .beijing: return "Beijing"
        case .shanghai: return "Shanghai"
        case .mumbai: return "Mumbai"
        case .delhi: return "Delhi"
        case .singapore: return "Singapore"
        case .bangkok: return "Bangkok"
        case .moscow: return "Moscow"
        case .istanbul: return "Istanbul"
        case .dubai: return "Dubai"
        case .riyadh: return "Riyadh"
        case .lima: return "Lima"
        case .santiago: return "Santiago"
        case .caracas: return "Caracas"
        case .bogota: return "Bogotá"
        case .havana: return "Havana"
        case .athens: return "Athens"
        case .lisbon: return "Lisbon"
        case .warsaw: return "Warsaw"
        case .oslo: return "Oslo"
        case .stockholm: return "Stockholm"
        case .helsinki: return "Helsinki"
        case .reykjavik: return "Reykjavik"
        case .zurich: return "Zurich"
        case .vienna: return "Vienna"
        case .brussels: return "Brussels"
        }
    }

    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .newyork: return CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        case .losangeles: return CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        case .toronto: return CLLocationCoordinate2D(latitude: 43.6511, longitude: -79.3470)
        case .mexicocity: return CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)
        case .buenosaires: return CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816)
        case .riodejaneiro: return CLLocationCoordinate2D(latitude: -22.9068, longitude: -43.1729)
        case .london: return CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        case .paris: return CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        case .madrid: return CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038)
        case .berlin: return CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050)
        case .rome: return CLLocationCoordinate2D(latitude: 41.9029, longitude: 12.4964)
        case .colombo: return CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612)
        case .jakarta: return CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456)
        case .kualalumpur: return CLLocationCoordinate2D(latitude: 3.1390, longitude: 101.6869)
        case .capetown: return CLLocationCoordinate2D(latitude: -33.9249, longitude: 18.4241)
        case .lagos: return CLLocationCoordinate2D(latitude: 6.5244, longitude: 3.3792)
        case .nairobi: return CLLocationCoordinate2D(latitude: -1.2864, longitude: 36.8172)
        case .cairo: return CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357)
        case .sydney: return CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
        case .melbourne: return CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631)
        case .perth: return CLLocationCoordinate2D(latitude: -31.9505, longitude: 115.8605)
        case .brisbane: return CLLocationCoordinate2D(latitude: -27.4698, longitude: 153.0251)
        case .tokyo: return CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917)
        case .seoul: return CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        case .beijing: return CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074)
        case .shanghai: return CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737)
        case .mumbai: return CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777)
        case .delhi: return CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090)
        case .singapore: return CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        case .bangkok: return CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018)
        case .moscow: return CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
        case .istanbul: return CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        case .dubai: return CLLocationCoordinate2D(latitude: 25.276987, longitude: 55.296249)
        case .riyadh: return CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
        case .lima: return CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428)
        case .santiago: return CLLocationCoordinate2D(latitude: -33.4489, longitude: -70.6693)
        case .caracas: return CLLocationCoordinate2D(latitude: 10.4806, longitude: -66.9036)
        case .bogota: return CLLocationCoordinate2D(latitude: 4.7110, longitude: -74.0721)
        case .havana: return CLLocationCoordinate2D(latitude: 23.1136, longitude: -82.3666)
        case .athens: return CLLocationCoordinate2D(latitude: 37.9838, longitude: 23.7275)
        case .lisbon: return CLLocationCoordinate2D(latitude: 38.7169, longitude: -9.1399)
        case .warsaw: return CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122)
        case .oslo: return CLLocationCoordinate2D(latitude: 59.9139, longitude: 10.7522)
        case .stockholm: return CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686)
        case .helsinki: return CLLocationCoordinate2D(latitude: 60.1695, longitude: 24.9354)
        case .reykjavik: return CLLocationCoordinate2D(latitude: 64.1355, longitude: -21.8954)
        case .zurich: return CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417)
        case .vienna: return CLLocationCoordinate2D(latitude: 48.2082, longitude: 16.3738)
        case .brussels: return CLLocationCoordinate2D(latitude: 50.8503, longitude: 4.3517)
        }
    }
}
