//
//  ViewController.swift
//  SerialHttpRequest
//
//  Created by Xueliang Zhu on 6/22/16.
//  Copyright © 2016 kotlinchina. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let manager = APIManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.addTask("https://www.baidu.com", method: .GET, parameters: [:], encoding: .url) { (data, resp, error) in
            print(resp ?? "nil")
        }
        manager.addTask("https://www.baidu.com", method: .GET, parameters: [:], encoding: .url) { (data, resp, error) in
            print(resp ?? "nil")
        }
        manager.addTask("https://www.baidu.com", method: .GET, parameters: [:], encoding: .url) { (data, resp, error) in
            print(resp ?? "nil")
        }
        manager.addTask("https://www.baidu.com", method: .GET, parameters: [:], encoding: .url) { (data, resp, error) in
            print(resp ?? "nil")
        }
    }
}

