//
//  ViewController.swift
//  Anagrams
//
//  Created by Caroline on 1/08/2014.
//  Copyright (c) 2014 Caroline. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  fileprivate let amountOfLevels: Int = 4

  fileprivate let controller:GameController
    
  required init?(coder aDecoder: NSCoder) {
    controller = GameController()
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let gameView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
    self.view.addSubview(gameView)
    controller.gameView = gameView

    let hudView = HUDView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
    self.view.addSubview(hudView)
    controller.hud = hudView
    controller.onAnagramSolved = self.showLevelMenu
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.showLevelMenu()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override var prefersStatusBarHidden : Bool {
    return true
  }

  func showLevelMenu() {
    let alertController = UIAlertController(title: "Choose Level",
      message: nil,
      preferredStyle:UIAlertControllerStyle.alert)
    for level in 1 ... amountOfLevels {
        if level <= 5{
        let oneLevel = UIAlertAction(title: "Level \(level)", style:.default,
                                 handler: {(alert:UIAlertAction!) in
                                    self.showLevel(level)})
    
    alertController.addAction(oneLevel)
        }else{
            let zweiLevel = UIAlertAction(title: "Level \(level)", style:.default,
                                         handler: {(alert:UIAlertAction!) in
                                            self.showLevel(5)})
            
            alertController.addAction(zweiLevel)
        }
    }
    self.present(alertController, animated: true, completion: nil)
  }
  
  func showLevel(_ levelNumber:Int) {
    controller.level = Level(levelNumber: levelNumber)
    controller.dealRandomAnagram()
  }
}

