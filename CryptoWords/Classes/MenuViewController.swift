//
//  MenuViewController.swift
//  Codenames
//
//  Created by Simon Bonnedahl on 2022-02-28.
//  Copyright © 2022 Google. All rights reserved.
//
import SideMenu
import Foundation
import UIKit

enum MenuItems: String{
    case language = "Language"
    case suggestWords = "Suggest Words"
    case gameInfo = "Game Info"
    
}

@available(iOS 13.0, *)
class MenuViewController: UITableViewController{
    
    public var delegate: MenuControllerDelegate?
    
    var items = ["Language", "Connect Device", "Suggest Words", "Game Info", "Rate App"];
    var globalBackgroundColor1 = UIColor(red: 78/255, green: 67/255, blue: 118/255, alpha: 1)
    var globalBackgroundColor2 = UIColor(red: 43/255, green: 88/255, blue: 118/255, alpha: 1)
    var currentLanguage = "English"
    
    override func viewDidLoad() {
    super.viewDidLoad()
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.rowHeight = 50
        tableView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell");
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath);
        cell.textLabel?.text = items[indexPath.row];
        switch(items[indexPath.row]){
        case "Language":
            cell.imageView?.image = UIImage(systemName: "globe", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14.0))
            break;
        case "Connect Device":
            cell.imageView?.image = UIImage(systemName: "link", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14.0))
            break;
        case "Game Info":
            cell.imageView?.image = UIImage(systemName: "info", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14.0))
            break;
        case "Suggest Words":
        cell.imageView?.image = UIImage(systemName: "plus.rectangle.on.rectangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14.0))
            break;
        case "Rate App":
        cell.imageView?.image = UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14.0))
            break;
        
        default:
            break
        }
        cell.tintColor = UIColor.white
        cell.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        cell.textLabel?.textColor = UIColor.white
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = items[indexPath.row]
        delegate?.didSelectMenuItem(named: selectedItem)
        
        
    }
    func languageMenu(){
        items = ["English", "Swedish", "Spanish", "French"];

    }
 
}


