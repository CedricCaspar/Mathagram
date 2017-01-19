//
//  String+Path.swift
//  Anagrams
//
//  Created by Michael on 28.11.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import Foundation

extension String {
    func stringByAppendingPathComponent(pathComponent: String) -> String {
        return (self as NSString).appendingPathComponent(pathComponent)
    }
}
