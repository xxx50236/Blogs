//
//  B-Tree.swift
//  Algorihtm
//
//  Created by ChenBin on 2021/3/24.
//  Copyright © 2021 ChenBin. All rights reserved.
//

import Foundation

/*
 
 根据 Knuth 的定义，一个 m 阶的B树是一个有以下属性的树：
 每一个节点最多有 m 个子节点
 每一个非叶子节点（除根节点）最少有 ⌈m/2⌉ 个子节点
 如果根节点不是叶子节点，那么它至少有两个子节点
 有 k 个子节点的非叶子节点拥有 k − 1 个键
 所有的叶子节点都在同一层
 
 */

class BTreeNode {
    
    let capacity: Int
    
    var keys: [Int] = []
    
    var childs: [BTreeNode] = []
    
    init(capacity: Int, keys: [Int], childs: [BTreeNode]) {
        self.capacity = capacity
        self.keys = keys
        self.childs = childs
    }
    
    var leaf: Bool {
        return childs.isEmpty
    }
}

class BTree {
    
    let capacity: Int
    
    private(set) var root: BTreeNode?
    
    init(capacity: Int, root: BTreeNode) {
        self.capacity = capacity
        self.root = root
    }
}

//
extension BTree {
    
    func find(_ key: Int) -> BTreeNode? {
        return find(key, in: root)
    }
    
    private func find(_ key: Int, in node: BTreeNode?) -> BTreeNode? {
        
        guard let n = node else {
            return nil
        }
        
        let p = leftBound(key, in: n.keys)
        
        if p < 0 || p >= n.keys.count {
            return nil
        }
        
        if key == n.keys[p] {
            return n
        } else if p < n.childs.count {
            return find(key, in: n.childs[p])
        } else {
            return nil
        }
    }
}

extension BTree {
    
    func insert(_ key: Int) {
        insert(key, into: root, from: nil)
    }
    
    private func insert(_ key: Int, into node: BTreeNode?, from pnode: BTreeNode?) {
        guard let n = node else {
            return
        }
        
        let p = leftBound(key, in: n.keys)
        
        if n.leaf {
            
            if p < n.keys.count {
                n.keys.insert(key, at: p)
            } else {
                n.keys.append(key)
            }
            
            if n.keys.count > capacity {
                spilt(n.childs[p], from: n, at: p)
            }
            
            return
        }
        
        insert(key, into: n.childs[p], from: n)
        
        spilt(n.childs[p], from: n, at: p)
    }
    
    private func spilt(_ node: BTreeNode, from pNode: BTreeNode?, at position: Int) {
        guard node.keys.count > capacity else {
            return
        }
        
        let middle = node.keys.count / 2
        
        let l = BTreeNode(capacity: capacity, keys: Array(node.keys[0..<middle]), childs: Array(node.childs[0...middle]))
        
        let next = middle + 1
        let r = BTreeNode(capacity: capacity, keys: Array(node.keys[next...]), childs: Array(node.childs[next...]))
        
        if let p = pNode {
            p.childs[position] = l
            if (position + 1) < p.childs.count {
                p.childs.append(r)
            } else {
                p.childs[position + 1] = r
            }
        } else {
            let newRoot = BTreeNode(capacity: capacity, keys: [node.keys[middle]], childs: [l, r])
            root = newRoot
        }
        
    }
    
}

extension BTree {
    
    func leftBound(_ key: Int, in keys: [Int]) -> Int {
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
