//
//  SignupViewController.swift
//  Simple Shopping
//
//  Created by Arya Tschand on 9/1/19.
//  Copyright © 2019 HTHS. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, UITextFieldDelegate {

    var dataArray = [SavedData]()
    var data: SavedData!
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Data.plist")
    var ref: DatabaseReference!
    
    @IBOutlet weak var Username: UITextField!
    
    @IBOutlet weak var Password: UITextField!
    
    @IBOutlet weak var PasswordVerify: UITextField!
    
    @IBOutlet weak var First: UITextField!
    
    @IBOutlet weak var Last: UITextField!
    
    
    @IBAction func Enter(_ sender: Any) {
        if Password.text == PasswordVerify.text {
            var username = Username.text
            var password = String(Password.text!.sha512())
            var name = First.text! + " " + Last.text!
            
            ref.child("users").childByAutoId().setValue(["email": username, "password": password, "name": name])
            data.loggedin = true
            data.name = name
            data.email = username!
            saveData()
            self.performSegue(withIdentifier: "aftersignup", sender: self)
        } else {
            PasswordVerify.text = ""
            Password.text = ""
            let alert = UIAlertController(title: "Match Error", message: "Entered passwords do not match.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel) { (action) in
            }
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func Login(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Password.delegate = self
        Username.delegate = self
        PasswordVerify.delegate = self
        ref = Database.database().reference()
        var username = Username.text
        var password = String(Password.text!.sha512())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        data = dataArray[0]
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
