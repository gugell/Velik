//
//  Location+Extension.swift
//  Fietscomputer
//
//  Created by Grigory Avdyushin on 23/06/2020.
//  Copyright © 2020 Grigory Avdyushin. All rights reserved.
//

import MapKit
import CoreLocation

extension Double {
    func asRadians() -> Double {
        Measurement(value: self, unit: UnitAngle.degrees).converted(to: .radians).value
    }
    func asDegrees() -> Double {
        Measurement(value: self, unit: UnitAngle.radians).converted(to: .degrees).value
    }
}

extension Collection where Element == CLLocationCoordinate2D {

    /// See: http://www.geomidpoint.com/calculation.html
    func center() -> Element? {
        guard !isEmpty else {
            return nil
        }
        guard count > 1 else {
            return self.first!
        }

        var x = Double.zero
        var y = Double.zero
        var z = Double.zero

        forEach {
            let lat = $0.latitude.asRadians()
            let lon = $0.longitude.asRadians()
            x += cos(lat) * cos(lon)
            y += cos(lat) * sin(lon)
            z += sin(lat)
        }

        x /= Double(count)
        y /= Double(count)
        z /= Double(count)

        let lon = atan2(y, x)
        let hyp = sqrt(x * x + y * y)
        let lat = atan2(z, hyp)

        return CLLocationCoordinate2D(latitude: lat.asDegrees(), longitude: lon.asDegrees())
    }

    func region() -> MKCoordinateRegion? {
        guard count > 1 else {
            return nil
        }

        let minLatitude = self.min(by: \.latitude)!.latitude
        let minLongitude = self.min(by: \.longitude)!.longitude
        let maxLatitude = self.max(by: \.latitude)!.latitude
        let maxLongitude = self.max(by: \.longitude)!.longitude

        let southWest = CLLocation(latitude: minLatitude, longitude: minLongitude)
        let southEast = CLLocation(latitude: minLatitude, longitude: maxLongitude)
        let northEast = CLLocation(latitude: maxLatitude, longitude: maxLongitude)
        let northWest = CLLocation(latitude: maxLatitude, longitude: minLongitude)

        let latitudinalMeters = southWest.distance(from: southEast)
        let longitudinalMeters = northEast.distance(from: northWest)

        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2

        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)

        return MKCoordinateRegion(
            center: center,
            latitudinalMeters: latitudinalMeters * 1.2,
            longitudinalMeters: longitudinalMeters * 1.2
        )
    }
}

extension CLLocationCoordinate2D {
    init(trackPoint: TrackPoint) {
        self.init(latitude: trackPoint.latitude, longitude: trackPoint.longitude)
    }
}

extension CLLocation {
    convenience init(wayPoint: GPXPoint) {
        self.init(
            coordinate: CLLocationCoordinate2D(
                latitude: wayPoint.latitude,
                longitude: wayPoint.longitude),
            altitude: wayPoint.elevation ?? 0,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            course: 0,
            speed: wayPoint.speed ?? 0,
            timestamp: wayPoint.timestamp ?? Date()
        )
    }
}
