//
//  MapPlaybackThumbNail.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/19/26.
//

import SwiftUI
import MapKit

struct MapPlaybackThumbNail: View {
    let compassApi: PlaybackCompassRepository
    @State private var position: MapCameraPosition = .automatic

    private var coord: CLLocationCoordinate2D? {
        guard let lat = compassApi.latitude, let lon = compassApi.longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var body: some View {
        Map(position: $position) {
            if let c = coord {
                Annotation("", coordinate: c) {
                    Image(systemName: "location.north.fill")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(.orange)
                        .rotationEffect(.degrees(compassApi.heading))
                        .shadow(color: .black.opacity(0.6), radius: 2)
                }
            }
        }
        .mapStyle(.standard)
        .mapControlVisibility(.hidden)
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(0.5)
        .onChange(of: compassApi.latitude) { _, _ in
            guard let c = coord else { return }
            position = .camera(MapCamera(centerCoordinate: c, distance: 1000))
        }
    }
}

#Preview {
    MapPlaybackThumbNail(compassApi: PlaybackCompassRepository())
}
