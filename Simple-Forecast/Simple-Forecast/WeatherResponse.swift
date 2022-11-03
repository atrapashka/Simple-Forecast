
import Foundation

struct WeatherResponse: Decodable {
    let clouds: Forecast
    let visibility: Int
    let wind: Wind
    let main: Main
    let name: String
//    let weather: [Weather]
}

//struct Weather: Decodable {
//    let id: Int
//    let main: String
//    let description: String
//    let icon: String
//}

struct Forecast: Decodable {
    let all: Int
}

struct Wind: Decodable {
    let speed: Double
    let deg: Int
}

struct Main: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
}
