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
    var withAlwaysCheck: Bool = false
  fileprivate var tiles = [TileView]()
  fileprivate var targets = [TargetView]()
  
  var hud:HUDView! {
    didSet {
      hud.hintButton.addTarget(self, action: #selector(GameController.actionHint), for:.touchUpInside)
      hud.hintButton.isEnabled = false
    }
  }
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

    let anastr = anagramPair[3] as! Array<String>
    let anacont = anagramPair[2] as! Array<String>
    self.analös = anagramPair[1] as! Array<Array<String>>
    
    let anagram1length = anastr.count
    let anagram2length = anacont.count

    let tileSide = ceil(ScreenWidth * 0.9 / CGFloat(max(anagram1length, anagram2length))) - TileMargin
    
    var xOffset = (ScreenWidth - CGFloat(max(anagram1length, anagram2length)) * (tileSide + TileMargin)) / 2.0
    
    xOffset += tileSide / 2.0
    
    targets = []
    
    for (index, letter) in anacont.enumerated() {
      if letter != " " {

        let target = TargetView(letter: letter, sideLength: tileSide)
        target.center = CGPoint(x: xOffset + CGFloat(index)*(tileSide + TileMargin), y: ScreenHeight/4)
        gameView.addSubview(target)
        targets.append(target)
        if letter != ">" {
            target.isMatched = true
            target.isCorrect = true
        }
      }
    }
    tiles = []
    for (index, letter) in anastr.enumerated() {
        
        let tile = TileView(letter: letter, sideLength: tileSide)
        tile.center = CGPoint(x: xOffset + CGFloat(index)*(tileSide + TileMargin), y: ScreenHeight/4*3)
        
        tile.randomize()
        tile.dragDelegate = self
        tiles.append(tile)
        gameView.addSubview(tile)
        }
    self.startStopwatch()
    hud.hintButton.isEnabled = true
    }
    func placeTile(_ tileView: TileView, targetView: TargetView, correct: Bool) {
        targetView.isMatched = true
        tileView.isMatched = true
        targetView.isCorrect = correct
        tileView.isCorrect = correct
        tileView.isUserInteractionEnabled = false
    
        UIView.animate(withDuration: 0.35,
                       delay:0.00,
                       options:UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        tileView.center = targetView.center
                        tileView.transform = CGAffineTransform.identity
        }, completion: {
            (value:Bool) in
            targetView.isHidden = true
        })
    
        let explode = ExplodeView(frame:CGRect(x: tileView.center.x, y: tileView.center.y, width: 10,height: 10))
        tileView.superview?.addSubview(explode)
        tileView.superview?.sendSubview(toBack: explode)
    }
  
  
  
  func checkForSuccess() {
    for targetView in targets {
      if !targetView.isCorrect {
        return
      }
    }
    print("Game Over!")
    
    hud.hintButton.isEnabled = false
    self.stopStopwatch()
    
    audioController.playEffect(SoundWin)
    
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
        stars.removeFromSuperview()
        self.clearBoard()
        self.onAnagramSolved()
    })
  }

  func startStopwatch() {
    secondsLeft = level.timeToSolve
    hud.stopwatch.setSeconds(secondsLeft)
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
  
  @objc func actionHint() {
    hud.hintButton.isEnabled = false
    self.stopStopwatch()
    self.clearBoard()
    self.dealRandomAnagram()
  }
  
  func clearBoard() {
    tiles.removeAll(keepingCapacity: false)
    targets.removeAll(keepingCapacity: false)
    
    for view in gameView.subviews  {
      view.removeFromSuperview()
    }
  }
  
}

extension GameController:TileDragDelegateProtocol {
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
    
    let anagramPair = level.anagrams[self.randomIndex]
    let anacont = anagramPair[2] as! Array<String>

    if let targetView = targetView {
        var checkPosition = 0
        for checkIndex in 0 ... targetIndex {
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
        self.placeTile(tileView, targetView: targetView, correct: isSolution)
        var analösKopie: Array<Array<String>> = []
        var remainIndexes: Array<Int> = []
        for solstring2 in 0 ... analös.count - 1{
            let letter = analös[solstring2][checkPosition]
            if letter == correctFoundLetter && correctFoundLetter != "a"{
            remainIndexes.append(solstring2)
            }
        }
        for i in 0 ... remainIndexes.count - 1{
        analösKopie.append(analös[remainIndexes[i]])
        }
        analös = analösKopie
        audioController.playEffect(SoundDing)
        self.checkForSuccess()
      } else {
        
/*
        tileView.randomize()
        
        UIView.animate(withDuration: 0.35,
          delay:0.00,
          options:UIViewAnimationOptions.curveEaseOut,
          animations: {
            tileView.center = CGPoint(x: tileView.center.x + CGFloat(randomNumber(minX:0, maxX:40)-20),
              y: tileView.center.y + CGFloat(randomNumber(minX:20, maxX:30)))
          },
          completion: nil)
*/
        self.placeTile(tileView, targetView: targetView, correct: isSolution)
        
        audioController.playEffect(SoundDing)
        self.checkForSuccess()

      }
     }
  }
}
