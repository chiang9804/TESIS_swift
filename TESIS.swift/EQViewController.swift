//
//  EQViewController.swift
//  TESIS.swift
//
//  Created by IES on 3/12/15.
//  Copyright (c) 2015 Rose-Air. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class EQViewController: UIViewController, MKMapViewDelegate {

    var viewFlag = Flag_HalfEQ
    var eq : EarthquakeItem!
    let template = "http://tesis.earth.sinica.edu.tw/testimage/imageAll/{x}-{y}-{z}.png"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: nil)
        
        self.navigationItem.rightBarButtonItem =  refreshBarButtonItem
        
        self.title = "地震資訊"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeMapOverlay:", name: NotificationKey_changeMapOverlay, object: nil)
       
        initializeLayout()
        makeHalfEQLayout()
        self.annotationBar.hidden = true
        self.historicMapBar.hidden = true
        // init map button view
        
        
        initMapView() // set location
        loadAnnotation() // set annotation
        loadGeoMapTileOverlay() // set tileOverlay
        loadSeisMapTileOverlay()
        loadFault()
        loadInterseismicDeformation()
        loadVolleyball()
        loadIntensityMap()
    
        mapView.addAnnotation(myAnnotation)
        loadPreviousSetting()
//        mapView.addOverlay(geoMapTileOverlay, level: MKOverlayLevel.AboveLabels)
//        mapView.addOverlay(seisMapTileOverlay, level: MKOverlayLevel.AboveLabels)
//        mapView.addOverlays(polylines)
//        mapView.addAnnotations(faultAnnotations)
//        mapView.addOverlays(vectors, level: MKOverlayLevel.AboveLabels)

    }
    
    
    
    // Mark: load Map data
    var location: CLLocationCoordinate2D!
    var myAnnotation: MyPointAnnotation!
    var geoMapTileOverlay: GeoMapTileOverlay!
    var seisMapTileOverlay: SeisMapTileOverlay!
    
    @IBOutlet weak var annotationBar: UIImageView!
    @IBOutlet weak var historicMapBar: UIImageView!
    // initial data setting
    func initMapView(){
        mapView.delegate = self
        self.location = CLLocationCoordinate2D(latitude: (NSString(string: eq.lat)).doubleValue, longitude: (NSString(string: eq.lng)).doubleValue)
        let span = MKCoordinateSpanMake(1, 1)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        

    }
    

    func loadAnnotation(){
        /// TODO: add image to annotation
        self.myAnnotation = MyPointAnnotation()
        myAnnotation.coordinate = location
        myAnnotation.title = "\(eq.date) \(eq.time) Taipei time"
        myAnnotation.subtitle = "ML \(eq.ml) \n\(eq.location)"
        var depth = Int((NSString(string: eq.depth)).doubleValue)
        switch depth {
        case 0...15: depth = 15
        case 16...30: depth = 30
        case 31...70: depth = 70
        case 71...150: depth = 150
        case 151...300: depth = 300
        default: depth = 300
        }
        var ml = Int(NSString(string: eq.ml).doubleValue)
        myAnnotation.imageName = "image/archeive_new/icon_event\(depth)_\(ml).png"
        
        self.volleyballAnnotation = MyVolleyballAnnotation()
        volleyballAnnotation.coordinate = location
        
        self.intensityMapAnnotation = IntensityMapAnnotation()
        volleyballAnnotation.coordinate = location
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        //        println("mapView: renderForOverlay")
        if overlay is MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: overlay as! MKTileOverlay)
        }
        if overlay is FaultPolylineOverlay {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            var polyline = overlay as! FaultPolylineOverlay
            if polyline.color != nil{
                polylineRenderer.strokeColor = polyline.color!
            } else {
                polylineRenderer.strokeColor = UIColor.orangeColor()
            }
            if polyline.stroke != nil {
                polylineRenderer.lineWidth = polyline.stroke!
            } else {
                polylineRenderer.lineWidth = 3
            }
            return polylineRenderer
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MyPointAnnotation{
            let reuseId = "faultAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                annotationView.canShowCallout = true
            } else {
                annotationView.annotation = annotation
            }
            let tmpAnnotation = annotation as! MyPointAnnotation
            annotationView.image = UIImage(named: tmpAnnotation.imageName)
            return annotationView
        } else if annotation is MyVolleyballAnnotation{
            var annotationView = MKAnnotationView()
            annotationView.annotation = annotation
            let tmpAnnotation = annotation as! MyVolleyballAnnotation
            annotationView.image = tmpAnnotation.image
            return annotationView
        } else if annotation is IntensityMapAnnotation{
            var annotationView = IntensityMapAnnotationView()
            annotationView.zoomLevel = mapView.region.span
            annotationView.annotation = annotation
            let tmpAnnotation = annotation as! IntensityMapAnnotation
            println("***===***zoomlevel\(annotationView.zoomLevel.latitudeDelta)")
            let rect = CGRectMake(0, 0, tmpAnnotation.image.size.width/4, tmpAnnotation.image.size.height/4)
            annotationView.image = tmpAnnotation.image
            annotationView.image.drawInRect(rect)
            return annotationView
        }
        return nil
    }
    
    func loadGeoMapTileOverlay(){
        geoMapTileOverlay = GeoMapTileOverlay()
        //        let tileOverlay = MKTileOverlay(URLTemplate: template)
        //        tileOverlay.canReplaceMapContent = true
        
    }
    
    func loadSeisMapTileOverlay(){
        seisMapTileOverlay = SeisMapTileOverlay()
        //        let tileOverlay = MKTileOverlay(URLTemplate: template)
        //        tileOverlay.canReplaceMapContent = true
        
    }
    
    struct Point {
        var index: Int
        var group_index: Int
        var Latlng: CLLocationCoordinate2D;
        func toString()-> String{
            return "\(index) in \(group_index) latLng(\(Latlng.latitude),\(Latlng.longitude))"
        }
    }
    
    var points = [Point]()
    var polylines = [FaultPolylineOverlay]()
    var faultAnnotations = [MyPointAnnotation]()

    func loadFault(){
        let path = NSBundle.mainBundle().pathForResource("fault2014_convert_2", ofType: "txt")
//        println("Fault path: \(path)")
        let content = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        if content == nil {
            println("cannot read fault data")
        } else {
//            var arrayOfLines = split(String(content!)){$0 == "\n"} as [String]
            var arrayOfLines = String(content!).componentsSeparatedByString("\n")
            var id = 0
            var gId = 0
            for i in 0..<arrayOfLines.count {
                if !arrayOfLines[i].isEmpty {
                    var tmp = arrayOfLines[i][arrayOfLines[i].startIndex]
                    var bool = tmp == "X"
//                    print("\(arrayOfLines[i]) == X? \(bool)")
                    if bool{
                        gId++
                    } else {
                        var arrayOfLatlng = split(String(arrayOfLines[i])){$0 == " "} as [String]
                        points.append(Point(index: id, group_index: gId-1, Latlng: CLLocationCoordinate2D(latitude: NSString(string: arrayOfLatlng[0]).doubleValue , longitude: NSString(string: arrayOfLatlng[1]).doubleValue)))
//                        println(points[id].toString())
                        id++
                    }
                }
            }
            let scale = 20
            //set annotation
            for i in 0..<points.count{
                if i % scale == 0{
                    var annotation = MyPointAnnotation()
                    switch (lineColor[points[i].group_index]){
                    case 0,5: annotation.imageName = "image/small_red_5.png"
                    case 3,4: annotation.imageName = "image/small_black_5.png"
                    case 1,2: annotation.imageName = "image/small_orange_5.png"
                    default: break
                    }
                    annotation.coordinate = points[i].Latlng
                    annotation.title = lineName[points[i].group_index]
                    faultAnnotations.append(annotation)
                }
            }
            
            //set polyline
//            println("gId:\(gId), id:\(id)")
            for i in 0...(gId-1){
                var tmp_points = points.filter({$0.group_index == i})
                var coordinates = tmp_points.map({$0.Latlng})
                var polyline = FaultPolylineOverlay(coordinates: &coordinates, count: coordinates.count)
                switch (lineColor[i]){
                case 0,5: polyline.color = UIColor.redColor()
                case 3,4: polyline.color = UIColor.blackColor()
                case 1,2: polyline.color = UIColor.orangeColor()
                default: break
                }
                polylines.append(polyline)
                
            }
//            self.mapView.addOverlays(polylines)
        }
    }
    
    var vectors = [FaultPolylineOverlay]()
    
    func loadInterseismicDeformation(){
        let path = NSBundle.mainBundle().pathForResource("S01R_2007.S0.5_2", ofType: nil)
//        println("Interseismic Deformation path: \(path)")
        let content = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        if content == nil {
            println("cannot read interseismic deformation data")
        } else {
            var arrayOfLines = String(content!).componentsSeparatedByString("\n")
            for i in 0...arrayOfLines.count-1 {
                if !arrayOfLines[i].isEmpty {
                    var arrayOfLatlngs = split(String(arrayOfLines[i])){$0 == " "} as [String]
//                    println(arrayOfLatlngs[0...7])
                    var coordinate1 = [CLLocationCoordinate2D(latitude: NSString(string: arrayOfLatlngs[1]).doubleValue , longitude: NSString(string: arrayOfLatlngs[0]).doubleValue),CLLocationCoordinate2D(latitude: NSString(string: arrayOfLatlngs[3]).doubleValue , longitude: NSString(string: arrayOfLatlngs[2]).doubleValue)]
                    var coordinate2 = [CLLocationCoordinate2D(latitude: NSString(string: arrayOfLatlngs[5]).doubleValue , longitude: NSString(string: arrayOfLatlngs[4]).doubleValue),CLLocationCoordinate2D(latitude: NSString(string: arrayOfLatlngs[3]).doubleValue , longitude: NSString(string: arrayOfLatlngs[2]).doubleValue),CLLocationCoordinate2D(latitude: NSString(string: arrayOfLatlngs[7]).doubleValue , longitude: NSString(string: arrayOfLatlngs[6]).doubleValue)]
//                    println(coordinate1)
//                    println(coordinate2)
                    var polyline1 = FaultPolylineOverlay(coordinates: &coordinate1, count: coordinate1.count)
                    var polyline2 = FaultPolylineOverlay(coordinates: &coordinate2, count: coordinate2.count)
                    polyline1.color = UIColor.redColor()
                    polyline2.color = UIColor.redColor()
                    polyline1.stroke = 1.5
                    polyline2.stroke = 1.5
                    vectors.append(polyline1)
                    vectors.append(polyline2)
                }
            }
            
        }
    }
    
    var imageCache = [String:UIImage]()
    var downloadState = [String:String]()
    let downloadState_downloading = "downloading"
    let downloadState_fileNotExist = "file_not_exist"
    let downloadState_lostConnection = "lost_connection"
    let downloadState_finished = "finished"
    var volleyballAnnotation : MyVolleyballAnnotation!
    var intensityMapAnnotation: IntensityMapAnnotation!
    
    func loadVolleyball(){
        println("volleyball URLs:\n\(eq.ball_gCap)\n\(eq.ball_BATS)\n\(eq.ball_AutoBATS)\n\(eq.ball_FMNEAR)\n==============")
        self.imageCache[eq.ball_gCap] = loadImageFromURL(eq.ball_gCap)
        self.imageCache[eq.ball_BATS] = loadImageFromURL(eq.ball_BATS)
        self.imageCache[eq.ball_AutoBATS] = loadImageFromURL(eq.ball_AutoBATS)
        self.imageCache[eq.ball_FMNEAR] = loadImageFromURL(eq.ball_FMNEAR)
    }
    
    func loadIntensityMap(){
        println("IntensityMap URLs:\n\(eq.map_cwb)\n\(eq.map_pga)\n\(eq.map_pgv)\n==============")
        self.imageCache[eq.map_cwb] = loadImageFromURL(eq.map_cwb)
        self.imageCache[eq.map_pga] = loadImageFromURL(eq.map_pga)
        self.imageCache[eq.map_pgv] = loadImageFromURL(eq.map_pgv)
    }
    
    func loadImageFromURL(urlString:String!)-> UIImage?{
        if let img = imageCache[urlString]{
            return img
        } else {
            // TODO check download State
            if downloadState[urlString] == downloadState_downloading {
                //TODO make Toast
            } else {
                downloadImage(urlString)
            }
        }
        return nil
    }
    
    func downloadImage(urlString:String!){
        downloadState[urlString] = downloadState_downloading
        println("downloadImage: \(urlString)")
        if let imgURL = NSURL(string: urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!){
            let request = NSURLRequest(URL: imgURL)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: {(response, data, error) -> Void in
                if error == nil{
                    let image = UIImage(data: data)
                    self.imageCache[urlString] = image
                    self.downloadState[urlString] = self.downloadState_finished
                    dispatch_async(dispatch_get_main_queue(), {
                        // TODO: add image to main thread here
                        // if should show image
                        println("finish download \(urlString)")
                        self.tryAddImage()
                    })
                } else {
                    // TODO: check error type
                    self.imageCache[urlString] = nil
                    self.downloadState[urlString] = self.downloadState_fileNotExist
                    println("download \(urlString) error with code: \(error.localizedDescription)")
                    println("response: \(response)")
                }
            })
        } else {
            self.imageCache[urlString] = nil
            self.downloadState[urlString] = self.downloadState_fileNotExist
            println("downloadImage: url failed")
        }
    
    }
    
    func tryAddImage(){
        println("tryAddImage: intensity(\(intensitySwitch),\(intensityType)) , ball(\(ballSwitch),\(ballType))")
        if intensitySwitch{
            mapView.removeAnnotation(intensityMapAnnotation)
            switch intensityType {
            case 0:if self.imageCache[eq.map_cwb] != nil{
                intensityMapAnnotation = IntensityMapAnnotation()
                intensityMapAnnotation.coordinate = CLLocationCoordinate2DMake((26.45+19.7)/2, (123.2+118.28)/2)
                intensityMapAnnotation.image = self.imageCache[eq.map_cwb]
                mapView.addAnnotation(intensityMapAnnotation)
                }
            case 1:if self.imageCache[eq.map_pga] != nil{
                
                }
            case 2:if self.imageCache[eq.map_pgv] != nil{
                
                }
            default:
                println("Unidentified intensity map type")
            }
        }
        if ballSwitch{
            mapView.removeAnnotation(volleyballAnnotation)
            switch ballType {
            case 0:if self.imageCache[eq.ball_gCap] != nil{
                volleyballAnnotation = MyVolleyballAnnotation()
                volleyballAnnotation.coordinate = location
                volleyballAnnotation.image = self.imageCache[eq.ball_gCap]
                mapView.addAnnotation(volleyballAnnotation)
            } else if self.downloadState[eq.ball_gCap] == self.downloadState_fileNotExist{
                println("file not exist")
                //TODO toast
            }
            case 1:if self.imageCache[eq.ball_BATS] != nil{
                volleyballAnnotation = MyVolleyballAnnotation()
                volleyballAnnotation.coordinate = location
                volleyballAnnotation.image = self.imageCache[eq.ball_BATS]
                mapView.addAnnotation(volleyballAnnotation)
            } else if self.downloadState[eq.ball_BATS] == self.downloadState_fileNotExist{
                println("file not exist")
                //TODO toast
            }
            case 2:if self.imageCache[eq.ball_AutoBATS] != nil{
                volleyballAnnotation = MyVolleyballAnnotation()
                volleyballAnnotation.coordinate = location
                volleyballAnnotation.image = self.imageCache[eq.ball_AutoBATS]
                mapView.addAnnotation(volleyballAnnotation)
            } else if self.downloadState[eq.ball_AutoBATS] == self.downloadState_fileNotExist{
                println("file not exist")
                //TODO toast
            }
            case 3:if self.imageCache[eq.ball_FMNEAR] != nil{
                volleyballAnnotation = MyVolleyballAnnotation()
                volleyballAnnotation.coordinate = location
                volleyballAnnotation.image = self.imageCache[eq.ball_FMNEAR]
                mapView.addAnnotation(volleyballAnnotation)
            } else if self.downloadState[eq.ball_FMNEAR] == self.downloadState_fileNotExist{
                println("file not exist")
                //TODO toast
            }
            default:
                println("Unidentified volleyball type")
            }
        }
    }
    
    // Mark: Layout settings
    
    @IBAction func upButtonPressed(sender: UIButton) {
        if(viewFlag == Flag_HalfEQ){
            self.view.removeConstraint(view_constraint_4)
            self.view.removeConstraint(view_constraint_5)
            self.view.removeConstraint(view_constraint_6)
            self.view.removeConstraint(view_constraint_7)
            self.view.removeConstraint(view_constraint_8)
            self.view.removeConstraint(view_constraint_9)
            makeFullContentLayout()
        } else if (viewFlag == Flag_FullMap){
            self.view.removeConstraint(view_constraint_4)
            self.view.removeConstraint(view_constraint_5)
            self.view.removeConstraint(view_constraint_6)
            self.view.removeConstraint(view_constraint_7)
            self.view.removeConstraint(view_constraint_8)
            self.view.removeConstraint(view_constraint_9)
            makeHalfEQLayout()
        }
    }
    
    @IBAction func downButtonPressed(sender: UIButton) {
        if(viewFlag == Flag_HalfEQ){
            self.view.removeConstraint(view_constraint_4)
            self.view.removeConstraint(view_constraint_5)
            self.view.removeConstraint(view_constraint_6)
            self.view.removeConstraint(view_constraint_7)
            self.view.removeConstraint(view_constraint_8)
            self.view.removeConstraint(view_constraint_9)
            makeFullMapLayout()
        } else if(viewFlag == Flag_FullContent){
            self.view.removeConstraint(view_constraint_4)
            self.view.removeConstraint(view_constraint_5)
            self.view.removeConstraint(view_constraint_6)
            self.view.removeConstraint(view_constraint_7)
            self.view.removeConstraint(view_constraint_8)
            self.view.removeConstraint(view_constraint_9)
            makeHalfEQLayout()
        }
    }
    
    lazy var view_constraint_1 = NSArray()
    lazy var view_constraint_2 = NSArray()
    lazy var view_constraint_3 = NSArray()
    lazy var view_constraint_4 = NSLayoutConstraint()
    lazy var view_constraint_5 = NSLayoutConstraint()
    lazy var view_constraint_6 = NSLayoutConstraint()
    lazy var view_constraint_7 = NSLayoutConstraint()
    lazy var view_constraint_8 = NSLayoutConstraint()
    lazy var view_constraint_9 = NSLayoutConstraint()
    lazy var view_constraint_10 = NSLayoutConstraint()
    lazy var view_constraint_11 = NSLayoutConstraint()
    lazy var view_constraint_12 = NSLayoutConstraint()
    lazy var view_constraint_13 = NSLayoutConstraint()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var seisInfoView: UIView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var intensityButton: UIButton!
    @IBOutlet weak var seisMapButton: UIButton!
    @IBOutlet weak var ballButton: UIButton!
    
    func initializeLayout(){
        let viewsDictionary = ["top":mapView,"bottom":seisInfoView]
        view_constraint_1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[top]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        view_constraint_2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[bottom]-0-|", options: NSLayoutFormatOptions(0), metrics: nil,views: viewsDictionary)
        view_constraint_3 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[top]-[bottom(>=30)]-0-|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: viewsDictionary)
        
        let status_height = UIApplication.sharedApplication().statusBarFrame.size.height
        let height = self.navigationController!.navigationBar.frame.size.height
        view_constraint_10 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: mapButton, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -(height+status_height+5))
        view_constraint_11 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: intensityButton, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -(height+status_height+5))
        view_constraint_12 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: seisMapButton, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -(height+status_height+5))
        view_constraint_13 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: ballButton, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -(height+status_height+5))
        intensityButton.layer.borderWidth = 1.0
        intensityButton.layer.borderColor = intensityButton.tintColor?.CGColor
        intensityButton.layer.masksToBounds = true
        intensityButton.layer.cornerRadius = 3.0
        intensityButton.titleLabel?.adjustsFontSizeToFitWidth = true
        seisMapButton.layer.borderWidth = 1.0
        seisMapButton.layer.borderColor = seisMapButton.tintColor?.CGColor
        seisMapButton.layer.masksToBounds = true
        seisMapButton.layer.cornerRadius = 3.0
        seisMapButton.titleLabel?.adjustsFontSizeToFitWidth = true
        ballButton.layer.borderWidth = 1.0
        ballButton.layer.borderColor = ballButton.tintColor?.CGColor
        ballButton.layer.masksToBounds = true
        ballButton.layer.cornerRadius = 3.0
        ballButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.view.addConstraints(view_constraint_1 as [AnyObject])
        self.view.addConstraints(view_constraint_2 as [AnyObject])
        self.view.addConstraints(view_constraint_3 as [AnyObject])
        self.view.addConstraint(view_constraint_10)
        self.view.addConstraint(view_constraint_11)
        self.view.addConstraint(view_constraint_12)
        self.view.addConstraint(view_constraint_13)
    }
    
    func makeHalfEQLayout(){
        view_constraint_4 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 0.6, constant: 0.0)
        view_constraint_5 = NSLayoutConstraint(item: seisInfoView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 0.4, constant: 0.0)
        
        view_constraint_6 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: annotationBar, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 25.0)
        view_constraint_7 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: annotationBar, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20.0)
        view_constraint_8 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: historicMapBar, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 25.0)
        view_constraint_9 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: historicMapBar, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20.0)

        
        self.view.addConstraint(view_constraint_4)
        self.view.addConstraint(view_constraint_5)
        self.view.addConstraint(view_constraint_6)
        self.view.addConstraint(view_constraint_7)
        self.view.addConstraint(view_constraint_8)
        self.view.addConstraint(view_constraint_9)

        
        viewFlag = Flag_HalfEQ
    }
    
    func makeFullMapLayout(){
        view_constraint_4 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: -30.0)
        view_constraint_5 = NSLayoutConstraint(item: seisInfoView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 0.0, constant: 30.0)
        
        view_constraint_6 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: annotationBar, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 25.0)
        view_constraint_7 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: annotationBar, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20.0)
        view_constraint_8 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: historicMapBar, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 25.0)
        view_constraint_9 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: historicMapBar, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20.0)
        
        self.view.addConstraint(view_constraint_4)
        self.view.addConstraint(view_constraint_5)
        self.view.addConstraint(view_constraint_6)
        self.view.addConstraint(view_constraint_7)
        self.view.addConstraint(view_constraint_8)
        self.view.addConstraint(view_constraint_9)

        viewFlag = Flag_FullMap
    }
    
    func makeFullContentLayout(){
        let status_height = UIApplication.sharedApplication().statusBarFrame.size.height
        let height = self.navigationController!.navigationBar.frame.size.height
        println("====height:\(height+status_height)")
        view_constraint_4 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 0.0, constant: height+status_height)
        view_constraint_5 = NSLayoutConstraint(item: seisInfoView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: -(height+status_height))

        view_constraint_6 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: annotationBar, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0)
        view_constraint_7 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: annotationBar, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        view_constraint_8 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: historicMapBar, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0)
        view_constraint_9 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: historicMapBar, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraint(view_constraint_4)
        self.view.addConstraint(view_constraint_5)
        self.view.addConstraint(view_constraint_6)
        self.view.addConstraint(view_constraint_7)
        self.view.addConstraint(view_constraint_8)
        self.view.addConstraint(view_constraint_9)

        viewFlag = Flag_FullContent
    }
    
    // Mark: default functions
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var alert:UIAlertController!
    @IBAction func mapButtonPressed(sender: AnyObject) {
        alert = UIAlertController(title: "地圖選項", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tableVC = myStoryboard.instantiateViewControllerWithIdentifier("mapSwitchTableViewController") as! EQMapSwitchTableViewController!
        alert.addChildViewController(tableVC)
        alert.view.addSubview(tableVC.tableView)
            
    //        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.Default, handler: nil))
        //TODO: load previous map setting state 
        self.presentViewController(alert, animated: true, completion: nil)
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


    func loadPreviousSetting(){
        let fetchRequest = NSFetchRequest(entityName: "MapViewSetting")
        var err: NSError? = nil
        let fetchResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &err) as? [MapViewSetting]
        println(fetchResults?.description)
        if fetchResults != nil{
            if let mapViewSetting = fetchResults!.first {
                intensityType = mapViewSetting.intensityType.integerValue
                if mapViewSetting.intensitySwitch.boolValue {
                    intensitySwitch = true
                }
                if mapViewSetting.geoMapSwitch.boolValue {
                    mapView.addOverlay(geoMapTileOverlay, level: MKOverlayLevel.AboveLabels)
                }
                if mapViewSetting.faultSwitch.boolValue {
                    mapView.addOverlays(polylines)
                    mapView.addAnnotations(faultAnnotations)
                }
                if mapViewSetting.intersesmicSwitch.boolValue {
                    mapView.addOverlays(vectors, level: MKOverlayLevel.AboveLabels)
                }
                ballType = mapViewSetting.ballType.integerValue
                if mapViewSetting.ballSwitch.boolValue {
                    ballSwitch = true
                }
                if mapViewSetting.satelliteSwitch.boolValue {
                    self.mapView.mapType = MKMapType.Satellite
                }
                if mapViewSetting.historicMapSwitch.boolValue {
                    mapView.addOverlay(seisMapTileOverlay, level: MKOverlayLevel.AboveLabels)
                }
            }
        }

    }

    var ballType: Int = 0
    var intensityType: Int = 0
    var ballSwitch: Bool = false
    var intensitySwitch: Bool = false
    
    func changeMapOverlay(notification:NSNotification){
        println("change Map Overlay")
        let userInfo: Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let overlayString = userInfo["overlay"]!
        let action = userInfo["action"]!
        switch overlayString {
        case "intensity":
            if(action == "add"){
                println("add intensity map")
                let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
                dispatch_sync(lockQueue) {
                    self.intensityType = userInfo["type"]!.toInt()!
                    self.intensitySwitch = true
                    self.tryAddImage()
                }
            }else if(action == "remove"){
                println("remove intensity map")
                intensitySwitch = false
            }
        case "geoMap":
            if(action == "add"){
                mapView.addOverlay(geoMapTileOverlay, level: MKOverlayLevel.AboveLabels)
            }else if(action == "remove"){
                mapView.removeOverlay(geoMapTileOverlay)
            }
        case "fault":
            if(action == "add"){
                mapView.addOverlays(polylines)
                mapView.addAnnotations(faultAnnotations)
            }else if(action == "remove"){
                mapView.removeOverlays(polylines)
                mapView.removeAnnotations(faultAnnotations)
            }
        case "intersesmic":
            if(action == "add"){
                mapView.addOverlays(vectors, level: MKOverlayLevel.AboveLabels)
            }else if(action == "remove"){
                mapView.removeOverlays(vectors)
            }
        case "ball":
            if(action == "add"){
                println("add ball")
                let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
                dispatch_sync(lockQueue) {
                    self.ballType =  userInfo["type"]!.toInt()!
                    self.ballSwitch = true
                    self.tryAddImage()
                }
            }else if(action == "remove"){
                println("remove ball")
                mapView.removeAnnotation(volleyballAnnotation)
                ballSwitch = false
            }
        case "satellite":
            if(action == "add"){
                self.mapView.mapType = MKMapType.Satellite
            }else if(action == "remove"){
                self.mapView.mapType = MKMapType.Standard
            }
        case "historicMap":
            if(action == "add"){
                mapView.addOverlay(seisMapTileOverlay, level: MKOverlayLevel.AboveLabels)
            }else if(action == "remove"){
                mapView.removeOverlay(seisMapTileOverlay)
            }
        default:
            println("default remove all overlays")
            self.mapView.removeOverlays(self.mapView.overlays)
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
