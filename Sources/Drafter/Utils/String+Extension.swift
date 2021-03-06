//
//  String+Extension.swift
//  DrafterTests
//
//  Created by LZephyr on 2018/5/17.
//

import Foundation

extension String {
    /// 检查字符串是否包含关键字，忽略大小写
    ///
    /// - Parameter keywords: 关键字列表
    /// - Returns:            只要包含keywords中任意一个关键字就返回true
    func contains(_ keywords: [String]) -> Bool {
        if keywords.isEmpty {
            return true
        }
        
        for keyword in keywords {
            if self.lowercased().contains(keyword.lowercased()) {
                return true
            }
        }
        return false
    }
    
    /// 判断文件是否为swift
    var isSwift: Bool {
        return hasSuffix(".swift")
    }
    
    /// 获取该字符串的MD5值
    var md5: String {
        return MD5(self)
    }
}

extension Optional where Wrapped == String {
    /// 判断可选字符串是否为空
    var isEmpty: Bool {
        if let str = self {
            return str.count == 0
        }
        return true
    }
}

// MARK: - 比较

/// 可选和非可选的两个字符串的相等性比较
func == (_ lhs: String?, _ rhs: String) -> Bool {
    if let str = lhs {
        return str == rhs
    }
    return false
}

/// 可选和非可选的两个字符串的相等性比较
func == (_ lhs: String, _ rhs: String?) -> Bool {
    if let str = rhs {
        return str == lhs
    }
    return false
}

// MARK: - 选择

// TODO: superCls要改成非可选类型

/// 在左右两个字符串中选择一个非空的，如果都非空则返回左边的
func select(_ lhs: String?, _ rhs: String?) -> String? {
    if !lhs.isEmpty {
        return lhs
    }
    if !rhs.isEmpty {
        return rhs
    }
    return ""
}
