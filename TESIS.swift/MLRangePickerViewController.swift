//
//  MLRangePickerViewController.swift
//  TESIS.swift
//
//  Created by Rose-Pro on 2015/7/13.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import UIKit
class MLRangePickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var values = [0.0,0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,8.5,9.0,9.5,10.0]
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return String(stringInterpolationSegment: values[row])
    }
}