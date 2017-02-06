//
//  GameController.swift
//  Anagrams
//
//  Created by Caroline Begbie on 12/04/2015.
//  Copyright (c) 2015 Caroline. All rights reserved.
//

import Foundation
import UIKit

class GameController {
  var gameView: UIView!
  var level: Level!
  
  fileprivate var tiles = [TileView]()
  fileprivate var targets = [TargetView]()
  
  var hud:HUDView! {
    didSet {
      //connect the Hint button
      hud.hintButton.addTarget(self, action: #selector(GameController.actionHint), for:.touchUpInside)
      hud.hintButton.isEnabled = false
    }
  }
  
  //stopwatch variables
  fileprivate var secondsLeft: Int = 0
  fileprivate var timer: Timer?
  
  fileprivate var data = GameData()
  
  fileprivate var audioController: AudioController
    fileprivate var analös: Array<Array<String>> = []
    var randomIndex: Int
  var onAnagramSolved:( () -> ())!
  
  init() {
    self.audioController = AudioController()
    self.audioController.preloadAudioEffects(AudioEffectFiles)
    self.analös = []
    self.randomIndex = 0
  }
  
  func dealRandomAnagram () {
    
    assert(level.anagrams.count > 0, "no level loaded")
    
    self.randomIndex = randomNumber(minX:0, maxX:UInt32(level.anagrams.count-1))
    let anagramPair = level.anagrams[self.randomIndex]
    //let alreadySolved = anagramPair[0] as! Bool
    
    
    
    let anastr = anagramPair[3] as! Array<String>
    let anacont = anagramPair[2] as! Array<String>
    self.analös = anagramPair[1] as! Array<Array<String>>
    
    
    let anagram1length = anastr.count
    let anagram2length = anacont.count

    //self.anagram4 = anagramPair[0] as! Array<String>
    

    let tileSide = ceil(ScreenWidth * 0.9 / CGFloat(max(anagram1length, anagram2length))) - TileMargin
    
    var xOffset = (ScreenWidth - CGFloat(max(anagram1length, anagram2length)) * (tileSide + TileMargin)) / 2.0
    
    xOffset += tileSide / 2.0
    
    //initialize target list
    targets = []
    
    //create targets
    for (index, letter) in anacont.enumerated() {
      if letter != " " {

        let target = TargetView(letter: letter, sideLength: tileSide)

        target.center = CGPoint(x: xOffset + CGFloat(index)*(tileSide + TileMargin), y: ScreenHeight/4)
        
        gameView.addSubview(target)
        targets.append(target)
        if letter != ">" {
            target.isMatched = true
        }
      }
    }
    
    //1 initialize tile list
    tiles = []
    
    //2 create tiles
    for (index, letter) in anastr.enumerated() {
        
    
        let tile = TileView(letter: letter, sideLength: tileSide)
        tile.center = CGPoint(x: xOffset + CGFloat(index)*(tileSide + TileMargin), y: ScreenHeight/4*3)
        
        tile.randomize()
        tile.dragDelegate = self
        
        //4
        
        tiles.append(tile)
        gameView.addSubview(tile)
    
      
    }
    
    //start the timer
    self.startStopwatch()
    
    hud.hintButton.isEnabled = true
    
  }
    



  func placeTile(_ tileView: TileView, targetView: TargetView) {
    //1
    targetView.isMatched = true
    tileView.isMatched = true
    
    //2
    tileView.isUserInteractionEnabled = false
    
    //3
    UIView.animate(withDuration: 0.35,
      delay:0.00,
      options:UIViewAnimationOptions.curveEaseOut,
      //4
      animations: {
        tileView.center = targetView.center
        tileView.transform = CGAffineTransform.identity
      },
      //5
      completion: {
        (value:Bool) in
        targetView.isHidden = true
    })
    
    let explode = ExplodeView(frame:CGRect(x: tileView.center.x, y: tileView.center.y, width: 10,height: 10))
    tileView.superview?.addSubview(explode)
    tileView.superview?.sendSubview(toBack: explode)
  }
  
  
  
  func checkForSuccess() {
    for targetView in targets {
      //no success, bail out
      if !targetView.isMatched {
        return
      }
    }
    print("Game Over!")
    
    hud.hintButton.isEnabled = false
    
    //stop the stopwatch
    self.stopStopwatch()
    
    //the anagram is completed!
    audioController.playEffect(SoundWin)
    
    // win animation
    let firstTarget = targets[0]
    let startX:CGFloat = 0
    let endX:CGFloat = ScreenWidth + 300
    let startY = firstTarget.center.y
    
    let stars = StardustView(frame: CGRect(x: startX, y: startY, width: 10, height: 10))
    gameView.addSubview(stars)
    gameView.sendSubview(toBack: stars)
    
    UIView.animate(withDuration: 3.0,
      delay:0.0,
      options:UIViewAnimationOptions.curveEaseOut,
      animations:{
        stars.center = CGPoint(x: endX, y: startY)
      }, completion: {(value:Bool) in
        //game finished
        stars.removeFromSuperview()

        //when animation is finished, show menu
        self.clearBoard()
        self.onAnagramSolved()
    })
  }

  func startStopwatch() {
    //initialize the timer HUD
    secondsLeft = level.timeToSolve
    hud.stopwatch.setSeconds(secondsLeft)
    
    //schedule a new timer
    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(GameController.tick(_:)), userInfo: nil, repeats: true)
  }
  
  func stopStopwatch() {
    timer?.invalidate()
    timer = nil
  }
  
  @objc func tick(_ timer: Timer) {
    secondsLeft -= 1
    hud.stopwatch.setSeconds(secondsLeft)
    if secondsLeft == 0 {
      self.stopStopwatch()
    }
  }
  
  //the user pressed the hint button
  @objc func actionHint() {
    //1
    hud.hintButton.isEnabled = false
    
    //2

/*
    
    //3 find the first unmatched target and matching tile
    var foundTarget:TargetView? = nil
    for target in targets {
      if !target.isMatched {
        foundTarget = target
        break
      }
    }
    
    //4 find the first tile matching the target
    var foundTile:TileView? = nil
    for tile in tiles {
      if !tile.isMatched && tile.letter == foundTarget?.letter {
        foundTile = tile
        break
      }
    }
    
    //ensure there is a matching tile and target
    if let target = foundTarget, let tile = foundTile {
      
      //5 don't want the tile sliding under other tiles
      gameView.bringSubview(toFront: tile)
      
      //6 show the animation to the user
      UIView.animate(withDuration: 1.5,
        delay:0.0,
        options:UIViewAnimationOptions.curveEaseOut,
        animations:{
          tile.center = target.center
        }, completion: {
          (value:Bool) in
          
          //7 adjust view on spot
          self.placeTile(tile, targetView: target)
          
          //8 re-enable the button
          self.hud.hintButton.isEnabled = true
          
          //9 check for finished game
          self.checkForSuccess()
 
          
      })
    }
 */
  }
  
  //clear the tiles and targets
  func clearBoard() {
    tiles.removeAll(keepingCapacity: false)
    targets.removeAll(keepingCapacity: false)
    
    for view in gameView.subviews  {
      view.removeFromSuperview()
    }
  }
  
}

extension GameController:TileDragDelegateProtocol {
  //a tile was dragged, check if matches a target
  func tileView(_ tileView: TileView, didDragToPoint point: CGPoint) {
    var targetView: TargetView?
    var targetIndex = 0
    for tv in targets {
      if tv.frame.contains(point) && !tv.isMatched {
        targetView = tv
        break
        
      }
    targetIndex += 1
    }
    //self.randomIndex = randomNumber(minX:0, maxX:UInt32(level.anagrams.count-1))
    let anagramPair = level.anagrams[self.randomIndex]
    let anacont = anagramPair[2] as! Array<String>

    // wievieltes Leeres Feld es ist und ob es Lösung ist
    if let targetView = targetView {
        var checkPosition = 0
        for checkIndex in 0 ... targetIndex {
            //let letterIndex = anagram3.index(anagram3.startIndex, offsetBy: checkIndex)
            //let letter = anagram3.characters[letterIndex]
            let letter = anacont[checkIndex]
            if letter == ">" {
                if checkIndex == 0{
                    checkPosition = 0
                }else{
                    checkPosition += 1
                }
            }else{
            continue
            }
        }
        var isSolution:Bool = false
        var correctFoundLetter: String = "a"
        for solarray in 0 ... analös.count - 1{
            //let checkPositionIndex = anagram4[solstring].index(anagram4[solstring].startIndex, offsetBy: checkPosition)
            //let letter = anagram4[solstring].characters[checkPositionIndex]
            let letter = analös[solarray][checkPosition]
            if letter == tileView.letter {
            isSolution = true
            correctFoundLetter = letter
            break
            }else{
            continue
            }
        }

      if isSolution == true{
        
        //3
        self.placeTile(tileView, targetView: targetView)
        var analösKopie: Array<Array<String>> = []
        var remainIndexes: Array<Int> = []
        //noch übrige möglichen Lösungen eingrenzen
        for solstring2 in 0 ... analös.count - 1{
            //let checkPositionIndex = anagram4[solstring2].index(anagram4[solstring2].startIndex, offsetBy: checkPosition, limitedBy: anagram4[solstring2].endIndex)
            let letter = analös[solstring2][checkPosition]
            if letter == correctFoundLetter && correctFoundLetter != "a"{
            remainIndexes.append(solstring2)
            }
        }
        for i in 0 ... remainIndexes.count - 1{
        analösKopie.append(analös[remainIndexes[i]])
        }
        analös = analösKopie

        
        //more stuff to do on success here
        
        audioController.playEffect(SoundDing)
        
        //give points

        
        //check for finished game
        self.checkForSuccess()
      
      } else {
        
        //4
        //1
        tileView.randomize()
        
        //2
        UIView.animate(withDuration: 0.35,
          delay:0.00,
          options:UIViewAnimationOptions.curveEaseOut,
          animations: {
            tileView.center = CGPoint(x: tileView.center.x + CGFloat(randomNumber(minX:0, maxX:40)-20),
              y: tileView.center.y + CGFloat(randomNumber(minX:20, maxX:30)))
          },
          completion: nil)
        
        //more stuff to do on failure here
        
        audioController.playEffect(SoundWrong)
        
        //take out points

      }
    }
    
  }
  

}
