//
//  MapViewSetting.swift
//  TESIS.swift
//
//  Created by Rose-Pro on 2015/6/2.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import CoreData

class MapViewSetting: NSManagedObject {

    @NSManaged var ballSwitch: NSNumber
    @NSManaged var ballType: NSNumber
    @NSManaged var faultSwitch: NSNumber
    @NSManaged var geoMapSwitch: NSNumber
    @NSManaged var historicMapSwitch: NSNumber
    @NSManaged var intensitySwitch: NSNumber
    @NSManaged var intensityType: NSNumber
    @NSManaged var intersesmicSwitch: NSNumber
    @NSManaged var satelliteSwitch: NSNumber
    
    class func createManagedObjectContext(moc: NSManagedObjectContext, intensitySwitch:NSNumber, geoMapSwitch:NSNumber, faultSwitch:NSNumber, intersesmicSwitch:NSNumber, ballSwitch:NSNumber, satelliteSwitch:NSNumber, historicMapSwitch:NSNumber, ballType:NSNumber, intensityType:NSNumber) -> MapViewSetting{
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("MapViewSetting", inManagedObjectContext: moc) as! MapViewSetting
        newItem.intensitySwitch = intensitySwitch
        newItem.geoMapSwitch = geoMapSwitch
        newItem.faultSwitch = faultSwitch
        newItem.intersesmicSwitch = intersesmicSwitch
        newItem.ballSwitch = ballSwitch
        newItem.satelliteSwitch = satelliteSwitch
        newItem.historicMapSwitch = historicMapSwitch
        newItem.ballType = ballType
        newItem.intensityType = intensityType
        return newItem
    }
    
    func modify(intensitySwitch:NSNumber, geoMapSwitch:NSNumber, faultSwitch:NSNumber, intersesmicSwitch:NSNumber, ballSwitch:NSNumber, satelliteSwitch:NSNumber, historicMapSwitch:NSNumber, ballType:NSNumber, intensityType:NSNumber){
        self.intensitySwitch = intensitySwitch
        self.geoMapSwitch = geoMapSwitch
        self.faultSwitch = faultSwitch
        self.intersesmicSwitch = intersesmicSwitch
        self.ballSwitch = ballSwitch
        self.satelliteSwitch = satelliteSwitch
        self.historicMapSwitch = historicMapSwitch
        self.ballType = ballType
        self.intensityType = intensityType
        
    }

}
