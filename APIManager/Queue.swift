//
//  Queue.swift
//  SerialHttpRequest
//
//  Created by Xueliang Zhu on 6/22/16.
//  Copyright © 2016 kotlinchina. All rights reserved.
//

import UIKit

class QueueItem<T> {
    let value: T!
    var next: QueueItem?
    
    init(_ newvalue: T?) {
        self.value = newvalue
    }
}

class Queue<T> {
    
    typealias Element = T
    
    var front: QueueItem<Element>
    var back: QueueItem<Element>
    
    init() {
        // Insert dummy item. Will disappear when the first item is added.
        back = QueueItem(nil)
        front = back
    }
    
    /// Add a new item to the back of the queue.
    func enqueue(value: Element) {
        back.next = QueueItem(value)
        back = back.next!
    }
    
    /// Return and remove the item at the front of the queue.
    func dequeue() -> Element? {
        if let newhead = front.next {
            front = newhead
            return newhead.value
        } else {
            return nil
        }
    }
    
    func isEmpty() -> Bool {
        return front === back
    }
}
