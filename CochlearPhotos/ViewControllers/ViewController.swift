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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewHeight = self.view.frame.height
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
        mapListHeightConstraint.constant = mapViewHeight - mapGap
        mapGapBottom = mapViewHeight - mapGap
        print (mapGapBottom!)
        
        setupLocTableView()
        
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
   

    @IBAction func didPanMapListView(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
     //   print("translation \(translation)")
        
        if sender.state == UIGestureRecognizer.State.began {
            locViewOriginalCenter = locationsView.center
            locViewOriginalY = locationsView.frame.origin.y

            print(locationsView.frame.origin.y)
        } else if sender.state == UIGestureRecognizer.State.changed {
            print(locationsView.frame.origin.y)
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
    
    func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == locationDetailSegue {

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

extension ViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func setupLocTableView() {

        locList = Location.getAll() ?? [Location]()
        
        locTableView.delegate = self
        locTableView.dataSource = self
        locTableView.tableFooterView = UIView()
        
        locTableView.reloadData()
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
    //    cell.detailTextLabel?.text = loc.name

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
        
        performSegue(withIdentifier: locationDetailSegue, sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
}
