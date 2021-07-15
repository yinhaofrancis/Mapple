//
//  ViewController.swift
//  Mapple
//
//  Created by yinhaofrancis on 07/14/2021.
//  Copyright (c) 2021 yinhaofrancis. All rights reserved.
//

import UIKit
import Mapple


class login:Seed{
    static func type() -> SeedType {
        .strong
    }
    
    static var factory: SeedFactory = {login()}
    
    var bucket: SeedBucket?
    
    var name: String = ""
    
}



class ViewController: UIViewController {

    
    @Carrot
    var l:login!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(l)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

