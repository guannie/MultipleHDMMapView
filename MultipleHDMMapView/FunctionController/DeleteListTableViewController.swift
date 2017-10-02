//
//  DeleteListTableViewController.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 22.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import HDMMapCore

class DeleteListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func cancel(_ sender: Any) {
        let naviController = UIStoryboard(name: "Main" , bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
        
        self.navigationController?.pushViewController(naviController!, animated: true)
    }
    
    var nameArray = [String] ()
    var key1Array = [String] ()
    var key2Array = [String] ()
    var urlArray = [String] ()
    
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
            naviController?.key1 = self.key1Array[indexPath.row]
            naviController?.key2 = self.key2Array[indexPath.row]
            
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
 
        /*
        let alert = UIAlertController(title: "Present Controller B", message: "Do you want to preset controller B?", preferredStyle: .alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) -> Void in
            
            alert.dismiss(animated: true, completion: nil)
            
            let controllerB = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateViewController") as? UpdateViewController
            
            self.navigationController?.pushViewController(controllerB!, animated: true)
            
        })
        
        alert.addAction(defaultAction)
        
        self.present(alert, animated: true, completion: nil)
 */
        
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
            self.key1Array.append((place?.place.attributes?.key1) ?? "")
            self.key2Array.append((place?.place.attributes?.key2) ?? "")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

