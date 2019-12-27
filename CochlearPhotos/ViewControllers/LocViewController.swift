//
//  ViewController.swift
//  CochlearPhotos
//
//  Created by Clayton on 20/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationsView: UIView!
    
    @IBOutlet weak var mapListHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var locTableView: UITableView!
    
    let locationDetailSegue = "locationDetailSegue"
    
    var mapViewHeight: CGFloat!
    var locViewOriginalCenter: CGPoint!
    var locViewOriginalY: CGFloat!
    
    let mapGap: CGFloat = 100
    var mapGapBottom: CGFloat!
    
    var locList: [Location] = []
    
    let locationManager = CLLocationManager()
    
    var selectedLoc: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locTableView.delegate = self
        locTableView.dataSource = self
        locTableView.tableFooterView = UIView()
        mapView.delegate = self
        
        setCurrentLocation()
        
        mapView.delegate = self
        // Do any additional setup after loading the view.
        if DBManager.shared.openOrCopyDatabase() { // initialise a singleton instance of the database
            
            LocationsAPI.get( completion: { locationsResponse in
                                  //   self.weatherResponse = weatherResponse
            print ("\n**** CONTENT DONLOADED, opening storyboard ***\n")
            self.setupLocTableView()
                
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locTableView.alpha = 0
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupLocTableView()
    }
   
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
           
           setupLocTableView()
    }
    
    
    @IBAction func didPanMapListView(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
     //   print("translation \(translation)")
        
        if sender.state == UIGestureRecognizer.State.began {
            locViewOriginalCenter = locationsView.center
            locViewOriginalY = locationsView.frame.origin.y
         //   print(locationsView.frame.origin.y)
        } else if sender.state == UIGestureRecognizer.State.changed {
           // print(locationsView.frame.origin.y)
            let newCentre = CGPoint(x: locViewOriginalCenter.x, y: locViewOriginalCenter.y + translation.y)
        if locationsView.frame.origin.y >= mapGap && locationsView.frame.origin.y <= mapGapBottom {
            locationsView.center = newCentre
            }
        } else if sender.state == UIGestureRecognizer.State.ended {
            if locationsView.frame.origin.y < mapGap {
                UIView.animate(withDuration:1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                animations: { () -> Void in
                    self.locationsView.frame.origin.y = self.mapGap
                }, completion: nil)
                
            }else if (locationsView.frame.origin.y > mapGapBottom ) {
                UIView.animate(withDuration:1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                animations: { () -> Void in
                    self.locationsView.frame.origin.y = self.mapGapBottom
                }, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == locationDetailSegue {
            if let locDetailViewController = segue.destination as? LocDetailViewController {
                locDetailViewController.selectedLocation = sender as? Location
            }
        }
    }
    
    
    @IBAction func didLongPressMapView(_ sender: UILongPressGestureRecognizer) {
        
        let touchPoint = sender.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
    }
    
    func annotateLocationList(completion : @escaping (Bool)->()){
        
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
        
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
            
            let distance: Double = locDistance(from: locAnnotation) ?? 0
            location.distance = distance
            Location.updateDistance(location: location)
        }
        completion(true)
    }
    
}
extension LocViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? LocAnnotation else { return nil }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = false
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    /*
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let ann = view.annotation as! LocAnnotation
        let placeName = ann.title!

        if let loc = Location.get(name: placeName) {
            performSegue(withIdentifier: locationDetailSegue, sender: loc)
        }
*/
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let loc:Location!
        
        let name = view.annotation?.title
        
        if name is String { // new custom pin
            let ann = view.annotation as! LocAnnotation
            let placeName = ann.title!
            loc = Location.get(name: placeName)
        }else{
            let customPin = view.annotation?.coordinate
            loc = Location()
            loc.locType = LocType.custom.rawValue
            loc.lat = customPin?.latitude
            loc.lng = customPin?.longitude
        }
        if loc != nil {
            selectedLoc = loc.toCL()
            performSegue(withIdentifier: locationDetailSegue, sender: loc)
        }
    }
    
}

extension LocViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func setupLocTableView() {
        mapViewHeight = self.view.frame.height
        mapListHeightConstraint.constant = mapViewHeight - mapGap
        mapGapBottom = mapViewHeight - mapGap
        
        locList = Location.getAll() ?? [Location]()

        annotateLocationList(completion: { listDone in
            self.locList = Location.getAll() ?? [Location]()
            self.locTableView.reloadData()
            self.locTableView.alpha = 1
        })
        
        if selectedLoc.latitude != 0 {
             mapView.setCenter(selectedLoc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0}
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           let headerView = UIView()
           headerView.backgroundColor = UIColor.clear
           return headerView
       }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return locList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "locCell")!
        let loc: Location = locList[indexPath.section]
        cell.layer.cornerRadius = 30
        cell.textLabel?.text = loc.name
        if var distance = loc.distance {
            distance =  Double(round(distance)/1000)
            var unit = " km"
            var distanceString = String(distance)
            switch distance {
            case 0..<1:
                distanceString = String(Int(round(distance * 1000)))
                unit = " m"
            case 1..<10:
                distanceString = String(format: "%.1f", distance)
            case 10... :
                distanceString = String(Int(round(distance)))
            default:
                distanceString = distanceString + ""
            }
            cell.detailTextLabel?.text = distanceString + unit
        }

        /*
        let imageView : UIImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        if more.linkType == MoreNavigation.LinkType.EXTERNAL.rawValue {
            imageView.image = UIImage(named:Imge.Card.Link.offsite)
        }else if more.linkType == MoreNavigation.LinkType.SETTINGS.rawValue {
            imageView.image = UIImage(named:Imge.Card.Link.offsite)
        }
 */
  //      cell.accessoryView = imageView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let loc = locList[indexPath.section]
        selectedLoc = loc.toCL()
        
        mapView.setCenter(loc.toCL(), animated: true)
        
        performSegue(withIdentifier: locationDetailSegue, sender: loc)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
}
extension LocViewController: CLLocationManagerDelegate {
    
    func setCurrentLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         locationManager.stopUpdatingLocation()
    }
    
    func locDistance(from point: MKAnnotation) -> Double? {
        
        guard let userLocation = mapView.userLocation.location else {
            return 0 // User location unknown!
        }
        let pointLocation = CLLocation(
            latitude:  point.coordinate.latitude,
            longitude: point.coordinate.longitude
        )
        return userLocation.distance(from: pointLocation)
    }
    
}
