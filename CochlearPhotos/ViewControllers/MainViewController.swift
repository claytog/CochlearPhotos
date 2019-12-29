//
//  MainViewController.swift
//  CochlearPhotos
//
//  Created by Clayton on 29/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.isHidden = true
        self.view.isHidden = true
        
        requestLocAuthority()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Util.isOnboard(){
            openLocStoryboard()
        }else{
            self.view.isHidden = false
            animateTitle()
            if DBManager.shared.openOrCopyDatabase() { // initialise a singleton instance of the database
               showActivityIndicator()
               LocationsAPI.get( completion: { locationsResponse in
                    print ("\n**** CONTENT DONLOADED, opening storyboard ***\n")
                    sleep(1)
                    self.actInd.stopAnimating()
                    self.startButton.isHidden = false
               })
            }
        }
    }

    func requestLocAuthority(){
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
          case .notDetermined:
             locationManager.requestWhenInUseAuthorization()
          return
          case .denied, .restricted:
             let alert = UIAlertController(title: "Location Services are disabled", message: "Please enable Location Services in your Settings", preferredStyle: .alert)
             let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
             alert.addAction(okAction)
             present(alert, animated: true, completion: nil)
          return
          case .authorizedAlways, .authorizedWhenInUse:
          break
        @unknown default:
           debugPrint ("unknown")
        }
    }
    
    func showActivityIndicator() {
       actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
       actInd.center = self.view.center
       let transform: CGAffineTransform = CGAffineTransform(scaleX: 2, y: 2)
       actInd.transform = transform
       actInd.hidesWhenStopped = true
       actInd.style = UIActivityIndicatorView.Style.medium
       self.view.addSubview(actInd)
       actInd.startAnimating()
    }
    
    @IBAction func didPressStartButton(_ sender: UIButton) {
        Util.onboard(isOnboard: true)
        openLocStoryboard()
    }
    
    func openLocStoryboard(){
        let storyboard = UIStoryboard(name: "Loc", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LocViewController") as! LocViewController
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false, completion: nil)
    }
    
    func animateTitle(){
        titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat(0.2))  // rotation line
        UIView.animate(withDuration: 1.0, animations: {
            self.titleLabel.transform = CGAffineTransform(rotationAngle: 0);
        })
    }

}
