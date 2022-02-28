//
//  Cell.swift
//  Codenames
//
//  Created by Simon Bonnedahl on 2021-12-28.
import UIKit

class Cell: UIButton{
    let id:Int
    let posX:Int
    let posY:Int
    let size:Int
    var color1:UIColor
    var color2:UIColor
    var text:String
    var type:String
    
    required init(id:Int, posX:Int, posY:Int, size:Int, color1:UIColor, color2:UIColor, text:String, type:String){
        self.id = id
        self.posX = posX
        self.posY = posY
        self.size = size
        self.color1 = color1
        self.color2 = color2
        self.text = text
        self.type = type
        super.init(frame: CGRect(x: posX,
                                 y: posY,
                                 width: size,
                                 height: size))

        setTitle(self.text, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize:(9.0))
        layer.cornerRadius = 10
        backgroundColor = self.color1
        
        doGlowAnimation(withColor: self.color1)
        

        
    }
    required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    
    func getData()->String{
        var str = ""
        str += String(self.id) + ":"
        str += self.type
        return str
    }
    
    func startGradientAnimation(color1:UIColor, color2:UIColor){
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.cornerRadius = 10
        gradient.colors = [
            color1.cgColor,
            color2.cgColor
        ]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        layer.insertSublayer(gradient, at: 0)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 5
        gradientChangeAnimation.toValue = [
            color2.cgColor,
            color1.cgColor
            ]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.repeatCount = .infinity
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
   
    }
}
extension Cell {
    enum GlowEffect: Float {
        case small = 0.4, normal = 2, big = 4
    }

    func doGlowAnimation(withColor color: UIColor, withEffect effect: GlowEffect = .normal) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0.7
        layer.shadowOffset = .zero

        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.repeatCount = .infinity
        glowAnimation.fromValue = 0
        glowAnimation.toValue = effect.rawValue
        glowAnimation.beginTime = CACurrentMediaTime()+0.3
        glowAnimation.duration = CFTimeInterval(2)
        glowAnimation.fillMode = .removed
        glowAnimation.autoreverses = true
        layer.add(glowAnimation, forKey: "shadowGlowingAnimation")
    }
}
