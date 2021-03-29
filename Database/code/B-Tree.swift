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

class BTree {
    
    let capacity: Int
    
    private(set) var root: BTreeNode?
    
    init(capacity: Int, root: BTreeNode? = nil) {
        self.capacity = capacity
        self.root = root
    }
}

// MARK: Find
extension BTree {
    
    func find(_ key: Int) -> BTreeNode? {
        return find(key, in: root)
    }
    
    private func find(_ key: Int, in node: BTreeNode?) -> BTreeNode? {
        
        guard let n = node else {
            return nil
        }
        
        let p = n.leftBound(of: key)
        
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

// MARK: Insert
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
        
        let p = n.leftBound(of: key)
        
        if n.leaf {
            n.insert(key)
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
        
        for (index, n) in p.childs.enumerated() where n === node {
            p.insert(node.keys[middle])
            p.childs[index] = l
            p.insert(r, at: index + 1)
            break
        }
                
    }
}

// MARK: Delete
extension BTree {
    
    private func delete(_ key: Int) {
        
        guard let findedNode = find(key) else {
            return
        }
        
        if findedNode.leaf {
            
            
        } else {
            
        }
        
    }
    
}

extension BTree {
    
    private func leftBiggestNode(of node: BTreeNode) -> BTreeNode? {
        guard let lastNode = node.childs.last else {
            return node
        }
        
        return leftBiggestNode(of: lastNode)
    }
    
}
