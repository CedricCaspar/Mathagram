//
//  Level.swift
//  Anagrams
//
//  Created by Caroline Begbie on 12/04/2015.
//  Copyright (c) 2015 Caroline. All rights reserved.
//

import Foundation
struct Level {

  let timeToSolve: Int
  let anagrams: [NSArray]
  
  init(levelNumber: Int) {
    let fileName = "level\(levelNumber).plist"
    let levelPath = "\(Bundle.main.resourcePath!)/\(fileName)"
    
    let levelDictionary: NSDictionary? = NSDictionary(contentsOfFile: levelPath)
    
    assert(levelDictionary != nil, "Level configuration file not found")
    
    self.timeToSolve = levelDictionary!["timeToSolve"] as! Int
    self.anagrams = levelDictionary!["anagrams"] as! [NSArray]
  }
}


