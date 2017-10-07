//
//  SwiftClassParser.swift
//  Drafter
//
//  Created by LZephyr on 2017/10/3.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/*
 definition = class_definition | protocol_definition | extension_definition
 g
 class_definition = 'class' NAME generics_type? inherit_list
 generics_type = '<' ANY '>'
 inherit_list = (':' (NAME)+ )?
 ...
 */
class SwiftClassParser: BacktrackParser {
    
    func parse() -> [ClassNode] {
        while token().type != .endOfFile {
            do {
                try definition()
            } catch {
                consume()
            }
        }
        
        distinct()
        
        return nodes
    }
    
    // MARK: - Private
    
    fileprivate var nodes: [ClassNode] = []
    fileprivate var currentNode: ClassNode? = nil
    fileprivate var protocols: [ProtocolNode] = []
    
    /// nodes去重
    fileprivate func distinct() {
        guard nodes.count > 1 else {
            return
        }
        
        var set = Set<ClassNode>()
        for node in nodes {
            if let index = set.index(of: node) {
                set[index].merge(node) // 合并相同的节点
            } else {
                set.insert(node)
            }
        }
        
        nodes = Array(set)
    }
}

// MARK: - 规则解析

fileprivate extension SwiftClassParser {
    
    func definition() throws {
        switch token().type {
        case .cls:
            let cls = try classDefinition()
            nodes.append(cls)
        case .exten:
            let cls = try extensionDefinition()
            nodes.append(cls)
        default:
            consume()
        }
    }
    
    func classDefinition() throws -> ClassNode {
        let cls = ClassNode()
        
        try match(.cls)
        cls.className = try match(.name).text
        
        try genericsType()

        let inherits = try inheritList()
        
        for index in 0..<inherits.count {
            let name = inherits[index]
            if index == 0 {
                cls.superCls = ClassNode(clsName: name)
            } else {
                cls.protocols.append(name)
            }
        }
        
        try match(.leftBrace)
        
        return cls
    }
    
    // 直接忽略泛型定义
    func genericsType() throws {
        if token().type == .leftAngle {
            try match(.leftAngle)
            
            var inside = 1
            while token().type != .endOfFile {
                if inside == 0 {
                    return
                }
                
                if token().type == .leftAngle {
                    inside += 1
                } else if token().type == .rightAngle {
                    inside -= 1
                }
                
                consume()
            }
        }
    }
    
    func extensionDefinition() throws -> ClassNode {
        try match(.exten)
        try match(.name)
        
        let cls = ClassNode(clsName: lastToken?.text ?? "")
        
        cls.protocols = try inheritList()
        try match(.leftBrace)
        
        return cls
    }
    
    func inheritList() throws -> [String] {
        var inherits: [String] = []
        
        if token().type == .colon {
            try match(.colon)
            while token().type != .endOfFile {
                try match(.name)
                inherits.append(lastToken?.text ?? "")
                
                if token().type == .comma { // 还有更多
                    consume()
                } else {
                    break
                }
            }
        }
        
        return inherits
    }
}
