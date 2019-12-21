//
//  LocAnnotation.swift
//  CochlearPhotos
//
//  Created by Clayton on 20/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//
import MapKit

class LocAnnotation: NSObject, MKAnnotation {
  let title: String?
  let locationName: String
  let locType: String
  let coordinate: CLLocationCoordinate2D
  
  init(title: String, locationName: String, locationType: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.locationName = locationName
    self.locType = locationType
    self.coordinate = coordinate
    

    super.init()
  }
  
  var subtitle: String? {
    return locationName
  }
}

