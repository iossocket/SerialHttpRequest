//
//  APIManager.swift
//  SerialHttpRequest
//
//  Created by Xueliang Zhu on 6/22/16.
//  Copyright © 2016 kotlinchina. All rights reserved.
//

import UIKit

class APIManager {
    
    var tasks: Queue<NSURLSessionTask>
    var session: NSURLSession
    var queue: NSOperationQueue
    var currentTask: NSURLSessionTask?
    
    init() {
        tasks = Queue<NSURLSessionTask>()
        queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config, delegate: nil, delegateQueue: queue)
    }
    
    deinit {
        session.finishTasksAndInvalidate()
    }
    
    func addTask(url: String, response: (data: NSData?, resp: NSURLResponse?, error: NSError?) -> Void) {
        let task = session.dataTaskWithURL(NSURL(string: url)!) {[weak self] (data, resp, error) in
            response(data: data, resp: resp, error: error)
            self?.resumeTasks()
        }
        tasks.enqueue(task)
        resumeTasks()
    }
    
    private func resumeTasks() {
        queue.addOperationWithBlock { [weak self] in
            
            if let task = self?.currentTask {
                if task.state == NSURLSessionTaskState.Running {
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
