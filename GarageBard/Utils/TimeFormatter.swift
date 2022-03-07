//
//  TimeFormatter.swift
//  GarageBard
//
//  Created by Mitchel Cabuloy on 3/7/22.
//

import Foundation

class TimeFormatter {
    let formatter = DateComponentsFormatter()
    
    static let instance = TimeFormatter()
    
    init() {
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
    }
    
    func format(_ duration: Double) -> String {
        guard let str = formatter.string(from: duration) else {
            return ""
        }
        
        // This fixes a bug with DateComponentsFormatter where -60...0 does not output a leading "-"
        if duration >= 0 || duration <= -60 {
            // Drop leading minute zero
            if str.hasPrefix("0") && str.count > 4 {
                return String(str.dropFirst())
            }
            
            return str
        }
        
        return "-" + format(duration * -1)
    }
}
