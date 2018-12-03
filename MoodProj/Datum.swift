//
//  Datum.swift
//
//
//

// This data structure is to save the info about a specific point in time that we would vizualize.
// Based on BarEntry but instead of only focusing on what is visualized, focuses on the base data

import Foundation
import UIKit

struct DatumEntry {
    let color: UIColor
    
    /// Ranged from 0.0 to 1.0
    let height: Float
    
    /// To be shown on top of the bar
    let textValue: String
    
    /// To be shown at the bottom of the bar
    let title: String
}
