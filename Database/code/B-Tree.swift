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
    
    func find(_ key: Int) -> (BTreeNode, Int)? {
        return find(key, in: root)
    }
    
    private func find(_ key: Int, in node: BTreeNode?) -> (BTreeNode, Int)? {
        
        guard let n = node else {
            return nil
        }
        
        let p = n.leftBound(of: key)
        
        if p < n.keys.count && key == n.keys[p] {
            return (n, p)
        }
        
        if p < n.childs.count {
            return find(key, in: n.childs[p])
        }
        
        return nil
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
    
    func delete(_ key: Int) {
        
//        guard let res = find(key) else {
//            return
//        }
//
//        if res.0.leaf {
//            res.0.delete(key, at: res.1)
//        } else if let n = leftBiggestNode(of: res.0),
//                  let biggestKey = n.keys.last {
//            res.0.replaceKey(at: res.1, with: biggestKey)
//        }
        
    }
    
    func delete(_ key: Int, in n: BTreeNode, from pNode: BTreeNode?, dNode: BTreeNode?) {
        
        let position = n.leftBound(of: key)
        
        if let deleteNode = dNode {
            
            if let last = n.keys.last, n.leaf {
                deleteNode.replace(key, with: last)
                n.delete(last)
            } else {
                delete(key, in: n.childs[position], from: n, dNode: n)
            }
            
        } else if position < n.keys.count && n.keys[position] == key {
            
            if n.leaf {
                n.delete(at: position)
            } else {
                delete(key, in: n.childs[position], from: n, dNode: n)
            }
            
        } else if position < n.childs.count {
            delete(key, in: n.childs[position], from: n, dNode: dNode)
        }
        
        balance(n, with: pNode)
        
    }
    
    func balance(_ node: BTreeNode, with pNode: BTreeNode?) {
        
        let minKey = node.capacity / 2
        
        if node.keys.count < minKey {
            return
        }
        
        guard let p = pNode else {
            return
        }
        
        for (index, n) in p.childs.enumerated() where node === n {
            
            let right = index + 1
            let left = index - 1
            
            if right < p.childs.count && p.childs[right].keys.count > minKey {
                let rightSibling = p.childs[right]
                n.keys.append(p.keys[index])
                p.replace(p.keys[index], with: rightSibling.keys[0])
                rightSibling.delete(at: 0)
                
            } else if left >= 0 && p.childs[left].keys.count > minKey {
                let leftSibling = p.childs[left]
                let lastIndex = leftSibling.keys.count - 1
                n.keys.append(p.keys[left])
                p.replace(p.keys[left], with: leftSibling.keys[lastIndex])
                leftSibling.delete(at: lastIndex)
                
            } else {
                
                var mergedNode: BTreeNode?
                
                if index == p.childs.count - 1 {
                    let leftSibling = p.childs[left]
                    leftSibling.keys.append(p.keys[left])
                    leftSibling.keys.append(contentsOf: n.keys)
                    
                    p.delete(at: left)
                    p.deleteChild(at: index)
                    
                    mergedNode = leftSibling
                    
                } else {
                    n.keys.append(p.keys[index])
                    if right < p.childs.count {
                        let rightSibling = p.childs[right]
                        n.keys.append(contentsOf: rightSibling.keys)
                        p.deleteChild(at: right)
                    }
                    p.delete(index)
                    mergedNode = n
                }
                
                if let newRootNode = mergedNode, p === root && p.keys.isEmpty {
                    root = newRootNode
                }
                
            }
            
            return
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
