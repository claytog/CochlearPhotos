//
//  MainViewController.swift
//  CochlearPhotos
//
//  Created by Clayton on 29/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat(0.2))  // rotation line

        UIView.animate(withDuration: 1.0, animations: {
            self.titleLabel.transform = CGAffineTransform(rotationAngle: 0);
        })
        
    }
       
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if Util.isOnboard(){
            startButton.isHidden = true
        }else{
            closeButton.isHidden = true
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       
        if !Util.isOnboard(){
            if DBManager.shared.openOrCopyDatabase() { // initialise a singleton instance of the database
                showActivityIndicator()
                LocationsAPI.get( completion: { locationsResponse in
                    print ("\n**** CONTENT DONLOADED, opening storyboard ***\n")
                    sleep(1)
                    self.actInd.stopAnimating()
                    self.openStoryboard()
                })
            }
        }
    }
       
    func openStoryboard(){
       if Util.isOnboard(){
           openLocStoryboard()
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
    
    @IBAction func didPressCloseButton(_ sender: UIButton) {
        openLocStoryboard()
    }
    
    @IBAction func didPressStartButton(_ sender: UIButton) {
        Util.onboard(isOnboard: true)
        openLocStoryboard()
    }
    
    func openLocStoryboard(){
        let storyboard = UIStoryboard(name: "Loc", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LocViewController") as! LocViewController
        controller.modalPresentationStyle = .fullScreen
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false, completion: nil)
    }

}
