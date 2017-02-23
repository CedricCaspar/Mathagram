import UIKit

class StopwatchView: UILabel {
  
  required init(coder aDecoder:NSCoder) {
    fatalError("use init(frame:")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.clear
    self.font = FontHUDBig
  }
  
  func setSeconds(_ seconds:Int) {
    self.text = String(format: " %02i : %02i", seconds/60, seconds % 60)
  }
}
