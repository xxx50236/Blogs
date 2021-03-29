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
    
    init(capacity: Int, root: BTreeNode? = nil) {
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
        
        if root == nil {
            root = BTreeNode(capacity: capacity, keys: [key], childs: [])
        } else {
            insert(key, into: root, from: nil)
        }
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
                    
        }
        
        if p < n.childs.count {
            insert(key, into: n.childs[p], from: n)
        }
        
        spilt(n, from: pnode)
    }
    
    private func spilt(_ node: BTreeNode, from pNode: BTreeNode?) {
        
        guard node.keys.count > capacity else {
            return
        }
        
        let middle = node.keys.count / 2
        
        let lt = node.leaf ? [] : Array(node.childs[0...middle])
        let l = BTreeNode(capacity: capacity, keys: Array(node.keys[0..<middle]), childs: lt)
        
        let next = middle + 1
        let rt = node.leaf ? [] : Array(node.childs[next...])
        let r = BTreeNode(capacity: capacity, keys: Array(node.keys[next...]), childs: rt)
        
        guard let p = pNode else {
            let newRoot = BTreeNode(capacity: capacity, keys: [node.keys[middle]], childs: [l, r])
            root = newRoot
            return
        }
        
        var i: Int?
        
        for (index, n) in p.childs.enumerated() where n === node {
            i = index
            break
        }
        
        guard let index = i else {
            return
        }
        
        let position = leftBound(node.keys[middle], in: p.keys)
        if position < p.keys.count {
            p.keys.insert(node.keys[middle], at: position)
        } else {
            p.keys.append(node.keys[middle])
        }
        
        p.childs[index] = l
        if (index + 1) >= p.childs.count {
            p.childs.append(r)
        } else {
            p.childs.insert(r, at: index + 1)
        }
        
    }
}

extension BTree {
    
    private func leftBound(_ key: Int, in keys: [Int]) -> Int {
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
