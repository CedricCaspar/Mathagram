//
//  TargetView.swift
//  Anagrams
//
//  Created by Caroline Begbie on 12/04/2015.
//  Copyright (c) 2015 Caroline. All rights reserved.
//

import Foundation
import UIKit

class TargetView: UIImageView {
  var letter: String
    //var printletter: Character
  var isMatched:Bool = false
  
  //this should never be called
  required init(coder aDecoder:NSCoder) {
    fatalError("use init(letter:, sideLength:")
  }
  
    init(letter:String, sideLength:CGFloat) {
    self.letter = letter
    //self.printletter = printletter
    if letter != ">" {
        //the tile background
        let image = UIImage(named: "tile")!
        
        //superclass initializer
        //references to superview's "self" must take place after super.init
        super.init(image:image)
        
        //6 resize the tile
        let scale = sideLength / image.size.width
        self.frame = CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale)
        
        //add a letter on top
        let letterLabel = UILabel(frame: self.bounds)
        letterLabel.textAlignment = NSTextAlignment.center
        letterLabel.textColor = UIColor.white
        letterLabel.backgroundColor = UIColor.clear
        letterLabel.text = letter.uppercased()
        letterLabel.font = UIFont(name: "Verdana-Bold", size: 78.0*scale)
        self.addSubview(letterLabel)
        
        self.isUserInteractionEnabled = true
        
        //create the tile shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
        self.layer.shadowRadius = 15.0
        self.layer.masksToBounds = false
        
        let path = UIBezierPath(rect: self.bounds)
        self.layer.shadowPath = path.cgPath

    }else{
    let image = UIImage(named: "slot")!
    super.init(image:image)
    
    let scale = sideLength / image.size.width
    self.frame = CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale)
    }
  }
}
