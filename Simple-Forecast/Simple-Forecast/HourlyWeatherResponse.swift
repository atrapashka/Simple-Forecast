//
//  HourlyWeatherResponse.swift
//  Simple-Forecast
//
//  Created by Alehandro on 22.04.22.
//

import Foundation

struct HourlyWeatheResponse: Decodable {
    let main: Main
}

struct Main: Decodable {
    let temp: Double
}
