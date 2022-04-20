//
//  RootContainerViewController.swift
//  Codenames
//
//  Created by Simon Bonnedahl on 2021-12-28.



import GoogleCast
import UIKit

@objc(RootContainerViewController)
class RootContainerViewController: UIViewController{
var globalBackgroundColor1 = UIColor(red: 78/255, green: 67/255, blue: 118/255, alpha: 1)
var globalBackgroundColor2 = UIColor(red: 43/255, green: 88/255, blue: 118/255, alpha: 1)

  override func viewDidLoad() {
    super.viewDidLoad()
      setGradientBackground()
      if let delegate = UIApplication.shared.delegate as? AppDelegate {
          delegate.orientationLock = .portrait
              }
      
 
  }
    func setGradientBackground(){
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [
            globalBackgroundColor2.cgColor,
            globalBackgroundColor1.cgColor,
        ]
        gradient.startPoint = CGPoint(x:0.0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        self.view.layer.insertSublayer(gradient, at: 0)

        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 4
        gradientChangeAnimation.toValue = [
            globalBackgroundColor1.cgColor,
            globalBackgroundColor2.cgColor,

            ]


        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.repeatCount = .infinity
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
    }
    

    
}
