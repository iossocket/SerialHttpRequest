//
//  APIManager.swift
//  SerialHttpRequest
//
//  Created by Xueliang Zhu on 6/22/16.
//  Copyright © 2016 kotlinchina. All rights reserved.
//

import UIKit

class APIManager {
    
    var tasks: Queue<URLSessionTask>
    var session: URLSession
    var queue: OperationQueue
    var currentTask: URLSessionTask?
    
    init() {
        tasks = Queue<URLSessionTask>()
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: nil, delegateQueue: queue)
    }
    
    deinit {
        session.finishTasksAndInvalidate()
    }
    
    func addTask(_ url: String, method: Method, parameters: [String: AnyObject], encoding: ParameterEncoding = .url, header: [String: String]? = nil, response: @escaping (_ data: Data?, _ resp: URLResponse?, _ error: Error?) -> Void) {
        let req = request(url, method: method, parameters: parameters, encoding: encoding, headers: header)
        guard let request = req else {
            response(nil, nil, NSError(domain: "request create error", code: 422, userInfo: nil))
            return
        }
        
        let task = session.dataTask(with: request, completionHandler: {[weak self] (data, resp, error) in
            response(data, resp, error)
            self?.resumeTasks()
        }) 
        tasks.enqueue(task)
        resumeTasks()
    }
    
    fileprivate func resumeTasks() {
        queue.addOperation { [weak self] in
            
            if let task = self?.currentTask {
                if task.state == URLSessionTask.State.running {
                    return
                }
            }
            
            guard let current = self?.tasks.dequeue() else {
                return
            }
            self?.currentTask = current
            current.resume()
        }
    }
}
