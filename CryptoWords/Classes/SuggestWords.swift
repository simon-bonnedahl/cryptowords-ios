//
//  SuggestWords.swift
//  Codenames
//
//  Created by Simon Bonnedahl on 2022-03-07.
//  Copyright © 2022 Google. All rights reserved.
//

import Foundation
import UIKit

class SuggestWords: UIViewController{
    

    public var delegate: SuggestWordsDelegate?
    
    var languageField: UITextField!
    var wordField: UITextField!
    var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tag = 10;
        hideKeyboardWhenTappedAround()
        self.languageField = UITextField(frame: CGRect(x: 100,
                                                       y: 30,
                                                       width: 200,
                                                       height: 40))
        self.wordField = UITextField(frame: CGRect(x: 100,
                                                   y: 100,
                                                   width: 200,
                                                   height: 40))
        self.submitButton = UIButton(frame: CGRect(x: 150,
                                                   y: 200,
                                                   width: 100,
                                                   height: 40))
        self.languageField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.languageField.textColor = UIColor.white
        self.languageField.placeholder = "Language"
        self.languageField.textAlignment = NSTextAlignment.center
        self.wordField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.wordField.textColor = UIColor.white
        self.wordField.placeholder = "Word"
        self.wordField.textAlignment = NSTextAlignment.center
        self.submitButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.submitButton.setTitle("Submit", for: UIControl.State.normal)
        self.submitButton.titleLabel?.textColor = UIColor.white
        self.submitButton.addTarget(self,
                         action: #selector(submit),
                         for: .touchUpInside)
        
        view.frame = CGRect(x: 0,
                                 y: 75,
                                 width: 400,
                                 height: 400)
        
        view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        
        view.addSubview(languageField)
        view.addSubview(wordField)
        view.addSubview(submitButton)
    }
    
    @objc
    func submit(){
        if(wordField.text!.isEmpty || languageField.text!.isEmpty){
            print("fields empty")
        }else{
        self.view.isHidden = true
        delegate?.addSuggestion(language: languageField.text!, word: wordField.text!);
        }
    }
 
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
