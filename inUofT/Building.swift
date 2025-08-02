//
//  Building.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-07-31.
//

import SwiftUI
import RealityKit
import Combine

enum ModelCategory: CaseIterable {
    case table
    
    var label: String{
        get {
            switch self {
            case .table:
                return "Tables"
            }
        }
    }
}

class Building {
    var name: String
    var campus: String
//    var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    init(name: String, campus: String, scaleCompensation: Float = 1.0){
        self.name = name
        self.campus = campus
//        self.thumbnail = UIImage(named: name) ?? UIImage(systemNmae: "photo")!
        self.scaleCompensation = scaleCompensation
        
    }
}
