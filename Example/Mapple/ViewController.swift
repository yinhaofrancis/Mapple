//
//  ViewController.swift
//  Mapple
//
//  Created by yinhaofrancis on 07/14/2021.
//  Copyright (c) 2021 yinhaofrancis. All rights reserved.
//

import UIKit
import Mapple



class ViewController: UIViewController {

    
    let a = ConfigrationRoute {
        Route(name: "dd") { i in
            UIViewController()
        }
        Route(name: "dd1") { i in
            UIViewController()
        }
        Route(name: "dd2") { i in
            UIViewController()
        }
        Route(name: "dd3") { i in 
            UIViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        ViewBuilder
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {

        self.present(a.route(route: "dd")!, animated: true) {
            
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

