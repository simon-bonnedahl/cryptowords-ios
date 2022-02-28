//
//  GameViewController.swift
//  Codenames
//
//  Created by Simon Bonnedahl on 2021-12-28.

import GoogleCast
import UIKit
import Firebase

@available(iOS 13.0, *)
@objc(GameViewController)
class GameViewController: UIViewController, GCKSessionManagerListener, GCKRequestDelegate{
  private var sessionManager: GCKSessionManager!
  private var messageChannel: GCKCastChannel!
  private var titleView: UIView!
  private var castButton: GCKUICastButton!
  private var languageButton: UIButton!
  var currentLanguage = "English"
    
 @IBOutlet var languages: [UIButton]!
   
var scorePanel: ScorePanel!
var startingTeam:String!
var words: [String]!
var initWords = [String](repeating: "", count: 25)

    var grid:UICollectionView!
    
    var red1 = UIColor(red: 255/255, green: 46/255, blue: 46/255, alpha: 0.9)
    var red2 = UIColor(red: 254/255, green: 90/255, blue: 90/255, alpha: 0.9)
    var blue1 = UIColor(red: 0/255, green: 180/255, blue: 255/255, alpha: 0.9)
    var blue2 = UIColor(red: 70/255, green: 200/255, blue: 239/255, alpha: 0.9)
    var white1 = UIColor(red: 236/255, green: 220/255, blue: 199/255, alpha: 0.9)
    var white2 = UIColor(red: 171/255, green: 161/255, blue: 146/255, alpha: 0.9)
    var bombGray1 = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.9)
    var bombGray2 = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0.9)
    
    
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    sessionManager = GCKCastContext.sharedInstance().sessionManager
  }

    override func viewDidLoad() {
    super.viewDidLoad()
        
        
    
    sessionManager.add(self)
    messageChannel = GCKCastChannel(namespace: appDelegate!.namespace)
    titleView = navigationItem.titleView
    castButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                                 width: CGFloat(24), height: CGFloat(24)))
    castButton.tintColor = UIColor.white
      
        languageButton = UIButton(type: .custom)
    languageButton.bounds = CGRect(x: 0, y: 0, width: 24, height: 24)
      
     
        let languageImage = UIImage(systemName: "globe", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24.0))
        languageButton.setImage(languageImage, for: .normal)
        languageButton.tintColor = UIColor.white
        languageButton.addTarget(self,
                   action: #selector(settingsClicked),
                   for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: languageButton)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
    
        
        languages.forEach { language in
            language.isHidden = true
            language.layer.cornerRadius = 20
            
        }
    getWords(language:currentLanguage)
    createGrid(words: initWords)
    createStartButton()
     
  }
    
  func getWords(language:String){
    let db = Firestore.firestore()
    let ref = db.collection("Languages").document(language)
    print(db)
    print(ref)
    ref.getDocument { (document, error) in
        if let document = document, document.exists {
            self.words = (document.get("words") as! [String])
                  print("LOADING DONE")
                  return
        } else {
            print("Document does not exist")
        }
            
    }
    }
    
    func getRandomWords()->[String]{
        var randomWords = [String]()
        for _ in 1...25{
            while(true){
                let randomIndex =  Int.random(in: 0..<self.words.count)
                let word = self.words[randomIndex]
                if(randomWords.contains(word)){
                    continue
                }
                randomWords.append(word)
                break
            }
        }
        return randomWords;
    }
    
    func createGrid(words:[String]){
        var cells = [Cell]()
        grid = UICollectionView(frame: CGRect(x: 1,
                                                  y: 80,
                                                  width: min(600, self.view.bounds.width),
                                                  height: min(600, self.view.bounds.width)), collectionViewLayout: UICollectionViewLayout())
        grid.center.x = self.view.center.x
        let cellsize = Int(grid.bounds.width/5)
        for y in 0...4{
            for x in 0...4{
                let cell = Cell(id:(y*5) + x, posX: x*cellsize, posY: y*cellsize, size: cellsize-4,color1: white1, color2:white2, text: words[(y*5)+x], type: "default")
                cell.addTarget(self,
                               action: #selector(sendCellData),
                                 for: .touchUpInside)
                cell.titleLabel?.font = UIFont.boldSystemFont(ofSize:(cell.bounds.width/9))
                cells.append(cell)
            }
        }
        self.view.addSubview(grid)
        var redButtons, blueButtons, whiteButtons :Int
        if(Bool.random() == true ){
                redButtons = 9
                blueButtons = 8
                startingTeam = "red"
        }else{
                redButtons = 8
                blueButtons = 9
                startingTeam = "blue"
        }
        scorePanel = ScorePanel(blueScore: blueButtons, redScore: redButtons, width: Int(grid.bounds.width/1.25), height: Int(grid.bounds.width/4))
        scorePanel.center.x = self.view.center.x
        scorePanel.center.y = grid.center.y + (grid.bounds.height/2) + 70
        self.view.addSubview(scorePanel)

        whiteButtons = 7
        cells.shuffle()
        for cell in cells{
            if(blueButtons > 0){
                cell.startGradientAnimation(color1:blue1, color2:blue2)
                cell.type = "blue"
                blueButtons -= 1
                cell.setTitleColor(UIColor.black, for: .normal)
              }else if(redButtons > 0){
                  cell.startGradientAnimation(color1:red1, color2:red2)
                  cell.type = "red"
                  redButtons -= 1
                  cell.setTitleColor(UIColor.black, for: .normal)
              }else if(whiteButtons > 0){
                  cell.startGradientAnimation(color1:white1, color2:white2)
                  cell.type = "white"
                  cell.setTitleColor(UIColor.black, for: .normal)
                  whiteButtons -= 1
              }else{
                  cell.startGradientAnimation(color1:bombGray1, color2:bombGray2)
                  cell.type = "bomb"
              }
            
            grid.addSubview(cell)
        }
        grid.backgroundColor = UIColor.clear
        
    }
    
    func createStartButton(){
        let button = UIButton(frame: CGRect(x: 140,
                                            y: grid.center.y + (grid.bounds.height/2) + 140,
                                            width: (grid.bounds.width/3),
                                            height: (grid.bounds.width/8)))
         button.setTitle("Start",
                         for: .normal)
         button.layer.borderWidth = 1
         button.layer.cornerRadius = 20
          
         button.addTarget(self,
                          action: #selector(sendInit),
                          for: .touchUpInside)
          button.backgroundColor = white1
          button.setTitleColor(UIColor.black, for: .normal)
          button.center.x = self.view.center.x
          self.view.addSubview(button)
    }
    
    @objc
    func sendInit(){
        for view in self.view.subviews{
            if(view.tag != 10){
                view.removeFromSuperview()
            }
        }
        var randomWords = initWords
        if(words.count > 25){
            randomWords = getRandomWords()
        }
        
        createGrid(words: randomWords)
        createStartButton()
        var initMsg = "init:" + startingTeam
        for word in randomWords{
            initMsg += ":"
            initMsg += word
        }
        sendData(message: initMsg)
    }
    
    @objc
    func sendCellData(sender:Cell){
        sender.layer.opacity = 0.7
        sender.isEnabled = false
        if(sender.type == "red"){
            scorePanel.decreaseRedScore()
            sendData(message: "score:red")
        }else if(sender.type == "blue"){
            scorePanel.decreaseBlueScore()
            sendData(message: "score:blue")
        }
        sendData(message: sender.getData())
    }
    
    func sendData(message:String) {
        sessionManager.currentCastSession?.add(messageChannel)
        let json = ["type": "message", "text": message]
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(json) {
        if let jsonString = String(data: jsonData, encoding: . utf8) {
        messageChannel.sendTextMessage(jsonString, error: nil)
        }
        print("Connected: ",messageChannel.isConnected)
    }
    }
    @IBAction func languageChoice(_ sender: UIButton) {
        currentLanguage = (sender.titleLabel?.text)!
        getWords(language: currentLanguage)
        self.words = [String]()
        sendInit()
        languages.forEach { language in
            language.isHidden = true
            
        }
        
    }
    
    @objc
    func settingsClicked(){
        languages.forEach { language in
            language.isHidden = !language.isHidden
            
        }
    }
    
  func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
    print("GameViewController: sessionManager didStartSession \(session)")
  }

  func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
    print("GameViewController: sessionManager didResumeSession \(session)")
  }

  func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
    print("session ended with error: \(String(describing: error))")
  }

  func sessionManager(_: GCKSessionManager, didFailToStartSessionWithError error: Error?) {
    if let error = error {
      showAlert(withTitle: "Failed to start a session", message: error.localizedDescription)
    }
  }

  func sessionManager(_: GCKSessionManager,
                      didFailToResumeSession _: GCKSession, withError _: Error?) {
  }

  func showAlert(withTitle title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    self.present(alert, animated: true, completion: nil)
  }


  func requestDidComplete(_ request: GCKRequest) {
    print("request \(Int(request.requestID)) completed")
  }

  func request(_ request: GCKRequest, didFailWithError error: GCKError) {
    print("request \(Int(request.requestID)) failed with error \(error)")
  }
  
}
