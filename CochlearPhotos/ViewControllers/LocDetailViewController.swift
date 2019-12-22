//
//  LocDetailViewController.swift
//  CochlearPhotos
//
//  Created by Clayton on 22/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import UIKit

class LocDetailViewController: UIViewController {

    @IBOutlet weak var locNameTextField: UITextField!
    @IBOutlet weak var locNotesTextView: UITextView!
    @IBOutlet weak var locNotesHeightConstraint: NSLayoutConstraint!
    
    var selectedLocation: Location!
    
    var keyboardHeight : CGFloat = 0
    var isDefault: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNameTextField()
        setupNotesTextView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        isEditing = selectedLocation.name != nil

        self.title = "Location"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adjustViewSize(forKeyboard: false)
        
    }
    
    func setupView(){
        
        isDefault = selectedLocation.locType == LocType.deflt.rawValue
        
        NotificationCenter.default.addObserver(self, selector: #selector(LocDetailViewController.keyboardWillDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification,object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            
            adjustViewSize(forKeyboard: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            
            adjustViewSize(forKeyboard: false)
        }
    }
    
    @objc func keyboardWillDisappear(_: NSNotification){
        // save the reflection

        selectedLocation.notes = locNotesTextView.text
        
        Location.updateLocation(location: selectedLocation)
            
            
        
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
           
           adjustViewSize(forKeyboard: false)
    }
    
    func adjustViewSize(forKeyboard: Bool){
        
        let heightToChange = self.locNotesTextView.frame.height - (forKeyboard ? keyboardHeight : 0)
        locNotesHeightConstraint.constant = heightToChange
        locNotesTextView.isScrollEnabled = true
    }
  
    
    @IBAction func didTapNotesTextView(_ sender: UITapGestureRecognizer) {
        
        isEditing = true
        setupNotesTextView()
        
    }
    
    @IBAction func didTapNameTextField(_ sender: UITapGestureRecognizer) {
        
        isEditing = true
        setupNameTextField()
    }
    
}

extension LocDetailViewController : UITextFieldDelegate {

    func setupNameTextField(){
        
        locNameTextField.text = selectedLocation.name
        
        if isDefault {
            locNameTextField.isUserInteractionEnabled = false
            locNameTextField.backgroundColor = UIColor.systemGroupedBackground;
        }else{
            if isEditing {
                
                locNameTextField.delegate = self
                locNameTextField.isUserInteractionEnabled = true
                locNameTextField.backgroundColor = UIColor.white;
                locNameTextField.layer.borderWidth = 1
                locNameTextField.layer.borderColor = UIColor.black.cgColor
                if locNameTextField.text == "" {
                    locNameTextField.becomeFirstResponder()
                }
            }else{
                
            }
        }
        
    }

}

extension LocDetailViewController : UITextViewDelegate {
    
    func setupNotesTextView(){
        
        locNotesTextView.text = selectedLocation.notes
        if isEditing {
            locNotesTextView.delegate = self
            locNameTextField.isUserInteractionEnabled = true
            locNotesTextView.layer.borderWidth = 1
            locNotesTextView.layer.borderColor = UIColor.black.cgColor
            locNotesTextView.isEditable = true
            if locNameTextField.text != "" {
                locNotesTextView.becomeFirstResponder()
            }
        }else{
            locNotesTextView.backgroundColor = UIColor.systemGroupedBackground
            locNotesTextView.isEditable = false
        }
    }
    
}
