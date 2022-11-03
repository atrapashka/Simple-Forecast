//
//  HourlyWeatherResponse.swift
//  Simple-Forecast
//
//  Created by Alehandro on 22.04.22.
//

import Foundation

struct HourlyWeatherResponse: Decodable {
    let timezone: String
    let current: Current
    let hourly: [Hourly]
    let daily: [Daily]
}

struct Current: Decodable {
    let dt: Int
    let temp: Double
    let feels_like: Double
    let clouds: Int
    let visibility: Int
    let wind_speed: Double
    let weather: [Weather]
}

struct Hourly: Decodable {
    let temp: Double
    let weather: [Weather]
}

struct Daily: Decodable {
    let temp: Temp
    let weather: [Weather]
}

struct Temp: Decodable {
    let min: Double
    let max: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
