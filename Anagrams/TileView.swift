//
//  TileView.swift
//  Anagrams
//
//  Created by Caroline Begbie on 12/04/2015.
//  Copyright (c) 2015 Caroline. All rights reserved.
//

import Foundation
import UIKit

protocol TileDragDelegateProtocol {
  func tileView(_ tileView: TileView, didDragToPoint: CGPoint)
}

class TileView:UIImageView {
  var letter: String
  
  var isMatched: Bool = false
    var isCorrect:Bool = false
  fileprivate var xOffset: CGFloat = 0.0
  fileprivate var yOffset: CGFloat = 0.0
  
  var dragDelegate: TileDragDelegateProtocol?
  
  fileprivate var tempTransform: CGAffineTransform = CGAffineTransform.identity
  
  required init(coder aDecoder:NSCoder) {
    fatalError("use init(letter:, sideLength:")
  }
  
  init(letter:String, sideLength:CGFloat) {
    self.letter = letter
    
    let image = UIImage(named: "tile")!
    
    super.init(image:image)
    
    let scale = sideLength / image.size.width
    self.frame = CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale)
    
    let letterLabel = UILabel(frame: self.bounds)
    letterLabel.textAlignment = NSTextAlignment.center
    letterLabel.textColor = UIColor.white
    letterLabel.backgroundColor = UIColor.clear
    letterLabel.text = letter.uppercased()
    letterLabel.font = UIFont(name: "Verdana-Bold", size: 78.0*scale)
    self.addSubview(letterLabel)
    
    self.isUserInteractionEnabled = true
    
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOpacity = 0
    self.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
    self.layer.shadowRadius = 15.0
    self.layer.masksToBounds = false
    
    let path = UIBezierPath(rect: self.bounds)
    self.layer.shadowPath = path.cgPath
    
  }
  
  func randomize() {
    let rotation = CGFloat(randomNumber(minX:0, maxX:50)) / 100.0 - 0.2
    self.transform = CGAffineTransform(rotationAngle: rotation)
    
    let yOffset = CGFloat(randomNumber(minX: 0, maxX: 10) - 10)
    self.center = CGPoint(x: self.center.x, y: self.center.y + yOffset)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent!) {
    if let touch = touches.first {
      let point = touch.location(in: self.superview)
      xOffset = point.x - self.center.x
      yOffset = point.y - self.center.y
      
    }
    self.layer.shadowOpacity = 0.8
    
    tempTransform = self.transform
    self.transform = self.transform.scaledBy(x: 1.2, y: 1.2)

    self.superview?.bringSubview(toFront: self)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent!) {
    if let touch = touches.first  {
      let point = touch.location(in: self.superview)
      self.center = CGPoint(x: point.x - xOffset, y: point.y - yOffset)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent!) {
    self.touchesMoved(touches, with: event)
    
    self.transform = tempTransform
    
    dragDelegate?.tileView(self, didDragToPoint: self.center)
    self.layer.shadowOpacity = 0.0
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent!) {
    self.transform = tempTransform
    self.layer.shadowOpacity = 0.0
  }
}
