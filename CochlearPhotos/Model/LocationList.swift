//
//  LocationsResponse.swift
//  CochlearPhotos
//
//  Created by Clayton on 20/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import Foundation
import GRDB

// MARK: - Welcome
class LocationList: Codable {
    let locations: [Location]
    let updated: Date
}

