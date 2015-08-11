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

class EQViewController: UIViewController,MKMapViewDelegate {

    var viewFlag = Flag_HalfEQ
    var eq : EarthquakeItem!
    let template = "http://tesis.earth.sinica.edu.tw/testimage/imageAll/{x}-{y}-{z}.png"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: nil)
        
        self.navigationItem.rightBarButtonItem =  refreshBarButtonItem
        
        self.title = "地震資訊"
        
        initializeLayout()
        makeHalfEQLayout()
        
        initMapView() // set location
        loadAnnotation() // set annotation
        loadGeoMapTileOverlay() // set tileOverlay
        loadSeisMapTileOverlay()
        loadFault()
        
//        mapView.addAnnotation(annotation)
//        mapView.addOverlay(geoMapTileOverlay, level: MKOverlayLevel.AboveLabels)
//        mapView.addOverlay(seisMapTileOverlay, level: MKOverlayLevel.AboveLabels)

    }
    
    
    
    // Mark: load Map data
    var location: CLLocationCoordinate2D!
    var annotation: MKPointAnnotation!
    var geoMapTileOverlay: GeoMapTileOverlay!
    var seisMapTileOverlay: SeisMapTileOverlay!
    
    // initial data setting
    func initMapView(){
        mapView.delegate = self
        self.location = CLLocationCoordinate2D(latitude: (NSString(string: eq.lat)).doubleValue, longitude: (NSString(string: eq.lng)).doubleValue)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
    }
    
    func loadAnnotation(){
        self.annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = "\(eq.date) \(eq.time) Taipei time"
        annotation.subtitle = "ML \(eq.ml) \n\(eq.location)"
//        mapView.addAnnotation(annotation)
    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        //        println("mapView: renderForOverlay")
        if overlay.isKindOfClass(MKTileOverlay) {
            return MKTileOverlayRenderer(tileOverlay: overlay as MKTileOverlay)
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
    }
    
    var points = [Point]()
    var polylines = [FaultPolylineOverlay]()
    var faultAnnotations = [MKPointAnnotation]()

    func loadFault(){
        let path = NSBundle.mainBundle().pathForResource("fault2010_new.dat", ofType: "txt")
        println("Fault path: \(path)")
        let content = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        if content == nil {
            println("cannot read fault data")
        } else {
            var arrayOfLines = split(String(content!)){$0 == "\n"} as [String]
            var id = 0
            var gId = 0
            for i in 0...arrayOfLines.count-1 {
                if(arrayOfLines[i]=="X"){
                    gId++
                } else {
                    var arrayOfLatlng = split(String(arrayOfLines[i])){$0 == " "} as [String]
                    points.append(Point(index: id, group_index: gId, Latlng: CLLocationCoordinate2D(latitude: NSString(string: arrayOfLatlng[0]).doubleValue , longitude: NSString(string: arrayOfLatlng[1]).doubleValue)))
                    id++
                }
            }
            let scale = 20
            // TODO add annotaion to faultAnnotations
            for i in 1...gId{
                var tmp_points = [points.filter(){$0.group_index == i}]
                var coordinates =             }
            
        }
    }
    
    // Mark: Layout settings
    
    @IBAction func upButtonPressed(sender: UIButton) {
        if(viewFlag == Flag_HalfEQ){
            self.view.removeConstraint(view_constraint_4)
            self.view.removeConstraint(view_constraint_5)
            makeFullContentLayout()
        } else if (viewFlag == Flag_FullMap){
            self.view.removeConstraint(view_constraint_4)
            self.view.removeConstraint(view_constraint_5)
            makeHalfEQLayout()
        }
    }
    
    @IBAction func downButtonPressed(sender: UIButton) {
        if(viewFlag == Flag_HalfEQ){
            self.view.removeConstraint(view_constraint_4)
            self.view.removeConstraint(view_constraint_5)
            makeFullMapLayout()
        } else if(viewFlag == Flag_FullContent){
            self.view.removeConstraint(view_constraint_4)
            self.view.removeConstraint(view_constraint_5)
            makeHalfEQLayout()
        }
    }
    
    lazy var view_constraint_1 = NSArray()
    lazy var view_constraint_2 = NSArray()
    lazy var view_constraint_3 = NSArray()
    lazy var view_constraint_4 = NSLayoutConstraint()
    lazy var view_constraint_5 = NSLayoutConstraint()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var seisInfoView: UIView!
    
    func initializeLayout(){
        let viewsDictionary = ["top":mapView,"bottom":seisInfoView]
        view_constraint_1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[top]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        view_constraint_2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[bottom]-0-|", options: NSLayoutFormatOptions(0), metrics: nil,views: viewsDictionary)
        view_constraint_3 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[top(bottom)]-[bottom(>=30)]-0-|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: viewsDictionary)
        self.view.addConstraints(view_constraint_1)
        self.view.addConstraints(view_constraint_2)
        self.view.addConstraints(view_constraint_3)
    }
    
    func makeHalfEQLayout(){
        view_constraint_4 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 0.6, constant: 0.0)
        view_constraint_5 = NSLayoutConstraint(item: seisInfoView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 0.4, constant: 0.0)
       
        self.view.addConstraint(view_constraint_4)
        self.view.addConstraint(view_constraint_5)
        
        viewFlag = Flag_HalfEQ
    }
    
    func makeFullMapLayout(){
        view_constraint_4 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0)
        view_constraint_5 = NSLayoutConstraint(item: seisInfoView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 0.0, constant: 30.0)
        
        self.view.addConstraint(view_constraint_4)
        self.view.addConstraint(view_constraint_5)
        
        viewFlag = Flag_FullMap
    }
    
    func makeFullContentLayout(){
        let height = UIApplication.sharedApplication().statusBarFrame.size.height
        println("====height:\(height)")
        view_constraint_4 = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 0.0, constant: 0.0)
        view_constraint_5 = NSLayoutConstraint(item: seisInfoView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 0.9, constant: 0.0)

        self.view.addConstraint(view_constraint_4)
        self.view.addConstraint(view_constraint_5)
        
        viewFlag = Flag_FullContent
    }
    
    // Mark: default functions
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
