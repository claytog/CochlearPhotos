//
//  ViewController.swift
//  CochlearPhotos
//
//  Created by Clayton on 20/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        // Do any additional setup after loading the view.
        if DBManager.shared.openOrCopyDatabase() { // initialise a singleton instance of the database
            let locationList: [Location] = Location.getAll()!
        
            for location in locationList {
            let locationCL = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
                let locAnnotation = LocAnnotation(title: location.name,
                  locationName: location.name,
                  locationType: location.locType ?? "",
                  coordinate: locationCL)
                mapView.addAnnotation(locAnnotation)
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: locationCL, span: span)
                mapView.setRegion(region, animated: true)
            }
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if DBManager.shared.openOrCopyDatabase() { // initialise a singleton instance of the database
            
            LocationsAPI.get( completion: { locationsResponse in
                //   self.weatherResponse = weatherResponse
                print ("\n**** CONTENT DONLOADED, opening storyboard ***\n")
                print (locationsResponse)
             
            })
        }
    }

}
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? LocAnnotation else { return nil }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let ann = view.annotation as! LocAnnotation
        let placeName = ann.title

        print(placeName)
      /*
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
 */
    }
}
