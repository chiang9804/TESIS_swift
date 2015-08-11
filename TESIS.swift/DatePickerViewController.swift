//
//  DatePickerViewController.swift
//  TESIS.swift
//
//  Created by Rose-Pro on 2015/6/10.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DatePickerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Indicator.hidden = true
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let threeMonthAgo = calendar.dateByAddingUnit(.CalendarUnitMonth, value: -3, toDate: date, options: nil)!
        fromDatePicker.setDate(threeMonthAgo, animated: false)
    }
    
    lazy var managedObjectContext: NSManagedObjectContext! = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
    }()
    
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var ConfirmBtn: UIButton!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    @IBOutlet weak var Indicator: UIActivityIndicatorView!
    @IBAction func confirmBtnPressed(sender: UIButton) {
        // set UI
        fromDatePicker.hidden = true
        toDatePicker.hidden = true
        label.hidden = true
        label2.hidden = true
        ConfirmBtn.hidden = true
        Indicator.hidden = false
        Indicator.startAnimating()
        // set connection
        let fromDate = fromDatePicker.date
        let toDate = toDatePicker.date
        var url = NSURL(string: getEarthquakeIdLink(fromDate, toDate) as String!) as NSURL!
        var request: NSURLRequest = NSURLRequest(URL: url)
        let mainQueue = NSOperationQueue.mainQueue()
        // Download Earthquake Id
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: {(response, data, error) -> Void in
            if error == nil{
                let json = JSON(data:data)
                if json != nil{
                    let firstId = json[0].stringValue
                    let secondId = json[json.count-1].stringValue
                    println("getId, from \(firstId) to \(secondId)")
                    let getListURL = "http://tesis.earth.sinica.edu.tw/common/php/processdatamobile.php?firstid=\(firstId)&secondid=\(secondId)"
                    url = NSURL(string: getListURL)
                    request = NSURLRequest(URL: url)
                    // Download Earthquake List
                    NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: {(response, data, error) -> Void in
                        if error == nil{
                            dispatch_async(dispatch_get_main_queue(), {
                                // Back to UI thread
                                self.fromDatePicker.hidden = false
                                self.toDatePicker.hidden = false
                                self.label.hidden = false
                                self.label2.hidden = false
                                self.ConfirmBtn.hidden = false
                                self.Indicator.hidden = true
                                
                                let json = JSON(data:data)
                                println("eqrthquakes: \(json)")
                                
                                if json != nil{
                                if let moc = self.managedObjectContext{
                                    // delete old objects
                                    let fetchRequest = NSFetchRequest(entityName: "EarthquakeItem2")
                                    var err: NSError? = nil
                                    let fetchResults = moc.executeFetchRequest(fetchRequest, error: &err) as? [EarthquakeItem]
                                    if err != nil{
                                        println("Error load data: \(err)")
                                    } else if fetchResults != nil{
                                        for object in fetchResults!{
                                            moc.deleteObject(object)
                                        }
                                    }
                                    let earthquakeList = json["earthquakes"]
                                    println("EarthquakeList:\(earthquakeList[0])")
                                    println("EarthquakeList length:\(earthquakeList.count)")
                                    for i in 0...earthquakeList.count-1{
                                        EarthquakeItem.createManagedObjectContext2(moc, no: earthquakeList[i]["No"].stringValue, date: earthquakeList[i]["Date"].stringValue, time: earthquakeList[i]["Time"].stringValue, lat: earthquakeList[i]["Latitude"].stringValue, lng: earthquakeList[i]["Longitude"].stringValue, depth: earthquakeList[i]["depth"].stringValue, ml: earthquakeList[i]["ML"].stringValue, cwb_id: earthquakeList[i]["CWB_ID"].stringValue, map_pgv: earthquakeList[i]["pgvlink"].stringValue, map_pga: earthquakeList[i]["pgacontour1"].stringValue, location: earthquakeList[i]["Location"].stringValue, ball_gCap: earthquakeList[i]["gCAP"].stringValue, ball_BATS: earthquakeList[i]["BATS"].stringValue, ball_AutoBATS: earthquakeList[i]["New_BATS"].stringValue, ball_FMNEAR: earthquakeList[i]["FMNEAR"].stringValue, map_cwb: earthquakeList[i]["intensitymap"].stringValue, isNew: true)
                                    }
                                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                    appDelegate.saveContext()
                                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_updateEQListView_p, object: nil, userInfo: ["eqlist":"2"])
                                    
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                }
                                }
                            })
                        } else {
                            println("download \(url) error with code: \(error.localizedDescription)")
                            println("response: \(response)")
                        }
                    })

                } else {
                   println("getId failed")
                }
                
            } else {
                println(error.localizedDescription)
            }
        
        })
        
        
        
    }
}