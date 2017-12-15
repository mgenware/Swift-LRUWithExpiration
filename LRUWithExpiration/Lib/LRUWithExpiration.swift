//
//  LRUWithExpiration.swift
//  LRUWithExpiration
//
//  Created by Mgen on 15/12/17.
//  Copyright © 2017 Mgen. All rights reserved.
//  https://github.com/mgenware/Swift-LRUWithExpiration
//

import Cocoa

class LRUWithExpiration<Key, Value>: CustomStringConvertible where Key : Hashable {
    struct Node: CustomStringConvertible {
        var key: Key
        var value: Value
        var counter: Int
        var expire: TimeInterval
        
        var description: String {
            return "[\(key): \(value), expire: \(expire)]"
        }
    }
    
    private var linkedList: LinkedList<Node>
    private var nodeMap = [Key: LinkedList<Node>.Node]()
    let capacity: Int
    
    var count: Int {
        return nodeMap.count
    }
    
    init(capacity: Int) {
        self.capacity = capacity
        self.linkedList = LinkedList<Node>()
    }
    
    subscript(key: Key) -> Value? {
        get {
            guard let node = nodeMap[key] else {
                return nil
            }
            
            renewNode(node: node)
            return node.value.value
        }
    }
    
    func setValue(value: Value, forKey key: Key, expire: TimeInterval = -1) {
        if let node = nodeMap[key] {
            var nodeValue = node.value
            nodeValue.expire = expire
            nodeValue.value = value
            node.value = nodeValue
            renewNode(node: node)
        } else {
            let nodeValue = Node(key: key, value: value, counter: 0, expire: expire)
            
            if nodeMap.count >= capacity {
                prune()
            }
            
            let node = LinkedList<Node>.Node(value: nodeValue)
            linkedList.append(node)
            nodeMap[key] = node
            renewNode(node: node)
        }
    }
    
    @discardableResult func removeValue(forKey key: Key) -> Value? {
        guard let node = nodeMap.removeValue(forKey: key) else {
            return nil
        }
        // this is an O(1) operation
        linkedList.remove(node: node)
        return node.value.value
    }
    
    func removeAll() {
        nodeMap.removeAll()
        linkedList.removeAll()
    }
}

// MARKP - CustomStringConvertible
extension LRUWithExpiration {
    var description: String {
        var results = "LRUWithExpiration(Count: \(count), Capacity: \(capacity)) {\n"
        for (_, value) in nodeMap {
            results.append("  \(value.value.description)\n")
        }
        results.append("}")
        return results
    }
}

// MARK: - Private funcs
extension LRUWithExpiration {
    private func prune() {
        guard let node = linkedList.last else {
            return
        }
        // this is an O(1) operation
        removeValue(forKey: node.value.key)
    }
    
    private func renewNode(node: LinkedList<Node>.Node) {
        // move node to head of linked list
        linkedList.remove(node: node)
        linkedList.insert(node, at: 0)
        
        // update counter
        var context = node.value
        context.counter += 1
        node.value = context
        
        if context.expire > 0.0 {
            let capturedCounter = context.counter
            let capturedKey = context.key
            DispatchQueue.main.asyncAfter(deadline: .now() + context.expire) {
                guard let node = self.nodeMap[capturedKey] else {
                    return
                }
                if node.value.counter == capturedCounter {
                    self.removeValue(forKey: capturedKey)
                }
            }
        }
    }
}

