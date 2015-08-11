//
//  EQMapSwitchTableViewController.swift
//  TESIS.swift
//
//  Created by Rose-Pro on 2015/4/21.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EQMapSwitchTableViewController: UITableViewController {
    
    @IBOutlet weak var intensitySwitch: UISwitch!
    @IBOutlet weak var geoMapSwitch: UISwitch!
    @IBOutlet weak var faultSwitch: UISwitch!
    @IBOutlet weak var intersesmicSwitch: UISwitch!
    @IBOutlet weak var ballSwitch: UISwitch!
    @IBOutlet weak var satelliteSwitch: UISwitch!
    @IBOutlet weak var historicMapSwitch: UISwitch!
    
    @IBOutlet weak var intensitySegment: UISegmentedControl!
    @IBOutlet weak var ballSegment: UISegmentedControl!
    
    @IBOutlet var MapSwitchTableView: UITableView!
    override func viewDidLoad() {
        println("in MapSwitchTableView: viewDidLoad")
        let fetchRequest = NSFetchRequest(entityName: "MapViewSetting")
        var err: NSError? = nil
        let fetchResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &err) as? [MapViewSetting]
        println(fetchResults?.description)
        if fetchResults != nil{
            if let mapViewSetting = fetchResults!.first {
                intensitySwitch.setOn(mapViewSetting.intensitySwitch.boolValue, animated: false)
                geoMapSwitch.setOn(mapViewSetting.geoMapSwitch.boolValue, animated: false)
                faultSwitch.setOn(mapViewSetting.faultSwitch.boolValue, animated: false)
                intersesmicSwitch.setOn(mapViewSetting.intersesmicSwitch.boolValue, animated: false)
                ballSwitch.setOn(mapViewSetting.ballSwitch.boolValue, animated: false)
                satelliteSwitch.setOn(mapViewSetting.satelliteSwitch.boolValue, animated: false)
                historicMapSwitch.setOn(mapViewSetting.historicMapSwitch.boolValue, animated: false)
                intensitySegment.selectedSegmentIndex = mapViewSetting.intensityType.integerValue
                ballSegment.selectedSegmentIndex = mapViewSetting.ballType.integerValue
            }
        }
        super.viewDidLoad()

    }

    
    @IBAction func intensitySwitchChanged(sender: UISwitch) {
        if(sender.on){
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"intensity","action":"add","type":"\(intensitySegment.selectedSegmentIndex)"])
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"intensity","action":"remove"])
        }
    }
    @IBAction func intentsitySegmentChanged(sender: UISegmentedControl) {
        if(intensitySwitch.on){
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"intensity","action":"add","type":"\(intensitySegment.selectedSegmentIndex)"])
        }
    }
    
    @IBAction func geoMapSwitchChanged(sender: UISwitch) {
        if(sender.on){
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"geoMap","action":"add"])
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"geoMap","action":"remove"])
        }    }
    @IBAction func faultSwitchChanged(sender: UISwitch) {
        if(sender.on){
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"fault","action":"add"])
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"fault","action":"remove"])
        }
    }
    @IBAction func intersesmicSwitchChanged(sender: UISwitch) {
        if(sender.on){
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"intersesmic","action":"add"])
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"intersesmic","action":"remove"])
        }
    }
    @IBAction func ballSwitchChanged(sender: UISwitch) {
        if(sender.on){
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"ball","action":"add","type":"\(ballSegment.selectedSegmentIndex)"])
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"ball","action":"remove"])
        }
    }
    @IBAction func ballSegmentChanged(sender: UISegmentedControl) {
        if(ballSwitch.on){
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"ball","action":"add","type":"\(ballSegment.selectedSegmentIndex)"])
        }
        else{
            ballSwitch.setOn(true, animated: true)
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"ball","action":"add","type":"\(ballSegment.selectedSegmentIndex)"])
        }
    }
    @IBAction func satelliteSwitchChanged(sender: UISwitch) {
        if(sender.on){
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"satellite","action":"add"])
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"satellite","action":"remove"])
        }
    }
    @IBAction func historicMapSwitchChanged(sender: UISwitch) {
        if(sender.on){
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"historicMap","action":"add"])
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_changeMapOverlay, object: self, userInfo: ["overlay":"historicMap","action":"remove"])
        }
    }
   
    @IBAction func confirmBtnPressed(sender: UIButton) {
        //TODO: save setting state here
        saveSetting()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()
    
    func saveSetting(){
        let fetchRequest = NSFetchRequest(entityName: "MapViewSetting")
        var err: NSError? = nil
        let fetchResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &err) as? [MapViewSetting]
        if let fetchResult = fetchResults!.first{
            fetchResult.modify(intensitySwitch.on, geoMapSwitch: geoMapSwitch.on, faultSwitch: faultSwitch.on, intersesmicSwitch: intersesmicSwitch.on, ballSwitch: ballSwitch.on, satelliteSwitch: satelliteSwitch.on, historicMapSwitch: historicMapSwitch.on, ballType: ballSegment.selectedSegmentIndex, intensityType: intensitySegment.selectedSegmentIndex)
        } else {
            if let moc = self.managedObjectContext {
                
                MapViewSetting.createManagedObjectContext(moc, intensitySwitch: intensitySwitch.on, geoMapSwitch: geoMapSwitch.on, faultSwitch: faultSwitch.on, intersesmicSwitch: intersesmicSwitch.on, ballSwitch: ballSwitch.on, satelliteSwitch: satelliteSwitch.on, historicMapSwitch: historicMapSwitch.on, ballType: ballSegment.selectedSegmentIndex, intensityType: intensitySegment.selectedSegmentIndex)
            }
        }
        println(fetchResults?.description)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveContext()
        println("in MapSwitchTableView: save Setting")
    }

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 7
//    }
    
    
    
}
