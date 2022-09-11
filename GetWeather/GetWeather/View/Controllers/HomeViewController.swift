import UIKit
import AVKit
import AVFoundation

class HomeViewController: UIViewController {
    
    @IBOutlet weak var getWeatherButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "WeatherIcon", ofType: "mp4")!))
        let layer = AVPlayerLayer(player: player)
        layer.frame = getWeatherButton.frame
        view.layer.addSublayer(layer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            player.play()
        })
    }

    @IBAction func getCurrentWeather(_ sender: UIButton) {
        let viewController = WeatherViewController(nibName: "WeatherViewController", bundle: nil)
        self.present(viewController, animated: true, completion: nil)
    }
}
