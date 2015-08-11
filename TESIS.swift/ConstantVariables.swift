//
//  ConstantVariables.swift
//  TESIS.swift
//
//  Created by Rose-Air on 2015/2/3.
//  Copyright (c) 2015年 Rose-Air. All rights reserved.
//

import Foundation
import UIKit

let NotificationKey_updateEQListView = "notification.key.update.eqlist.view"
let NotificationKey_updateEQInfoView = "notification.key.update.eqinfo.view"
let NotificationKey_changeMapOverlay = "notification.key.change.map.overlay"
let NotificationKey_dismissMapbuttonAlert = "notification.key.dismiss.map.button.alert"
let NotificationKey_updateEQListView_p = "notification.key.update.eqlist.view.p"

/** layout constraints **/
let Flag_HalfEQ = 0
let Flag_FullMap = 1
let Flag_FullContent = 2

/** Fault line name **/
let lineName = ["山腳斷層", "湖口斷層", "新竹斷層", "新城斷層",
    "新城斷層", "獅潭斷層", "三義斷層", "大甲斷層", "大甲斷層", "鐵砧山斷層", "鐵砧山斷層", "屯子腳斷層",
    "彰化斷層", "大茅埔斷層", "九芎坑斷層", "梅山斷層", "大尖山斷層", "大尖山斷層", "木屐寮斷層",
    "六甲斷層", "觸口斷層", "觸口斷層", "新化斷層", "後甲里斷層", "左鎮斷層", "左鎮斷層", "左鎮斷層",
    "小崗山斷層", "旗山斷層", "潮州斷層", "潮州斷層", "恆春斷層", "米崙斷層", "嶺頂斷層", "瑞穗斷層",
    "奇美斷層", "玉里斷層", "玉里斷層", "池上斷層", "鹿野斷層", "利吉斷層", "利吉斷層",
    "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層",
    "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層",
    "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層",
    "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層", "車籠埔斷層及其支斷層",
    "車籠埔支斷層(隘寮斷層)"
]
let lineColor = [
    1, 1, 1, 5, 5, 0, 5, 5, 5, 5,
    5, 0, 5, 0, 2, 0, 0, 0, 1, 5,
    0, 0, 0, 1, 1, 1, 1, 1, 5, 1,
    1, 1, 1, 1, 5, 1, 5, 5, 5, 5,
    1, 1, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0
]
// usage of array
//for (index, value) in enumerate(shoppingList) {
//    println("Item \(index + 1): \(value)")
//}