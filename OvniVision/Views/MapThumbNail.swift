//
//  MapThumbNail.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/19/26.
//

import SwiftUI

struct MapThumbNail: View {
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
            VStack(alignment: .center) {
                Image(systemName: "map")
                    .foregroundStyle(.gray.opacity(0.5))
            }
        }
        .frame(width: 100, height: 100)
    }
}

#Preview {
    MapThumbNail()
}
