//
//  DownloadSessionDelegate.swift
//  TESIS.swift
//
//  Created by Rose-Air on 2014/11/6.
//  Copyright (c) 2014年 Rose-Air. All rights reserved.
//

import Foundation
import CoreData
import UIKit

typealias CompleteHandlerBlock = () -> ()

class DownloadSessionDelegate : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate{
    
    var handlerQueue: [String : CompleteHandlerBlock]!
    lazy var managedObjectContext: NSManagedObjectContext! = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
    }()
    
    class var sharedInstance: DownloadSessionDelegate {
        struct Static {
            static var instance : DownloadSessionDelegate?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = DownloadSessionDelegate()
            Static.instance!.handlerQueue = [String : CompleteHandlerBlock]()
        }
        
        return Static.instance!
    }
    
    //MARK: session delegate
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        println("session error: \(error?.localizedDescription).")
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust))
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
//        println("session \(session) has finished the download task \(downloadTask) of URL \(location).")
        println("session: did finished the download task to URL.")
        println("session: File Handle \(NSFileHandle(forReadingAtPath: location.path!))")
        var fileHandle:NSFileHandle? = NSFileHandle(forReadingAtPath: location.path!)
        if fileHandle == nil{
            println("download tmp file open failed")
        } else {
            var data:NSData = fileHandle!.readDataToEndOfFile()
    //        println(data)
            
            let fileManager = NSFileManager.defaultManager()
            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docsDir = dirPaths[0] as! String
    //        println(docsDir)
            
            if fileManager.createFileAtPath(docsDir+"/EQdata", contents: data, attributes: nil){
                println("save file to document succeed.")
            } else {
                println("save file to document failed.")
            }

            let json = JSON(data:data)
    //        println("eqrthquakes: \(json)")

            if json != nil{
                let earthquakeList = json["earthquakes"]
    //            println("EarthquakeList:\(earthquakeList[0])")
                // save to Core dataswift 
                if let moc = self.managedObjectContext {
                    for i in 1...earthquakeList.count-1{
//                        println("EarthquakeList:\(earthquakeList[i])")
                        EarthquakeItem.createManagedObjectContext(moc, no: earthquakeList[i]["No"].stringValue, date: earthquakeList[i]["Date"].stringValue, time: earthquakeList[i]["Time"].stringValue, lat: earthquakeList[i]["Latitude"].stringValue, lng: earthquakeList[i]["Longitude"].stringValue, depth: earthquakeList[i]["depth"].stringValue, ml: earthquakeList[i]["ML"].stringValue, cwb_id: earthquakeList[i]["CWB_ID"].stringValue, map_pgv: earthquakeList[i]["pgvlink"].stringValue, map_pga: earthquakeList[i]["pgacontour1"].stringValue, location: earthquakeList[i]["Location"].stringValue, ball_gCap: earthquakeList[i]["gCAP"].stringValue, ball_BATS: earthquakeList[i]["BATS"].stringValue, ball_AutoBATS: earthquakeList[i]["New_BATS"].stringValue, ball_FMNEAR: earthquakeList[i]["FMNEAR"].stringValue, map_cwb: earthquakeList[i]["intensitymap"].stringValue, isNew: true)
                    }
                }
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.saveContext()
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey_updateEQListView, object: self)
                
            }
            fileHandle!.closeFile()
        }
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        println("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")
        println("session: download task wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")

    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        println("session: download task resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.")
//        println("session \(session) download task \(downloadTask) resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error == nil {
//            println("session \(session) download completed")
            println("session: download completed")
//            let appDelegate = UIApplication.sharedApplication() as AppDelegate
        } else {
            println("session: download failed with error \(error?.localizedDescription)")
        }
    }
    
    // when the session finishes the last background download task
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        println("session: background session finished events.")
        
        if !session.configuration.identifier.isEmpty {
            callCompletionHandlerForSession(session.configuration.identifier)
        }
    }
    
    //MARK: completion handler
    func addCompletionHandler(handler: CompleteHandlerBlock, identifier: String) {
        handlerQueue[identifier] = handler
    }
    
    // store the completion handler
    func callCompletionHandlerForSession(identifier: String!) {
        if handlerQueue[identifier] != nil  {
            var handler: CompleteHandlerBlock = handlerQueue[identifier]!
            handlerQueue!.removeValueForKey(identifier)
            handler()
        }
    }
}