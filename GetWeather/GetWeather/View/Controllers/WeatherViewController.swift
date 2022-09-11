import UIKit
import CoreLocation
import Indicators

class WeatherViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tempTypeChangerButton: UIButton!
    
    let locationManager = CLLocationManager()
    let viewModel = WeatherViewModel()
    var items: Weather?
    var latitude: Double?
    var longitude: Double?
    var updatingLocation = false
    var timer: Timer?
    var lastLocationError: Error?
    var isFetched = false
    var temperature = 0
    var changeTemperatureHelper = 0
        
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPopupButton()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CurrentWeatherCell", bundle: nil),
                                forCellWithReuseIdentifier: "CurrentWeatherCell")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        startLocationManager()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func fetchData() {
        guard latitude != nil else {
            return
        }
        guard location != nil else {
            return
        }
        viewModel.fetchData(latitude: self.latitude!, longitude: self.longitude!) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let weater):
                self?.items = weater
                self?.isFetched = true
            }
        }
        setLabels()
    }
    
    func setLabels() {
        if let cell = collectionView.cellForItem(at: [0, 0]) as? CurrentWeatherCell {
            if isFetched {
                cell.temperatureLabel.isHidden = false
                cell.cityLabel.isHidden = false
                cell.descriptionLabel.isHidden = false
                cell.countryLabel.isHidden = false
                cell.windLabel.isHidden = false
            }
            
            if let kelvin = items?.main.temp {
                switch changeTemperatureHelper {
                case 0:
                    cell.temperatureLabel.text = String(Int(kelvin - 273.15))
                case 1:
                    cell.temperatureLabel.text = String(Int(kelvin))
                case 2:
                    cell.temperatureLabel.text = String(Int(1.8 * (kelvin - 273.15) + 32))
                default:
                    cell.temperatureLabel.text = String(Int(kelvin - 273.15))
                }
            }
            cell.backgroundColor = UIColor(patternImage: UIImage(named: "cellBackground")!)
            cell.layer.cornerRadius = 10
            cell.cityLabel.text = items?.name
            cell.countryLabel.text = items?.sys.country
            if let weather = items?.weather {
                cell.descriptionLabel.text = weather.first?.description
            }
            if let windSpeed = items?.wind.speed {
                cell.windLabel.text = String(windSpeed)
            }
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(
                timeInterval: 10,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false)
        }
    }
    
    @objc func didTimeOut() {
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(
                domain: "MyLocationsErrorDomain",
                code: 1,
                userInfo: nil)
        }
    }
    
    func setPopupButton() {
        let optionClosure = {(action: UIAction) in
            self.changeTemperatureType(action: action)
        }
        tempTypeChangerButton.menu = UIMenu(children: [
            UIAction(title: "°F", state: .off, handler: optionClosure),
            UIAction(title: "°C", state: .on, handler: optionClosure),
            UIAction(title: "°K", state: .off, handler: optionClosure)
        ])
        tempTypeChangerButton.showsMenuAsPrimaryAction = true
        tempTypeChangerButton.changesSelectionAsPrimaryAction = true
    }
    
    func changeTemperatureType(action: UIAction) {
        if let cell = collectionView.cellForItem(at: [0, 0]) as? CurrentWeatherCell {
            if action.title == "°F" {
                changeTemperatureHelper = 2
                cell.temperatureTypeLabel.text = "Fahrenheit"
            } else if action.title == "°C" {
                cell.temperatureTypeLabel.text = "Celsius"
                changeTemperatureHelper = 0
            } else {
                cell.temperatureTypeLabel.text = "Kelvin"
                changeTemperatureHelper = 1
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}


extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
    }
}

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentWeatherCell", for: indexPath) as? CurrentWeatherCell else { return UICollectionViewCell()}
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "cellBackground")!)
        setLabels()
        return cell
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}


extension WeatherViewController: CLLocationManagerDelegate {
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        startLocationManager()
        if let location = locations.first {
            self.location = location
        }
        latitude = location?.coordinate.latitude ?? nil
        longitude = location?.coordinate.longitude ?? nil
        fetchData()
        if isFetched == false {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
        }
    }
}
