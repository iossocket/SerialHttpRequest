//
//  QueueTests.swift
//  SerialHttpRequest
//
//  Created by XueliangZhu on 15/08/2017.
//  Copyright © 2017 kotlinchina. All rights reserved.
//

import XCTest
@testable import SerialHttpRequest

class QueueTests: XCTestCase {
    
    func testDequeueWhenQueueIsNotEmpty() {
        let queue = Queue<Int>()
        let enqueueItem = 0
        queue.enqueue(enqueueItem)
        
        let dequeueItem = queue.dequeue()
        
        XCTAssertEqual(enqueueItem, dequeueItem)
    }
    
    func testDequeueWhenQueueIsEmpty() {
        let queue = Queue<Int>()
        
        let dequeueItem = queue.dequeue()
        
        XCTAssertNil(dequeueItem)
    }
}
