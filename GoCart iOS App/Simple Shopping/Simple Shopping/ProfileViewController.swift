//
//  ProfileViewController.swift
//  Simple Shopping
//
//  Created by Arya Tschand on 9/7/19.
//  Copyright © 2019 HTHS. All rights reserved.
//

import UIKit
import Firebase
import CryptoSwift

class ProfileViewController: UIViewController, UITextFieldDelegate {

    var dataArray = [SavedData]()
    var data: SavedData!
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Data.plist")
    var ref: DatabaseReference!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        saveData()
        data = dataArray[0]
        name.delegate = self
        password.delegate = self
        email.delegate = self
        ref = Database.database().reference()
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        name.text = data.name
        password.text = ""
        email.text = data.email
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            for (key,values) in value! {
                self.data.userKey = key as! String
                self.saveData()
                self.ref.child("users").child("\(key)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value2 = snapshot.value as? NSDictionary
                    if (value2?["name"] as! String) == self.name.text {
                        self.data.userKey = key as! String
                    }
                })
            }
        })
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
    
    @IBAction func save(_ sender: Any) {
        data.name = name.text!
        data.email = email.text!
        var emailtemp = email.text
        var passwordtemp = String(password.text!.sha512())
        var nametemp = name.text
        if password.text! != "" {
            ref.child("users").child(data.userKey).setValue(["email": emailtemp, "password": passwordtemp, "name": nametemp])
        } else {
        }
        ref.child("users").child(data.userKey).child("name").setValue(nametemp)
        ref.child("users").child(data.userKey).child("email").setValue(emailtemp)
        saveData()
    }
    

}
