//
//  BTreeNode.swift
//  Algorihtm
//
//  Created by ChenBin on 2021/3/29.
//  Copyright © 2021 ChenBin. All rights reserved.
//

import Foundation

class BTreeNode {
    
    let capacity: Int
    
    var keys: [Int] = []
    
    var childs: [BTreeNode] = []
    
    init(capacity: Int, keys: [Int], childs: [BTreeNode]) {
        self.capacity = capacity
        self.keys = keys
        self.childs = childs
    }
}

extension BTreeNode {
    
    func insert(_ key: Int) {
        
        let p = leftBound(of: key)
        
        if p < keys.count {
            keys.insert(key, at: p)
        } else {
            keys.append(key)
        }
        
    }
    
    func insert(_ child: BTreeNode, at index: Int) {
        if index >= childs.count {
            childs.append(child)
        } else {
            childs.insert(child, at: index)
        }
    }
    
}

extension BTreeNode {
    
    func delete(_ key: Int) {
        
        let p = leftBound(of: key)
        
        if p < keys.count && keys[p] == key {
            keys.remove(at: p)
        }
    }
    
    func delete(at p: Int) {
        if p < keys.count {
            keys.remove(at: p)
        }
    }
    
    func deleteChild(at p: Int) {
        if p < childs.count {
            childs.remove(at: p)
        }
    }
    
}

extension BTreeNode {
    func replace(_ key: Int, with newKey: Int) {
        
        let p = leftBound(of: key)
        
        guard keys[p] == key else {
            return
        }
        
        keys[p] = newKey
    }
}

extension BTreeNode {
    
    func leftBound(of key: Int) -> Int {
        var left = 0
        var right = keys.count
        
        while left < right {
            let middle = left + (right - left) / 2
            
            if key > keys[middle] {
                left = middle + 1
            } else if key < keys[middle] {
                right = middle
            } else {
                right = middle
            }
        }
        
        return left
    }
    
}

extension BTreeNode {
    
    var leaf: Bool {
        return childs.isEmpty
    }
    
}
