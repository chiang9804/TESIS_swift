//
//  EarthqiakeTableViewController.swift
//  TESIS.swift
//
//  Created by Rose-Air on 2015/1/12.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation

class EarthquakeTableViewController: UITableViewController, CLLocationManagerDelegate {

    var delegate = DownloadSessionDelegate.sharedInstance
    var fetchResults: Array<EarthquakeItem>? = nil
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateEQListView", name: NotificationKey_updateEQListView, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateEQListView:", name: NotificationKey_updateEQListView_p, object: nil)
//        downloadEQList()
        getEQItem()
//      if nil downloadEQList() else updateEQList, updateEQLocation
        if fetchResults == nil || fetchResults?.count == 0{
            downloadEQList()
        } else {
            updateEQListLocation()
            self.tableView.reloadData()
        }
        if fetchResults != nil && fetchResults?.count != 0{
            updateEQListLocation()
        }
//        downloadEQList()
        initLocationManager()
        
        
        println("EarthquakeTableViewController: viewDidLoad")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let settingBarButtonItem = UIBarButtonItem(image: UIImage(named: "image/settings3-25.png"), style: .Plain, target: self, action: "settingPressed")
        
        let datePickerBarButtonItem = UIBarButtonItem(image: UIImage(named: "image/calendar-25.png"), style: .Plain, target: self, action: "datePickerPressed")
        
        let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: nil)
        
        self.navigationItem.rightBarButtonItems = [settingBarButtonItem, datePickerBarButtonItem, refreshBarButtonItem]
    }
    
    func datePickerPressed(){
        let datePickerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("datePickerViewController") as! DatePickerViewController
        self.navigationController?.pushViewController(datePickerViewController, animated: true)
        
    }
    
    func settingPressed(){
        // TODO: segue to SettingTableViewController
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
    
    func updateEQListView(){
        //when Download finish
        //call update table view here.
        getEQItem()
        updateEQListLocation()
        self.tableView.reloadData()
    }
    
    func updateEQListView(notification: NSNotification){
        println("updateEQListView with EarthquakeItems")
//        let userInfo:Dictionary<String,[EarthquakeItem]!> = notification.userInfo as! Dictionary<String,[EarthquakeItem]!>
        getEQItem2()
        updateEQListLocation()
        self.tableView.reloadData()
        
    }
    
    func updateEQListLocation(){
//        var earthquakeList_new : [EarthquakeItem]? = nil
        if let earthquakeList:[EarthquakeItem] = fetchResults{
            for eq in earthquakeList{
            let eqLocation = CLLocation(latitude: (eq.lat as NSString).doubleValue, longitude: (eq.lng as NSString).doubleValue)
                if let currentLocation = previousCoord{
                    var distance = currentLocation.distanceFromLocation(eqLocation)
                    distance = distance / 1000
                    eq.distance = Int(distance)
                    let dx = eqLocation.coordinate.latitude - currentLocation.coordinate.latitude
                    let dy = eqLocation.coordinate.longitude - currentLocation.coordinate.longitude
                    println("eqLoc: \(eqLocation.coordinate.longitude) cirLoc: \(currentLocation.coordinate.longitude)")
                    println("dx:\(dx) dy:\(dy)")
                    println("theta = \(atan2(dy,dx))")
                    let degree = fmod(atan2(dy,dx)+2*M_PI, 2*M_PI)
                    println(degree*32/(2*M_PI))
                    switch degree*32/(2*M_PI) {
                    case 0...1, 31...32:
                        eq.distanceText = "東方"
                    case 1...3:
                        eq.distanceText = "東北東方"
                    case 5...7:
                        eq.distanceText = "北北東方"
                    case 7...9:
                        eq.distanceText = "北方"
                    case 9...11:
                        eq.distanceText = "北北西方"
                    case 11...13:
                        eq.distanceText = "西北方"
                    case 13...15:
                        eq.distanceText = "西北西方"
                    case 15...17:
                        eq.distanceText = "西方"
                    case 17...19:
                        eq.distanceText = "西南西方"
                    case 19...21:
                        eq.distanceText = "西南方"
                    case 21...23:
                        eq.distanceText = "南南西方"
                    case 23...25:
                        eq.distanceText = "南方"
                    case 26...27:
                        eq.distanceText = "南南東方"
                    case 27...29:
                        eq.distanceText = "東南方"
                    case 29...31:
                        eq.distanceText = "東南東方"
                    default:
                        eq.distanceText = " "
                    }
                    println(eq.distanceText)
                } else {
                    eq.distance = 0
                    eq.distanceText = "無法獲得位置資料"
                }
                
            }
        } else {
            println("update EQList location failed: fetchResults = nil")
        }
//        self.tableView.reloadData()
    }
    
    func getEQItem(){
        let fetchRequest = NSFetchRequest(entityName: "EarthquakeItem")
        let sortDescriptor = NSSortDescriptor(key: "no", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var err: NSError? = nil
        fetchResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &err) as? [EarthquakeItem]
        if err != nil {
            println("Error load data: \(err)")
        }
    }
    
    func getEQItem2(){
        let fetchRequest = NSFetchRequest(entityName: "EarthquakeItem2")
        let sortDescriptor = NSSortDescriptor(key: "no", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var err: NSError? = nil
        fetchResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &err) as? [EarthquakeItem]
        if err != nil {
            println("Error load data: \(err)")
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        println("fetchResults: \(fetchResults)")
        if fetchResults == nil || fetchResults?.count == 0{
            fetchResults = nil
            return 1
        } else {
            return fetchResults!.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        let mlLabel = cell.viewWithTag(100) as! UILabel
        let timeLabel = cell.viewWithTag(101) as! UILabel
        let distanceLabel = cell.viewWithTag(102) as! UILabel
        let locationLabel = cell.viewWithTag(103) as! UILabel
        let timezoneLabel = cell.viewWithTag(104) as! UILabel
        let indicator = cell.viewWithTag(105) as! UIActivityIndicatorView
        
        if fetchResults == nil {
//            mlLabel.text = "3.0"
//            timeLabel.text = "2014-09-29 , 19:16:28"
//            distanceLabel.text = "震央位於現在位置 南南東方79公里處"
//            locationLabel.text = "花蓮縣政府北偏東方 39.9 公里 (位於宜蘭縣近海)"
            mlLabel.hidden = true
            timeLabel.hidden = true
            distanceLabel.hidden = true
            locationLabel.hidden = true
            timezoneLabel.hidden = true
            indicator.hidden = false
            indicator.startAnimating()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.userInteractionEnabled = false
        } else {
            indicator.hidden = true
            mlLabel.hidden = false
            timeLabel.hidden = false
            distanceLabel.hidden = false
            locationLabel.hidden = false
            timezoneLabel.hidden = false
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            cell.userInteractionEnabled = true
            let eq = self.fetchResults?[indexPath.row] as EarthquakeItem!
            mlLabel.text = eq.ml
            timeLabel.text = "\(eq.date) , \(eq.time)"
            locationLabel.text = eq.location
            
            distanceLabel.text = "震央位於現在位置 \(eq.distanceText) \(eq.distance)公里處"
        }
        return cell
    }

    
    /* implement location update here */
    
    func initLocationManager() {
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            println("Location services are not enabled")
            //TODO: alert box info user to enable
        }
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location \(error.localizedDescription)")
    }
    
    var previousCoord: CLLocation? = nil;
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        println("did update location (lat, lng) = (\(coord.latitude),\(coord.longitude))")
        if previousCoord == nil {
            previousCoord = locationObj
            if fetchResults != nil && fetchResults?.count > 0{
                updateEQListLocation()
            }
        } else {
            let distance = previousCoord?.distanceFromLocation(locationObj)
            if distance > 1000 {
                previousCoord = locationObj
                if fetchResults != nil && fetchResults?.count > 0{
                    updateEQListLocation()
                }
            }
        }
        
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let selectedIndex = self.tableView.indexPathForSelectedRow() as NSIndexPath!
        let destinationVC = segue.destinationViewController as! EQViewController
        
        if fetchResults == nil{
            println("prepareForSegue: fetchResults is nil")
        } else {
            destinationVC.eq = self.fetchResults?[selectedIndex.row] as EarthquakeItem!
//            println("prepareForSegue: send eq \(destinationVC.eq) at row \(selectedIndex.row)")
        }
        
    }
    
    func downloadEQList() {
        let getIdURL = getEarthquakeIdLink() as String!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self.delegate, delegateQueue: nil)
        let url = NSURL(string: getIdURL)!
        println("url:\(url)")
        
        let dataTask = session.dataTaskWithURL(url,completionHandler: {data, response, error -> Void in
            println("get Id Task completed")
            if error != nil {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            let json = JSON(data:data)
            if json != nil {

                println("json count: \(json.count)")
                let firstId = json[0].stringValue
                let secondId = json[json.count-1].stringValue
                println("getId, from \(firstId) to \(secondId)")
                
                dispatch_async(dispatch_get_main_queue(), {
                    let getListURL = "http://tesis.earth.sinica.edu.tw/common/php/processdatamobile.php?firstid=\(firstId)&secondid=\(secondId)"
                    let configuration2 = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(SessionProperties.identifier)
                    let backgroundSession = NSURLSession(configuration: configuration2, delegate: self.delegate, delegateQueue: nil)
                    let url2 = NSURL(string: getListURL)!
                    println("url:\(url2)")
                    let downloadTask = backgroundSession.downloadTaskWithURL(url2)
                    downloadTask.resume()

                })

            } else { //if parse getId json error.
                println("getId failed")
            }
        })
        dataTask.resume()
        
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
