//
//  InfoViewController.swift
//  Codenames
//
//  Created by Simon Bonnedahl on 2022-03-04.
//  Copyright © 2022 Google. All rights reserved.
//

import Foundation
import UIKit

class InfoViewController: UIViewController{
     
    var howToPlay: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =  UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 00)
        view.tag = 10
        howToPlay = UITextView(frame: CGRect(x: 0,
                                              y: 75,
                                             width: view.bounds.maxX,
                                              height: 540))
        let string = "NEW GAME: \n\nTo start a new game you need to connect to a chromecast device on your local network. To do that you press the Cast Icon in the top-right corner. Choose a language in the menu and press the start button.\n\nGAME RULES: \n\nTwo teams of similar skill and size compete against each other. Each team need atleast 2 players for a regular game. Each team chose a leader. If you are the leader you have access to the playing device and can see the colors on the grid. The codemaster's job is to say a 1-word clue that can relate to the words of your color. You also say how many words the clue relates to.\nEXAMPLE: If you have plane and car you can say vehicle:2.\nWhen a team makes a guess, the leader press that word on the playing device.\nThe team with 9 words on the board goes first and the team that first cover all of their words on the grid wins. If your team guess on the word corresponding to the black square(the bomb), you lose. On your turn you are allowed to guess as many words as you want as long as they are correct, if not the turn goes over to the opponent team."
       
        howToPlay?.text = string
        
        howToPlay?.font = UIFont.systemFont(ofSize:(14))
        howToPlay?.textColor = UIColor.white
        howToPlay?.isEditable = false;
        howToPlay?.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
        howToPlay?.layer.cornerRadius = 8
        
        view.addSubview(howToPlay!)
        
        let button = UIButton(frame: CGRect(x: view.bounds.maxX/2,
                                            y: 570,
                                            width: 50,
                                            height: 35))
         button.setTitle("OK",
                         for: .normal)
         button.layer.borderWidth = 2
        button.layer.cornerRadius = 2
         button.addTarget(self,
                          action: #selector(goBack),
                          for: .touchUpInside)
          button.setTitleColor(UIColor.white, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
          button.center.x = self.view.center.x
          self.view.addSubview(button)
    }
    
    @objc
    func goBack(){
        self.view.isHidden = true;
    }
    

    
    
    
}
