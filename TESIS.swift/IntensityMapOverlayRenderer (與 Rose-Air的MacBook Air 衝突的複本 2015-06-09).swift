//
//  IntensityMapOverlayRenderer.swift
//  TESIS.swift
//
//  Created by Rose-Pro on 2015/6/9.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import MapKit

class IntensityMapOverlayRenderer: MKOverlayRenderer {
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext!) {
        let myOverlay = self.overlay as! IntensityMapOverlay
        let bounds = myOverlay.boundingMapRect
        context.Sca
    }
}