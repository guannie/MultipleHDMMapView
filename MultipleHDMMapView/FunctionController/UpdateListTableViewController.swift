//
//  UpdateListTableViewController.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 22.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import HDMMapCore

class UpdateListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var tableArray = [String] ()
    var urlArray = [String] ()

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = self.tableArray[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let name = self.tableArray[indexPath.row]
        
        let alertController = UIAlertController(title: "Delete Geofence", message: "Are you sure you want to remove \(name)?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            
            let data = DataHandler()
            data.deletePlace(self.urlArray[indexPath.row], (self.tableArray[indexPath.row]))
            
            self.tableArray.remove(at: indexPath.row)
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
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let testdata = DataHandler()
        testdata.testCoordinates(){
            (place) in
            
            self.tableArray.append((place?.place.name)!)
            self.urlArray.append((place?.place.url)!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
