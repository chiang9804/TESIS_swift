//
//  EarthquakeFileURL.swift
//  TESIS.swift
//
//  Created by Rose-Air on 2015/1/12.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation

struct SessionProperties {
    static let identifier : String! = "url_session_background_download"
}

func getEarthquakeIdLink() -> String {
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
    let date1 = "\(components.year)-\(components.month)-\(components.day)"
//    let date1 = String(components.year)+"-"+String(components.month)+"-"+String(components.day)

//    println("get date \(date1)")
    
    let threeMonthAgo = calendar.dateByAddingUnit(.CalendarUnitMonth, value: -3, toDate: date, options: nil)!
    
    let components2 = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: threeMonthAgo)
    let date2 = "\(components2.year)-\(components2.month)-\(components2.day)"
//    let date2 = String(components2.year)+"-"+String(components2.month)+"-"+String(components2.day)
    
//    println("get date \(date2)")
    
    let data = "http://tesis.earth.sinica.edu.tw/common/php/getid.php?start="+date2+"&end="+date1
    
    return data
}

func getEarthquakeIdLink(fromDate:NSDate, toDate:NSDate) -> String {

    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: toDate)
    let date1 = "\(components.year)-\(components.month)-\(components.day)"
    //    let date1 = String(components.year)+"-"+String(components.month)+"-"+String(components.day)
    
    let components2 = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: fromDate)
    let date2 = "\(components2.year)-\(components2.month)-\(components2.day)"
    //    let date2 = String(components2.year)+"-"+String(components2.month)+"-"+String(components2.day)
    
    //    println("get date \(date2)")
    
    let data = "http://tesis.earth.sinica.edu.tw/common/php/getid.php?start="+date2+"&end="+date1
    
    return data
}


func getEarthquakeListLink() -> String{
    let data = "http://tesis.earth.sinica.edu.tw/common/php/processdatamobile.php?firstid=800&secondid=820"
    return data
}