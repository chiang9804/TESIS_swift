//
//  GeoMapTileOverlay.swift
//  TESIS.swift
//
//  Created by IES on 3/27/15.
//  Copyright (c) 2015 Rose-Air. All rights reserved.
//

import Foundation
import MapKit

class GeoMapTileOverlay: MKTileOverlay{
    var cache:NSCache! = NSCache()
    var operationQueue:NSOperationQueue! = NSOperationQueue()
    
    override func URLForTilePath(path: MKTileOverlayPath) -> NSURL! {
        // modify tiles URL
//        println("request map tiles: \(path.x)-\(path.y)-\(path.z)")
        return NSURL(string: "http://tesis.earth.sinica.edu.tw/testimage/imageAll/\(path.x)-\(path.y)-\(path.z).png")
    }
    
    override func loadTileAtPath(path: MKTileOverlayPath, result: ((NSData!, NSError!) -> Void)!) {
        // custom tiles
        if result == nil{
            return ;
        }
        var cachedData:NSData?
        if self.cache != nil{
            cachedData = self.cache.objectForKey(self.URLForTilePath(path)) as! NSData?
        } else {
            cachedData = nil
        }
        if cachedData != nil{
            result(cachedData, nil)
        } else {
//            println("loadTileAtPath: no cachedData")
            var request = NSURLRequest(URL: self.URLForTilePath(path))
//            println("send download request at: \(self.URLForTilePath(path))")
            NSURLConnection.sendAsynchronousRequest(request, queue: self.operationQueue, completionHandler:{response,data,error in
                self.cache.setObject(data, forKey: self.URLForTilePath(path))
                result(data, error)
            })
        }
        
    }
}