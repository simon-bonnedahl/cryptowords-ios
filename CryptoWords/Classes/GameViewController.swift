//
//  GameViewController.swift
//  Codenames
//
//  Created by Simon Bonnedahl on 2021-12-28.

import GoogleCast
import UIKit
import Firebase
import SideMenu
import StoreKit
import MultipeerConnectivity

@available(iOS 13.0, *)
@objc(GameViewController)
class GameViewController: UIViewController, GCKSessionManagerListener, GCKRequestDelegate, MenuControllerDelegate, UINavigationControllerDelegate, SuggestWordsDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate{
    
    
    
  private var sessionManager: GCKSessionManager!
  private var messageChannel: GCKCastChannel!
  private var titleView: UIView!
  private var castButton: GCKUICastButton!
  private var languageButton: UIButton!
  var currentLanguage = "English"
    
var peerID: MCPeerID!
var mcSession: MCSession!
var mcAdvertiserAssistant: MCNearbyServiceAdvertiser!
    
 @IBOutlet var languages: [UIButton]!

var sideMenu: UISideMenuNavigationController?
var languageMenu: UISideMenuNavigationController?
private var infoController = InfoViewController()

var suggestWords: SuggestWords!
var scorePanel: ScorePanel!
var startingTeam:String!
var words: [String]!
var initWords = [String](repeating: "_", count: 25)
var startButton: UIButton!

    var grid:UICollectionView!
    var cells: [Cell]!
    
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
    
    let menu = MenuViewController();
    menu.delegate = self;
    let menu2 = MenuViewController()
    menu2.languageMenu()
    menu2.delegate = self;
    
    sideMenu = UISideMenuNavigationController(rootViewController: menu)
    self.languageMenu = UISideMenuNavigationController(rootViewController: menu2)
    
    sideMenu?.leftSide = true;
    //sideMenu?.setNavigationBarHidden(true, animated: false)
    SideMenuManager.default.menuFadeStatusBar = false;
    SideMenuManager.default.menuLeftNavigationController = sideMenu;
    //SideMenuManager.default.menuAddPanGestureToPresent(toView: self.view)
    SideMenuManager.default.menuPresentMode = .menuDissolveIn;
    sessionManager.add(self)
    messageChannel = GCKCastChannel(namespace: appDelegate!.namespace)
    titleView = navigationItem.titleView
    castButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                                 width: CGFloat(24), height: CGFloat(24)))
    castButton.tintColor = UIColor.white
      
        languageButton = UIButton(type: .custom)
    languageButton.bounds = CGRect(x: 0, y: 0, width: 24, height: 24)

      
     
        let languageImage = UIImage(systemName: "line.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24.0)) //"globe"
        languageButton.setImage(languageImage, for: .normal)
        languageButton.tintColor = UIColor.white
        languageButton.addTarget(self,
                   action: #selector(settingsClicked),
                   for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: languageButton)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
    
    peerID = MCPeerID(displayName: UIDevice.current.name)
    mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
    mcSession.delegate = self
        
    getWords(language:currentLanguage)
    createGrid(words: initWords)
    createStartButton()
        
    addChildController()
     
  }
    
  func getWords(language:String){
    let db = Firestore.firestore()
    let ref = db.collection("Languages").document(language)
    ref.getDocument { (document, error) in
        if let document = document, document.exists {
            self.words = (document.get("words") as! [String])
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
    func createGrid(words:[String], colors:[String]? = nil){
        
        cells = [Cell]()
        grid = UICollectionView(frame: CGRect(x: 1,
                                                  y: 80,
                                                  width: min(600, self.view.bounds.width),
                                                  height: min(600, self.view.bounds.width)), collectionViewLayout: UICollectionViewLayout())
        grid.center.x = self.view.center.x
        let cellsize = Int(grid.bounds.width/5)
        for y in 0...4{
            for x in 0...4{
                var type = "default"
                if(colors != nil){
                    type = colors![(y*5)+x]
                }
                let cell = Cell(id:(y*5) + x, posX: x*cellsize, posY: y*cellsize, size: cellsize-4,color1: white1, color2:white2, text: words[(y*5)+x], type: type)
                
                cell.addTarget(self,
                               action: #selector(sendCellData),
                                 for: .touchUpInside)
                cell.titleLabel?.font = UIFont.boldSystemFont(ofSize:(cell.bounds.width/9))
                cells.append(cell)
            }
        }
        self.view.addSubview(grid)
        if(colors == nil){
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
        let shuffledCells = cells.shuffled()
       
        for cell in shuffledCells{
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
           
        }else{
            var bluebuttons = 0
            var redbuttons = 0
            for cell in cells{
                switch(cell.type){
                case "blue":
                    cell.startGradientAnimation(color1:blue1, color2:blue2)
                    cell.setTitleColor(UIColor.black, for: .normal)
                    bluebuttons += 1
                    break
                case "red":
                    cell.startGradientAnimation(color1:red1, color2:red2)
                    cell.setTitleColor(UIColor.black, for: .normal)
                    redbuttons += 1
                    break
                case "white":
                    cell.startGradientAnimation(color1:white1, color2:white2)
                    cell.setTitleColor(UIColor.black, for: .normal)
                    break
                case "bomb":
                    cell.startGradientAnimation(color1:bombGray1, color2:bombGray2)
                    break
                default:
                    continue
                }
                
                
                grid.addSubview(cell)
        }
            scorePanel = ScorePanel(blueScore: bluebuttons, redScore: redbuttons, width: Int(grid.bounds.width/1.25), height: Int(grid.bounds.width/4))
            scorePanel.center.x = self.view.center.x
            scorePanel.center.y = grid.center.y + (grid.bounds.height/2) + 70
            self.view.addSubview(scorePanel)
            
        }
        grid.backgroundColor = UIColor.clear
        
    }
    
    func createStartButton(){
        startButton = UIButton(frame: CGRect(x: 140,
                                            y: grid.center.y + (grid.bounds.height/2) + 150,
                                            width: grid.bounds.width/4,
                                            height: (grid.bounds.width/8)))
        startButton.setTitle("Start",
                         for: .normal)
        startButton.layer.borderWidth = 2
        startButton.layer.cornerRadius = grid.bounds.width/16
        startButton.layer.borderColor = white1.cgColor
          
        startButton.addTarget(self,
                          action: #selector(sendInit),
                          for: .touchUpInside)
        startButton.backgroundColor = white1.withAlphaComponent(0)
        startButton.setTitleColor(white1, for: .normal)
        startButton.center.x = self.view.center.x
        UIView.animate(withDuration: 0.4,
            animations: {
            self.startButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.4) {
                    self.startButton.transform = CGAffineTransform.identity
                }
            })
          self.view.addSubview(startButton)
    }
   
    @objc
    func sendInit(){
        for view in self.view.subviews{
            if(view.tag != 10){
                view.removeFromSuperview()
            }else{
                view.isHidden = true
            }
        }
        var randomWords = initWords
        if(words.count > 25){
            randomWords = getRandomWords()
        }
        
        createGrid(words: randomWords)
        createStartButton()
        var initMsg = "init:" + startingTeam
        var initMsg2 = "init:"
        var w = ""
        for cell in cells{
            initMsg += ":"
            initMsg += cell.text
            w += cell.text + "|"
        }
        initMsg2 += w.dropLast()
        initMsg2 += ":"
        var c = ""
        for cell in cells{
            c += cell.type + "|"
        }
        initMsg2 += c.dropLast()
        
        sendData(message: initMsg.components(separatedBy: .whitespacesAndNewlines).joined())
        sendDataToPeers(data: initMsg2.components(separatedBy: .whitespacesAndNewlines).joined())
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
        sendDataToPeers(data: "cell:" + String(sender.id))
    }
    
    func sendData(message:String) {
        sessionManager.currentCastSession?.add(messageChannel)
        let json = ["type": "message", "text": message]
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(json) {
        if let jsonString = String(data: jsonData, encoding: . utf8) {
        messageChannel.sendTextMessage(jsonString, error: nil)
        }
    }
    }
    
    func setLanguage(language: String){
        currentLanguage = language
        getWords(language: currentLanguage)
        self.words = [String]()
        sendInit()
    }
    private func addChildController(){
        addChild(infoController)
        view.addSubview(infoController.view)
        infoController.view.frame = view.bounds
        infoController.didMove(toParent: self)
        infoController.view.isHidden = true
        
        suggestWords = SuggestWords()
        addChild(suggestWords)
        view.addSubview(suggestWords.view)
        suggestWords.didMove(toParent: self)
        suggestWords.view.isHidden = true
        suggestWords.delegate = self
        
    }
    func addSuggestion(language: String, word: String) {
        let db = Firestore.firestore()
     
        db.collection("SuggestedWords").document(language.prefix(1).capitalized + language.dropFirst()).setData([UIDevice.current.name
                                                                              + UUID().uuidString:word])
    
    }
    func removeMenuViews(){
        for view in self.view.subviews{
            if(view.tag == 10){
                view.isHidden = true
            }
        }
    }
    func didSelectMenuItem(named: String){
        removeMenuViews()
        sideMenu?.dismiss(animated: true, completion: { [self] in
        if named == "Game Info"{
            self.infoController.view.isHidden = false;
            self.view.bringSubviewToFront((self.infoController.view)!)
        };if named == "Language"{
            present(self.languageMenu!, animated: true)
        };if named == "Connect Device"{
            startHosting()
            joinSession()
        };if named == "Rate App"{
            SKStoreReviewController.requestReview()
        };if named == "Suggest Words"{
            self.suggestWords.view.isHidden = false
            self.view.bringSubviewToFront((self.suggestWords.view)!)
        }
            
        })
        languageMenu?.dismiss(animated: true, completion: { [self] in
        if named == "Swedish"{
            self.setLanguage(language: named)
        };if named == "English"{
            self.setLanguage(language: named)
        };if named == "Spanish"{
            self.setLanguage(language: named)
        };if named == "French"{
            self.setLanguage(language: named)
        }
        }
        
        )
        
        
    }
    @objc
    func settingsClicked(){
        present(sideMenu!, animated: true);
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
    
    //MCPeer
    
    func sendDataToPeers(data: String) {
        if mcSession.connectedPeers.count > 0 {
            if let textData = data.data(using: .utf8) {
                do {
                    //send data
                    try mcSession.send(textData, toPeers: mcSession.connectedPeers, with: .reliable)
                    DispatchQueue.main.async {
                    }
                } catch let error as NSError {
                    //error sending data
                    print(error.localizedDescription)
                }
            }
        }
    }
    func sendDataToHost(data: String){
        if mcSession.connectedPeers.count > 0 {
            if let textData = data.data(using: .utf8) {
                do {
                    //send data
                    var host = [MCPeerID]()
                    host.append(mcSession.connectedPeers[0])

                    try mcSession.send(textData, toPeers: host, with: .reliable)
                    DispatchQueue.main.async {
                       
                    }
                } catch let error as NSError {
                    //error sending data
                    print(error.localizedDescription)
                }
            }
        }
    }
    

 
    func startHosting() {
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "cryptowords")
        mcAdvertiserAssistant.delegate = self
        mcAdvertiserAssistant.startAdvertisingPeer()

        
    }
    func stopHosting(){
        mcAdvertiserAssistant.stopAdvertisingPeer()
    }
    
    //join a room
    func joinSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "cryptowords", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    // MARK: - Session Methods
    //Session states
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                
                
            }
          
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
            
        @unknown default:
            fatalError()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //data received
        if let data = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                let dataArray = data.split(separator: ":")
                let type = dataArray[0]
                switch(type){
                case "init":
                    for view in self.view.subviews{
                        if(view.tag != 10){
                            view.removeFromSuperview()
                        }else{
                            view.isHidden = true
                        }
                    }
                    let w = String(dataArray[1])
                    let c = String(dataArray[2])
                    var wa = [String]()
                    var ca = [String]()
                   
                    for word in w.split(separator: "|"){
                        wa.append(String(word))
                    }
                    for color in c.split(separator: "|"){
                        ca.append(String(color))
                    }
                    self.createGrid(words: wa, colors: ca)
                    self.createStartButton()
                    break
                case "cell":
                    let cell = self.cells[Int(dataArray[1])!]
                 
                    cell.layer.opacity = 0.7
                    cell.isEnabled = false
                    if(cell.type == "red"){
                        self.scorePanel.decreaseRedScore()
                    }else if(cell.type == "blue"){
                        self.scorePanel.decreaseBlueScore()
                    }
                default:
                    print("Not a valid data type")
                }

            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    // MARK: - Browser Methods
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    // MARK: - Advertiser Methods
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //accept the connection/invitation
        invitationHandler(true, mcSession)
    }

}

protocol MenuControllerDelegate{
    func didSelectMenuItem(named: String)
}
protocol SuggestWordsDelegate{
    func addSuggestion(language: String, word: String)
}
