//
//  SettingTableViewController.swift
//  TESIS.swift
//
//  Created by Rose-Pro on 2015/7/13.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import UIKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var mlRangeLabel: UILabel!
    @IBOutlet weak var deepRangeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var infoSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: look at EQMapSwitchTableViewController
        // save setting (add an entity?)
        // notification back to filter the list
    }
    

}
