//
//  EigenesExperiment.swift
//  ExperiSleep
//
//  Created by benni leven on 07.05.26.
//

import Foundation

struct EigenesExperiment: Identifiable, Codable {
    var id = UUID()
    var titel: String
    var beschreibung: String
    var icon: String
    var farbname: String
    
    var color: String { farbname }
}
