//
//  IntensityMapAnnotation.swift
//  TESIS.swift
//
//  Created by Rose-Pro on 2015/6/9.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import MapKit

class IntensityMapAnnotation: MKPointAnnotation {
    var image:UIImage!
    var topLeftCoord: CLLocationCoordinate2D!
    var bottomRightCoord: CLLocationCoordinate2D!
}