//
//  RouteDefine.swift
//  Mapple_Example
//
//  Created by hao yin on 2021/7/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Mapple

let viewControllers = ConfigrationRoute {
    Route(name: "main") { m, param in
        UIStoryboard(name: "Test", bundle: nil).instantiateViewController(withIdentifier: m)
    }
}
