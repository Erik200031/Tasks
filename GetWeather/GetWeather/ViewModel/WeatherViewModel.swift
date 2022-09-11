import Foundation

class WeatherViewModel {
    
    var items: Weather?
    var networkService = NetworkService()
    func fetchData(latitude: Double, longitude: Double, completion: @escaping (Result<Weather?, Error>) -> Void) {
        networkService.fetchData(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let weather):
                self.items = weather
                completion(.success(weather))
            }
        }
    }
}
