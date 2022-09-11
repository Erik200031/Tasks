import Foundation

struct Weathers: Codable {
    let object: Weather?
}

struct Weather: Codable {
    let weather: [Description]
    let main: Main
    let wind: Wind
    let sys: Sys
    let timezone: Int
    let name: String
}

struct Description: Codable {
    let description: String
}

struct Main: Codable {
    let temp: Double
}

struct Wind: Codable {
    let speed: Double
}

struct Sys: Codable {
    let country: String
}
