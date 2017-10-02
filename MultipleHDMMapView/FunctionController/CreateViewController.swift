//
//  CreateViewController.swift
//  MultipleHDMMapView
//
//  Created by Tan Chung Shzen on 02.10.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var beaconIdField: UITextField!
    @IBOutlet var key1TextField: UITextField!
    @IBOutlet var key2TextField: UITextField!
    
    @IBOutlet weak var pickerBeacon: UIPickerView!
    
    @IBOutlet var nameValidationLabel: UILabel!
    @IBOutlet weak var key1Validation: UILabel!
    @IBOutlet weak var key2Validation: UILabel!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    let list = ["Bauhaus", "Küche", "B&B B", "Meetingraum Heidelberg", "Geo Dev" ,"Kicker" ,"Glashaus" ,"Matthi" ,"Eingang Entwicklung" ,"Tokio"]
    
    //    MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        setupView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated) // No need for semicolon
    }
    
    fileprivate func setupView() {
        nameValidationLabel.isHidden = true
        key1Validation.isHidden = true
        key2Validation.isHidden = true
        self.pickerBeacon.isHidden = true
    }
    
    //MARK: Button function
    
    @IBAction func submitForm(_ sender: Any) {
        var shape = "POLYGON"
        if(points?.count == 1) {shape = "Radial"}
        
        let geofence = putPlace.Geofence(shape: shape, points: points)
        let beacon = [putPlace.Beacons(id: getBeaconId(beaconName: beaconIdField.text!))]
        let attributes = putPlace.Attributes(key1: key1TextField.text, key2: key2TextField.text)
        
        let updates = putPlace(name: nameTextField.text, geofence: geofence, beacons: beacon, attributes: attributes)
        
        let data = DataHandler()
        data.updatePlace(updates,url)
        
        //after sending data, set points to nil
        points = nil
        
        let naviController = UIStoryboard(name: "Main" , bundle: nil).instantiateViewController(withIdentifier: "DeleteListTableViewController") as? GeofenceController
        
        self.navigationController?.pushViewController(naviController!, animated: true)
    }
}

//MARK: Other functions
extension UpdateViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            key1TextField.becomeFirstResponder()
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
        
        return (true, "")
    }
}

extension CreateViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        self.view.endEditing(true)
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.beaconIdField.text = self.list[row]
        self.pickerBeacon.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.beaconIdField{
            self.pickerBeacon.isHidden = false
            
            textField.endEditing(true)
        }
    }
    
    func getBeaconId (beaconName: String) -> (String) {
        
        var beaconId : String?
        
        switch beaconName {
        case "Bauhaus":
            beaconId = "5BA5149904694C61B7E048A33761CFFF"
        case "Küche":
            beaconId = "6862263E3D8046E188A05FDB26BE7264"
        case "B&B B":
            beaconId = "92F96CFDF6034AD580FEBEDBF3E09852"
        case "Meetingraum Heidelberg":
            beaconId = "89F2D6B3338240C1AE42F1BEC2CE544C"
        case "Geo Dev":
            beaconId = "5D71868A35174FD985801E0AD1358A13"
        case "Kicker":
            beaconId = "65C8711F83B7491E98B6839C600F2B3C"
        case "Glashaus":
            beaconId = "357DBCFD80D24DF0AAE6C9D1D4B3DC37"
        case "Matthi":
            beaconId = "559A5BCA9E28442B9CF2D52E96A5EAD3"
        case "Eingang Entwicklung":
            beaconId = "6B1C7DD8A68C46D889C4FB860DAE7F8C"
        case "Tokio":
            beaconId = "06470462D6B74DBC8CDAF18D341ECE9F"
        default:
            beaconId = ""
        }
        
        return beaconId!
    }
}