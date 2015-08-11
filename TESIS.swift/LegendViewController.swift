//
//  LegendViewController.swift
//  TESIS.swift
//
//  Created by Rose-Pro on 2015/4/21.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import UIKit

class LegendViewController: UIViewController, UIScrollViewDelegate{
   
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 6.0
        scrollView.contentSize = self.imageView.frame.size
        println("legend size \(self.imageView.frame.size)")
        scrollView.delegate = self
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        
    }
    
    @IBAction func closePopup(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}