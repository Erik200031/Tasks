import Foundation

class NetworkService {
    
    func fetchData(latitude: Double, longitude: Double, completion: @escaping (Result<Weather?, Error>) -> Void) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(String(latitude))&lon=\(String(longitude))&appid=8a79f299e87a3fb985390e75f6c81ef6")
        else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  200...300 ~= response.statusCode,
                  error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let result = try JSONDecoder().decode(Weather.self, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
