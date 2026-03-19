//
//  PermissionButton.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/19/26.
//

import SwiftUI
import CoreLocation

struct PermissionButton: View {
    @Environment(PermissionRepository.self) var permissionApi
    @Environment(LocationRepository.self) var locationApi
    let openCamera: () -> Void

    @State private var showAlert = false

    private var isLocationAuthorized: Bool {
        locationApi.authorizationStatus == .authorizedWhenInUse ||
        locationApi.authorizationStatus == .authorizedAlways
    }

    private var isLocationDenied: Bool {
        locationApi.authorizationStatus == .denied ||
        locationApi.authorizationStatus == .restricted
    }

    private var isDenied: Bool {
        permissionApi.isCameraDenied || permissionApi.isMicDenied || isLocationDenied
    }

    private var alertMessage: String {
        var missing: [String] = []
        if permissionApi.isCameraDenied { missing.append("Camera") }
        if permissionApi.isMicDenied    { missing.append("Microphone") }
        if isLocationDenied             { missing.append("Location") }
        return "\(missing.joined(separator: ", ")) access has been denied. Open Settings to enable it."
    }

    var body: some View {
        CameraButton(
            icon: isDenied ? "exclamationmark.triangle" : "dot.viewfinder",
            color: isDenied ? .red : .pink
        ) {
            if isDenied || isLocationDenied {
                showAlert = true
            } else {
                Task {
                    await permissionApi.requestCamera()
                    await permissionApi.requestMic()

                    if locationApi.authorizationStatus == .notDetermined {
                        // Show the location dialog — user must tap again after responding
                        locationApi.requestPermission()
                        return
                    }

                    if permissionApi.canOpenCamera && isLocationAuthorized {
                        locationApi.start()
                        openCamera()
                    }
                }
            }
        }
        .alert("Permission Required", isPresented: $showAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}

#Preview {
    PermissionButton {}
        .environment(PermissionRepository.shared)
        .environment(LocationRepository.shared)
}
