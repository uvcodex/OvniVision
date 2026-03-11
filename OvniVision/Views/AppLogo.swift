//
//  AppLogoView.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/10/26.
//

import SwiftUI

struct AppLogo: View {
    var width: CGFloat = 45
    
    var body: some View {
        Image("AppLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width)
    }
}

#Preview {
    AppLogo(width: 250)
}
