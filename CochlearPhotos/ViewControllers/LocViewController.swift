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
    let LOADED = "loaded"
    
    let mapGap: CGFloat = 120
    var mapGapBottom: CGFloat!
    var mapViewHeight: CGFloat!
    var locViewOriginalCenter: CGPoint!
    var locViewOriginalY: CGFloat!
    var locListHeightOrig: CGFloat!
    var locListHeightDef: CGFloat!
    
    let locationManager = CLLocationManager()
    var locList: [Location] = []
    var selectedLoc: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var pressedLoc = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupView()
        
        initLocTable()
        
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
        
        locTableView.alpha = 1
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshView()
    }
   
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
           
        setupLocTableView()
        setHeights()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
           if segue.identifier == locationDetailSegue {
               if let locDetailViewController = segue.destination as? LocDetailViewController {
                   locDetailViewController.selectedLocation = sender as? Location
               }
           }
       }
    
    func setupView(){
        pressedLoc = LOADED
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func refreshView(){
        setupLocTableView()
        pressedLoc = ""
        locListHeightOrig = mapListHeightConstraint.constant
    }
    
    @objc func willEnterForeground() {

        setupLocTableView()
    }
    
    func initLocTable(){
        
        locTableView.delegate = self
        locTableView.dataSource = self
        locTableView.tableFooterView = UIView()
        mapView.delegate = self
    }
    
    func annotateLocationList(completion : @escaping (Bool)->()){
        
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
        let locationList: [Location] = Location.getAll()!
        
        for (index, location) in locationList.enumerated() {
            let locAnnotation = location.toLocAnnotation()
            mapView.addAnnotation(locAnnotation)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            if index == 0 && pressedLoc == LOADED {
                let region = MKCoordinateRegion(center: locAnnotation.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
            let distance: Double = locDistance(from: locAnnotation) ?? 0
            location.distance = distance
            Location.updateDistance(location: location)
        }
        completion(true)
    }
    
    @IBAction func didPanMapListView(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)

        if sender.state == UIGestureRecognizer.State.began {
            locViewOriginalCenter = locationsView.center
            locViewOriginalY = locationsView.frame.origin.y
   
        } else if sender.state == UIGestureRecognizer.State.changed {
            let newHeight = locListHeightOrig - translation.y
            mapListHeightConstraint.constant = newHeight
          
        } else if sender.state == UIGestureRecognizer.State.ended {
            
            locListHeightOrig = mapListHeightConstraint.constant
            
            if locationsView.frame.origin.y < mapGap {
                UIView.animate(withDuration:0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                animations: { () -> Void in
                    self.locationsView.frame.origin.y = self.mapGap
                    self.mapListHeightConstraint.constant = self.locListHeightDef
                    self.locListHeightOrig = self.locListHeightDef
                }, completion: nil)
                
            }else if (locationsView.frame.origin.y > mapGapBottom ) {
                UIView.animate(withDuration:0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                animations: { () -> Void in
                    self.locationsView.frame.origin.y = self.mapGapBottom + self.mapGap
                    self.mapListHeightConstraint.constant = self.mapGap
                    self.locListHeightOrig = self.mapGap
                }, completion: nil)
            }
        }
    }
    
    @IBAction func didLongPressMapView(_ sender: UILongPressGestureRecognizer) {

        let touchPoint = sender.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        
        
        let loc = Location(locType: LocType.custom, coordinate: annotation.coordinate)
        selectedLoc = loc.toCL()
        
        let newPressedLoc = String(selectedLoc.latitude + selectedLoc.longitude)
        if pressedLoc != newPressedLoc {
            pressedLoc = newPressedLoc
            performSegue(withIdentifier: locationDetailSegue, sender: loc)
        }
    }
    
    @IBAction func didPressRefreshButton(_ sender: UIBarButtonItem) {
        refreshView()
    }
    
    @IBAction func currentLocation(_ sender: UIBarButtonItem) {
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
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
 
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let loc:Location!
        let name = view.annotation?.title
        
        if name is String {
            let ann = view.annotation as! LocAnnotation
            let placeName = ann.title!
            loc = Location.get(name: placeName)
        }else{
            loc = Location(locType: LocType.custom, coordinate: view.annotation!.coordinate)
        }
        if loc != nil {
            selectedLoc = loc.toCL()
            performSegue(withIdentifier: locationDetailSegue, sender: loc)
        }
    }

}
extension LocViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func setupLocTableView() {
        
        locListHeightDef = self.view.frame.height - mapGap
        locList = Location.getAll() ?? [Location]()
        annotateLocationList(completion: { listDone in
            self.locList = Location.getAll() ?? [Location]()
            self.locTableView.reloadData()
        })
        if selectedLoc.latitude == 0 {
            setHeights()
        }
    }
    
    func setHeights(){
        mapViewHeight = self.view.frame.height
        mapListHeightConstraint.constant = mapViewHeight - mapGap
        mapGapBottom = mapViewHeight - mapGap
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
        cell.textLabel?.textColor = UIColor.label
        cell.backgroundColor = UIColor.systemGray5
        if loc.locType == LocType.custom.rawValue {
            cell.textLabel?.textColor = UIColor.label
            cell.backgroundColor = UIColor.secondarySystemGroupedBackground
        }
        if let distance = loc.distance {
            cell.detailTextLabel?.text = Util.distanceToString(distance)
        }
        cell.detailTextLabel?.textColor = cell.textLabel?.textColor
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.setupLocTableView()
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
