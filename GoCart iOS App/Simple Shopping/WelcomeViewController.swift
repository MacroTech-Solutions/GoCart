//
//  SerialViewController.swift
//  HM10 Serial
//
//  ViewController.swift
//  Simple Shopping
//
//  Created by Arya Tschand on 8/25/19.
//  Copyright © 2019 HTHS. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore
import Firebase
import CryptoSwift

/// The option to add a \n or \r or \r\n to the end of the send message


class WelcomeViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: IBOutlets
    
    //@IBOutlet weak var mainTextView: UITextView!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var Welcome: UILabel!
    
    @IBOutlet weak var ShopBtn: UIButton!
    
    var dataArray = [SavedData]()
    var data: SavedData!
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Data.plist")
    var ref: DatabaseReference!
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        saveData()
        data = dataArray[0]
        Welcome.text = data.name
        saveData()
    }
    
    
    @IBAction func ShopClicked(_ sender: Any) {
        if data.lists.count > 0 {
            performSegue(withIdentifier: "Shop", sender: self)
        } else {
            performSegue(withIdentifier: "ShopNoList", sender: self)
        }
    }
    
    func saveData() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(dataArray)
            try data.write(to: dataFilePath!)
        } catch {
            let alert = UIAlertController(title: "Error Code 1", message: "Something went wrong! Please reload App.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func loadData() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                dataArray = try decoder.decode([SavedData].self, from: data)
            } catch {
                let alert = UIAlertController(title: "Error Code 2", message: "Something went wrong! Please reload App.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}


