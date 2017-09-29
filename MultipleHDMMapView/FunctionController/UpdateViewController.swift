//
//  UpdateViewController.swift
//  MultipleHDMMapView
//
//  Created by Tan Chung Shzen on 27.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController {
    
    //    MARK: Properties
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var beaconIdField: UITextField!
    @IBOutlet var key1TextField: UITextField!
    @IBOutlet var key2TextField: UITextField!
    
    @IBOutlet var beaconIdValidationLabel: UILabel!

    @IBOutlet weak var editGeofenceBtn: UIButton!
    
    @IBOutlet weak var updateBtn: UIButton!
    
    var name: String = ""
    var key1: String = ""
    var key2: String = ""
    var url: String = ""
    var points : [putPlace.Geofence.Points]? = nil
  
    //    MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !name.isEmpty{
            nameTextField.text = name
        }
        if !key1.isEmpty{
            key1TextField.text = key1
        }
        if !key2.isEmpty{
            key2TextField.text = key2
        }
        
        beaconIdField.autocapitalizationType = .allCharacters
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !(points == nil) {
            loadStates()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated) // No need for semicolon
        points = nil
    }
    
    fileprivate func setupView() {
        beaconIdValidationLabel.isHidden = true
    }
    
//    func numberOnly(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
//    {
//        let allowedCharacters = CharacterSet.decimalDigits
//        let characterSet = CharacterSet(charactersIn: string)
//        return allowedCharacters.isSuperset(of: characterSet)
//    }
    

    //MARK: Button functions
    @IBAction func editGeofence(_ sender: UIButton) {
        
        //Save the state while user navigate to another view
        saveStates()
        
        //sender to MainViewController
//        let data = ["url" : url]
//
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateGeofence"), object: nil, userInfo: data)
        
        //Navigate to MainViewController
        let naviController = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
        
        naviController?.url = url
        
        self.navigationController?.pushViewController(naviController!, animated: true)
    }
    
    @IBAction func updateForm(_ sender: Any) {
        var shape = "POLYGON"
        if(points?.count == 1) {shape = "Radial"}
        
        let geofence = putPlace.Geofence(shape: shape, points: points)
        let beacon = [putPlace.Beacons(id: beaconIdField.text)]
        let attributes = putPlace.Attributes(key1: key1TextField.text, key2: key2TextField.text)
        
        let updates = putPlace(name: nameTextField.text, geofence: geofence, beacons: beacon, attributes: attributes)
        
        let data = DataHandler()
        data.updatePlace(updates,url)
        
        //after sending data, set points to nil
        points = nil
        
        let naviController = UIStoryboard(name: "Main" , bundle: nil).instantiateViewController(withIdentifier: "DeleteListTableViewController") as? DeleteListTableViewController
        
        self.navigationController?.pushViewController(naviController!, animated: true)
    }
}

//MARK: Other functions
extension UpdateViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            beaconIdField.becomeFirstResponder()
        case beaconIdField:
            // Validate Text Field
            let (valid, message) = validate(textField)
            print(valid)
            if valid {
                key1TextField.becomeFirstResponder()
            }
            
            // Update Password Validation Label
            self.beaconIdValidationLabel.text = message
            
            // Show/Hide Password Validation Label
            UIView.animate(withDuration: 0.25, animations: {
                self.beaconIdValidationLabel.isHidden = valid
            })
        case key1TextField:
            key2TextField.becomeFirstResponder()
        default:
            key2TextField.resignFirstResponder()
        }
        
        return true
    }
    
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        //Validation for beacon ID Textfield
        if textField == beaconIdField {
            var shortOf = 32 - text.characters.count
            
            if (shortOf == 0) {
                return (true, "")
            } else if (shortOf < 0){
                return (false, "Your beacon ID is \(-shortOf) extra value.")
            } else if (shortOf < 32){
                return (false, "Your beacon ID have \(shortOf) short.")
            }
        }
        
        return (text.characters.count == 32 || text.characters.count == 0, "")
    }
    
    func saveStates(){
        let defaults = UserDefaults.standard
        
        defaults.set(nameTextField.text, forKey: "nameTextField")
        defaults.set(key1TextField.text, forKey: "key1TextField")
        defaults.set(key2TextField.text, forKey: "key2TextField")
        defaults.synchronize()
    }
    
    func loadStates(){
        let defaults = UserDefaults.standard
        nameTextField.text = defaults.object(forKey: "nameTextField") as? String
        key1TextField.text = defaults.object(forKey: "key1TextField") as? String
        key2TextField.text = defaults.object(forKey: "key2TextField") as? String
    }
}
