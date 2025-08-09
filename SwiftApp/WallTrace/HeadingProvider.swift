import Foundation
import CoreLocation
import Combine

/// The class that will provide the heading of the device. Will be used to align the initial local heading with the absolute geographical heading.
/// 
final class HeadingProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let lm = CLLocationManager()
    @Published private(set) var headingDeg: Double?

    override init() {
        super.init()
        lm.delegate = self
        if CLLocationManager.headingAvailable() {
            lm.headingFilter = 1
            lm.requestWhenInUseAuthorization()
            lm.startUpdatingHeading()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading h: CLHeading) {
        guard h.headingAccuracy >= 0 else { return }   // ignore invalid
        let deg = (h.trueHeading >= 0) ? h.trueHeading : h.magneticHeading
        DispatchQueue.main.async { self.headingDeg = deg }
    }
}
