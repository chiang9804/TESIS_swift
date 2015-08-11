//
//  IntensityMapAnnotationView.swift
//  TESIS.swift
//
//  Created by Rose-Pro on 2015/6/9.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import MapKit

class IntensityMapAnnotationView: MKAnnotationView{
    var zoomLevel: MKCoordinateSpan!
    override func drawRect(rect: CGRect) {
        // Not called
        println("*******span:\(zoomLevel)")
        let myAnnotation = self.annotation as! IntensityMapAnnotation
        let rect = CGRectMake(0, 0, self.image.size.width/4, self.image.size.height/4)
        self.image.drawInRect(rect)
        
    }
}
