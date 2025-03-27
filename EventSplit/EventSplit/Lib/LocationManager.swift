
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        print("📱 LocationManager initializing...")
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.allowsBackgroundLocationUpdates = false
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let firstLocation = locations.first {
            location = firstLocation
            manager.stopUpdatingLocation()
            print("Location updated: \(firstLocation)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    func calculateDistance(to coordinates: String?) -> Double? {
        
        guard let location = location,
              let coordinates = coordinates else {
            print("Error: Missing location or coordinates")
            return nil
        }
        
        let coordinateArray = coordinates.split(separator: ",")
        
        guard coordinateArray.count == 2,
              let latitude = Double(coordinateArray[0].trimmingCharacters(in: .whitespaces)),
              let longitude = Double(coordinateArray[1].trimmingCharacters(in: .whitespaces)) else {
            print("Error: Invalid coordinate format")
            return nil
        }
        
        let eventLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distance = location.distance(from: eventLocation) / 1000
        
        return distance
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location Manager: Authorization changed to: \(manager.authorizationStatus.rawValue)")
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Info: Location authorized, starting updates")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Error: Location access denied or restricted")
        case .notDetermined:
            print("Info: Waiting for user authorization")
        @unknown default:
            break
        }
    }
}

