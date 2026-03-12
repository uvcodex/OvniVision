//
//  App+Extensions.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/12/26.
//

import Foundation

extension TimeInterval {
    var durationString: String {
        let total = Int(self)
        let minutes = total / 60
        let seconds = total % 60
        let tenths = Int((self - Double(total)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
}
