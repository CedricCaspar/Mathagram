//
//  GameData.swift
//  Anagrams
//
//  Created by Caroline Begbie on 12/04/2015.
//  Copyright (c) 2015 Caroline. All rights reserved.
//

import Foundation

class GameData {
  var points:Int = 0 {
    didSet {
      points = max(points, 0)
    }
  }
}
