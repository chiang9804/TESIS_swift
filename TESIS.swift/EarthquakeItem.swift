//
//  TESIS_swift.swift
//  TESIS.swift
//
//  Created by Rose-Air on 2015/2/6.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import CoreData

class EarthquakeItem: NSManagedObject {

    @NSManaged var ball_AutoBATS: String
    @NSManaged var ball_BATS: String
    @NSManaged var ball_FMNEAR: String
    @NSManaged var ball_gCap: String
    @NSManaged var cwb_id: String
    @NSManaged var date: String
    @NSManaged var depth: String
    @NSManaged var isNew: NSNumber
    @NSManaged var lat: String
    @NSManaged var lng: String
    @NSManaged var location: String
    @NSManaged var map_cwb: String
    @NSManaged var map_pga: String
    @NSManaged var map_pgv: String
    @NSManaged var ml: String
    @NSManaged var no: String
    @NSManaged var time: String
    @NSManaged var distance: NSNumber
    @NSManaged var distanceText: String

    class func createManagedObjectContext(moc: NSManagedObjectContext, no:String,date: String,time: String,lat: String,lng: String,depth: String,ml: String,cwb_id: String,map_pgv: String,map_pga: String,location: String,ball_gCap: String,ball_BATS: String,ball_AutoBATS: String,ball_FMNEAR: String,map_cwb: String,isNew: NSNumber) -> EarthquakeItem{
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("EarthquakeItem", inManagedObjectContext: moc) as! EarthquakeItem
        newItem.no = no
        newItem.date = date
        newItem.time = time
        newItem.lat = lat
        newItem.lng = lng
        newItem.depth = depth
        newItem.ml = ml
        newItem.cwb_id = cwb_id
        newItem.map_cwb = map_cwb
        newItem.map_pga = map_pga
        newItem.map_pgv = map_pgv
        newItem.location = location
        newItem.ball_gCap = ball_gCap
        newItem.ball_BATS = ball_BATS
        newItem.ball_AutoBATS = ball_AutoBATS
        newItem.ball_FMNEAR = ball_FMNEAR
        newItem.isNew = isNew
        return newItem
    }
    
    class func createManagedObjectContext2(moc: NSManagedObjectContext, no:String,date: String,time: String,lat: String,lng: String,depth: String,ml: String,cwb_id: String,map_pgv: String,map_pga: String,location: String,ball_gCap: String,ball_BATS: String,ball_AutoBATS: String,ball_FMNEAR: String,map_cwb: String,isNew: NSNumber) -> EarthquakeItem{
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("EarthquakeItem2", inManagedObjectContext: moc) as! EarthquakeItem
        newItem.no = no
        newItem.date = date
        newItem.time = time
        newItem.lat = lat
        newItem.lng = lng
        newItem.depth = depth
        newItem.ml = ml
        newItem.cwb_id = cwb_id
        newItem.map_cwb = map_cwb
        newItem.map_pga = map_pga
        newItem.map_pgv = map_pgv
        newItem.location = location
        newItem.ball_gCap = ball_gCap
        newItem.ball_BATS = ball_BATS
        newItem.ball_AutoBATS = ball_AutoBATS
        newItem.ball_FMNEAR = ball_FMNEAR
        newItem.isNew = isNew
        return newItem
    }

}
