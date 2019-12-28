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
    @IBOutlet weak var locNameHeightConstraint: NSLayoutConstraint!
    
    var selectedLocation: Location!
    
    var isNew: Bool!
    var isDefault: Bool!
    var keyboardShowing: Bool! = false
    var nameHeight: CGFloat!
    var origTextViewColr: UIColor!
    var placeholderTextColr = UIColor.gray
    let placeholderTextViewText = "Add notes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNameTextField()
        setupNotesTextView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adjustViewSize()
    }
    
    func setupView(){
        
        self.title = "Location"
        nameHeight = locNameHeightConstraint.constant
        isNew = selectedLocation.name == nil
        isEditing = isNew
        isDefault = selectedLocation.locType == LocType.deflt.rawValue
        
        locNotesTextView.delegate = self
        origTextViewColr = locNotesTextView.textColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(LocDetailViewController.keyboardWillDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification,object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue

            adjustViewSize(forKeyboard: keyboardRectangle.height)
            keyboardShowing = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            adjustViewSize(forKeyboard: -keyboardRectangle.height)
            keyboardShowing = false
        }
    }
    
    @objc func keyboardWillDisappear(_: NSNotification){
        // save the reflection

        if !isDefault {
            selectedLocation.name = locNameTextField.text
        }
        if locNotesTextView.text.isEmpty {
            locNotesTextView.text = placeholderTextViewText
            locNotesTextView.textColor = placeholderTextColr
        }else{
            selectedLocation.notes = locNotesTextView.text
        }
        if isNew {
            if !selectedLocation.name.isEmpty {
                Location.insertLocation(location: selectedLocation)
            }
        }else{
            Location.updateLocation(location: selectedLocation)
        }
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
           
           adjustViewSize()
    }
    
    func adjustViewSize(forKeyboard: CGFloat = 0){
        var heightToChange:CGFloat = 0
        if keyboardShowing {
            heightToChange = self.locNotesTextView.frame.height
        }else{
            heightToChange = self.view.frame.height - nameHeight - (forKeyboard+120)
            if heightToChange < nameHeight {
                heightToChange = nameHeight
            }
        }
        locNotesHeightConstraint.constant = heightToChange
    }
  
    
    @IBAction func didTapNameTextField(_ sender: UITapGestureRecognizer) {
        isEditing = true
        setupNameTextField()
    }
    
    @IBAction func didTapNotesTextView(_ sender: UITapGestureRecognizer) {
        isEditing = true
        setupNotesTextView()
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
                locNameTextField.becomeFirstResponder()
                
            }
        }
    }

}

extension LocDetailViewController : UITextViewDelegate {
    
    func setupNotesTextView(){
        
        locNotesTextView.text = selectedLocation.notes
        if isEditing {
            locNameTextField.isUserInteractionEnabled = true
            locNotesTextView.layer.borderWidth = 1
            locNotesTextView.layer.borderColor = UIColor.black.cgColor
            locNotesTextView.isEditable = true
            locNotesTextView.becomeFirstResponder()
        }else{
            locNotesTextView.backgroundColor = UIColor.systemGroupedBackground
            locNotesTextView.isEditable = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeholderTextColr {
            textView.text = nil
            textView.textColor = origTextViewColr
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderTextViewText
            textView.textColor = placeholderTextColr
        }
    }
    
}
