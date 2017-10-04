//
//  GeofenceController.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 22.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import HDMMapCore

class GeofenceController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var nameArray = [String] ()
    var beaconIdArray = [String] ()
    var urlArray = [String] ()
    
    @IBAction func cancel(_ sender: Any) {
        let naviController = UIStoryboard(name: "Main" , bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
        
        self.navigationController?.pushViewController(naviController!, animated: true)
    }
    
    @IBAction func addBtn(_ sender: UIBarButtonItem) {
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = self.nameArray[indexPath.row]
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let name = self.nameArray[indexPath.row]
        
        
        let alertController = UIAlertController(title: "Manage Geofence", message: "Do you wish to Update or Delete \(name)?", preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler: {(action) -> Void in
            
            //alertController.dismiss(animated: true, completion: nil)
            
            let naviController = UIStoryboard(name: "Main" , bundle: nil).instantiateViewController(withIdentifier: "UpdateViewController") as? UpdateViewController
            
            naviController?.name = self.nameArray[indexPath.row]
            naviController?.url = self.urlArray[indexPath.row]
            naviController?.beaconId = self.beaconIdArray[indexPath.row]
            
            self.navigationController?.pushViewController(naviController!, animated: true)
        })
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            
            let data = DataHandler()
            data.deletePlace(self.urlArray[indexPath.row], (self.nameArray[indexPath.row]))
            
            self.nameArray.remove(at: indexPath.row)
            self.urlArray.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(updateAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteGeofence(_ sender: UIButton) {
     
     
        let point = tableView.convert(CGPoint.zero, from: sender)
        if let indexPath = tableView.indexPathForRow(at: point) {
                let name = self.nameArray[indexPath.row]
     
                let alertController = UIAlertController(title: "Delete Geofence", message: "Are you sure you want to remove \(name)?", preferredStyle: .alert)
     
                let confirmAction = UIAlertAction(title: "Yes", style: .default) { (_) in
     
                    let data = DataHandler()
                    data.deletePlace(self.urlArray[indexPath.row], (self.nameArray[indexPath.row]))
     
                    self.nameArray.remove(at: indexPath.row)
                    self.urlArray.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                let cancelAction = UIAlertAction(title: "No", style: .cancel) { (_) in }
     
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
     
                self.present(alertController, animated: true, completion: nil)
     
            }
     
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let testdata = DataHandler()
        testdata.testCoordinates(){
            (place) in
            
            self.nameArray.append((place?.place.name)!)
            self.urlArray.append((place?.place.url)!)
 
            if !((place?.place.beacons?.isEmpty)!){
            for beacon in (place?.place.beacons)! {
                        self.beaconIdArray.append(beacon.name!)
                }
            } else {
                self.beaconIdArray.append("")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}

