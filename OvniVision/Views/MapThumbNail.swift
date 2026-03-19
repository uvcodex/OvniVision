//
//  MapThumbNail.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/19/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapThumbNail: View {
    @Environment(LocationRepository.self) var locationApi
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

    private var isAuthorized: Bool {
        let s = locationApi.authorizationStatus
        return s == .authorizedWhenInUse || s == .authorizedAlways
    }

    var body: some View {
        if isAuthorized {
            Map(position: $position) {
                if let coord = locationApi.location {
                    Annotation("", coordinate: coord, anchor: .center) {
                        Image(systemName: "location.north.fill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.orange)
                            .rotationEffect(.degrees(locationApi.heading))
                            .shadow(color: .black.opacity(0.6), radius: 2)
                    }
                }
            }
            .mapStyle(.standard)
            .mapControlVisibility(.hidden)
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onChange(of: locationApi.location?.latitude) { _, _ in
                guard let coord = locationApi.location else { return }
                position = .camera(MapCamera(centerCoordinate: coord, distance: 1000))
            }
            .opacity(0.6)
        }
    }
}

#Preview {
    MapThumbNail()
        .environment(LocationRepository.shared)
}
