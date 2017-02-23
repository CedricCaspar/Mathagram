

import UIKit

class HUDView: UIView {
  
  var stopwatch: StopwatchView
  
  var hintButton: UIButton!
  
  required init(coder aDecoder:NSCoder) {
    fatalError("use init(frame:")
  }
  
  override init(frame:CGRect) {
    self.stopwatch = StopwatchView(frame:CGRect(x: ScreenWidth/2-150, y: 0, width: 300, height: 100))
    self.stopwatch.setSeconds(0)
    
    super.init(frame:frame)
    self.addSubview(self.stopwatch)
    
    self.isUserInteractionEnabled = true
    
    let hintButtonImage = UIImage(named: "btn")!
    
    self.hintButton = UIButton(type: .system)
    hintButton.setTitle("Restart!", for:UIControlState())
    hintButton.titleLabel?.font = FontHUD
    hintButton.setBackgroundImage(hintButtonImage, for: UIControlState())
    hintButton.frame = CGRect(x: 50, y: 30, width: hintButtonImage.size.width, height: hintButtonImage.size.height)
    hintButton.alpha = 0.8
    self.addSubview(hintButton)
  }
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    
    if hitView is UIButton {
      return hitView
    }
    
    return nil
  }
  
}
