//
//  ScorePanel.swift
//  Codenames
//
//  Created by Simon Bonnedahl on 2021-12-29.
//  Copyright © 2021 Google. All rights reserved.
//

import Foundation
import UIKit

class ScorePanel: UIView{
    let width:Int
    let height:Int
    var rScore:Int
    var bScore:Int
    var redScore:UITextField
    var blueScore:UITextField
    var seperator:UITextField
    var red = UIColor(red: 255/255, green: 46/255, blue: 46/255, alpha: 0.8)
    var blue = UIColor(red: 0/255, green: 180/255, blue: 255/255, alpha: 0.8)
    var white = UIColor(red: 236/255, green: 220/255, blue: 199/255, alpha: 0.8)
    
    required init(blueScore:Int, redScore:Int, width:Int, height:Int){
        self.bScore = blueScore
        self.rScore = redScore
        self.width = width
        self.height = height
        let fontSize = CGFloat(width/5)
        self.redScore = UITextField(frame: CGRect(x: (height/3),
                                                  y: 0,
                                                  width: width/3,
                                                  height: height))
        self.redScore.text = String(redScore)
        self.redScore.font = UIFont.boldSystemFont(ofSize:(fontSize))
        self.redScore.textColor = red
        
        self.seperator = UITextField(frame: CGRect(x: (height/3) + (width/3),
                                                  y: 0,
                                                  width: width/3,
                                                  height: height))
        self.seperator.text = " : "
        self.seperator.font = UIFont.boldSystemFont(ofSize:(fontSize))
        self.seperator.textColor = white
        
        self.blueScore = UITextField(frame: CGRect(x: (height/3) + (2*(width/3)),
                                                  y: 0,
                                                  width: width/3,
                                                  height: height))
        self.blueScore.text = String(blueScore)
        self.blueScore.font = UIFont.boldSystemFont(ofSize:(fontSize))
        self.blueScore.textColor = blue
        
       
       
        super.init(frame: CGRect(x: 0,
                                 y: 460,
                                 width: width,
                                 height: height))
        addSubview(self.redScore)
        addSubview(self.seperator)
        addSubview(self.blueScore)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    func decreaseBlueScore(){
        bScore -= 1
        self.blueScore.text = String(bScore)
        
    }
    func decreaseRedScore(){
        rScore -= 1
        self.redScore.text = String(rScore)
    }
}
