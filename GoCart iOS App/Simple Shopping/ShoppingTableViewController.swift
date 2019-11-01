//
//  ShoppingTableViewController.swift
//  Simple Shopping
//
//  Created by Arya Tschand on 9/6/19.
//  Copyright © 2019 HTHS. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore
import Firebase
import CryptoSwift

enum MessageOption: Int {
    case noLineEnding,
    newline,
    carriageReturn,
    carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
    newline
}

class ShoppingTableViewController: UITableViewController, BluetoothSerialDelegate {
    
    var dataArray = [SavedData]()
    var data: SavedData!
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Data.plist")
    var index = -1
    var list: ShoppingList = ShoppingList()
    var temprfid: [String] = []
    var ref: DatabaseReference!
    var completeGiven: Bool = false
    
    @IBOutlet weak var TitleLabel: UINavigationItem!
    
    @IBOutlet weak var ConnectBtn: UIBarButtonItem!
    
    @IBOutlet weak var PriceLabel: UILabel!
    
    @IBAction func Connect(_ sender: Any) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        serial = BluetoothSerial(delegate: self)
        
        // UI
        //mainTextView.text = ""
        reloadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ShoppingTableViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
        
        // we want to be notified when the keyboard is shown (so we can move the textField up)
        
        // to dismiss the keyboard if the user taps outside the textField while editing
        
        // style the bottom UIView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // animate the text field to stay above the keyboard
        var info = (notification as NSNotification).userInfo!
        let value = info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = value.cgRectValue
        
        //TODO: Not animating properly
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
        }, completion: { Bool -> Void in
            self.textViewScrollToBottom()
        })
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // bring the text field back down..
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
        }, completion: nil)
        
    }
    
    func textViewScrollToBottom() {
        //let range = NSMakeRange(NSString(string: mainTextView.text).length - 1, 1)
        //mainTextView.scrollRangeToVisible(range)
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        saveData()
        data = dataArray[0]
        list.name = "Shopping List"
        reloadView()
        tableView.reloadData()
    }
    
    func testingCarts(cart: String, setVal: Bool){
        
        var cartName = cart
        
        self.ref.child("carts").observeSingleEvent(of: .value, with: { (snapshot) in
           
            let value = snapshot.value as? NSDictionary
            
            for (key,values) in value! {
                
                let value2 = values as? NSDictionary
        
                if(value2?["name"] as! String == cartName){
               
                    var cartKey = key as! String
                    self.ref.child("carts").child(cartKey).child("purchased").setValue(setVal)
       
                }
                
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.names = []
        list.price = []
        list.url = []
        list.inCart = []
        if index >= 0 {
            if data.lists[index].names.count > 0 {
                for var x in 0...data.lists[index].names.count-1 {
                    list.names.append(data.lists[index].names[x])
                    list.url.append(data.lists[index].url[x])
                    list.price.append(data.lists[index].price[x])
                    list.inCart.append(false)
                }
            }
            if temprfid.count > 0 {
                for var x in 0...temprfid.count-1 {
                    var tempname: String
                    var tempprice: String
                    var tempurl: String
                    for var y in 0...data.idArray.count-1 {
                        if temprfid[x] == data.idArray[y] + "\r\n" {
                            tempname = data.nameArray[y]
                            tempprice = data.priceArray[y]
                            tempurl = data.urlArray[y]
                            var found: Bool = false
                            for var z in 0...list.names.count-1 {
                                if tempname == list.names[z] {
                                    list.names[z] = list.names[z] + "`"
                                    list.inCart[z] = true
                                    found = true
                                }
                            }
                            if found == false {
                                if verifyUrl(urlString: tempurl) == true {
                                    
                                } else  {
                                    tempurl = tempurl.substring(to: tempurl.index(before: tempurl.endIndex))
                                }
                                list.names.append(tempname)
                                list.url.append(tempurl)
                                list.price.append(tempprice)
                            }
                        }
                    }
                }
            }
        } else {
            if temprfid.count > 0 {
                for var x in 0...temprfid.count-1 {
                    var tempname: String
                    var tempprice: String
                    var tempurl: String
                    for var y in 0...data.idArray.count-1 {
                        if temprfid[x] == data.idArray[y] + "\r\n"{
                            tempname = data.nameArray[y]
                            tempprice = data.priceArray[y]
                            tempurl = data.urlArray[y]
                            if verifyUrl(urlString: tempurl) == true {
                                
                            } else  {
                                tempurl = tempurl.substring(to: tempurl.index(before: tempurl.endIndex))
                            }
                            list.names.append(tempname)
                            list.url.append(tempurl)
                            list.price.append(tempprice)
                        }
                    }
                }
            }
        }
        
        if data.lists.count > 0 && index != -1{
            if data.lists[index].names.count > 0 {
                var extra = list.names.count-data.lists[index].names.count
                if extra > 0 {
                    for var x in 0...extra-1 {
                        list.inCart.append(true)
                    }
                }
                if list.inCart.count > 0  {
                    var finished = true
                    for var x in 0...data.lists[index].names.count-1 {
                        if list.inCart[x] == false {
                            finished = false
                        }
                    }
                }
            }
        } else if data.lists.count > 0  {
            var extra = list.names.count
            for var x in 0...extra-1 {
                list.inCart.append(true)
            }
        }
        
        var totalprice: Double = 0
        if list.names.count > 0 {
            for var x in 0...list.names.count-1 {
                list.price[x].remove(at: list.price[x].startIndex)
                if list.inCart.count > x {
                    if list.inCart[x] == true {
                        totalprice += Double(list.price[x])!
                    }
                }
            }
            if totalprice > 0 {
                let x = Double(round(100*totalprice)/100)
                PriceLabel.text = "Total Cost - $" + String(x)
            } else {
                PriceLabel.text = "No items in cart"
            }
            
        } else {
            PriceLabel.text = "No items in cart"
        }
        return list.names.count
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    @IBAction func Payment(_ sender: Any) {
        if ConnectBtn.title == "Disconnect" {
            testingCarts(cart: serial.connectedPeripheral!.name!, setVal: true)
        }
        performSegue(withIdentifier: "pay", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) && completeGiven == false {
            let alert = UIAlertController(title: "Remove Item", message: "Are you sure you want to remove this item?", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Delete", style: .default, handler: { (action) in
                self.list.names.remove(at: indexPath.row)
                self.list.price.remove(at: indexPath.row)
                self.list.url.remove(at: indexPath.row)
                self.list.inCart.remove(at: indexPath.row)
                if indexPath.row < self.data.lists[self.index].names.count {
                    self.data.lists[self.index].names.remove(at: indexPath.row)
                    self.data.lists[self.index].url.remove(at: indexPath.row)
                    self.data.lists[self.index].price.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.saveData()
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            })
            alert.addAction(delete)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            completeGiven = true
        }
    }
    
    
    // Populate rows and delete a player if the information is incomplete
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "product", for: indexPath)
        
        var back: Int = 0
        
        if list.names[indexPath.row].last == "`" {
            list.names[indexPath.row] = list.names[indexPath.row].substring(to: list.names[indexPath.row].index(before: list.names[indexPath.row].endIndex))
            cell.backgroundColor = UIColor.green
            list.inCart[indexPath.row] = true
        } else {
            var found = false
            if index != -1 {
                if data.lists[index].names.count > 0 {
                    for var x in 0...data.lists[index].names.count-1 {
                        if data.lists[index].names[x] == list.names[indexPath.row] {
                            found = true
                        }
                    }
                    if found == true {
                        cell.backgroundColor = UIColor.red
                        list.inCart[indexPath.row] = false
                    }
                }
            }
        }
        
        if indexPath.row < list.url.count {
            let url = URL(string: list.url[indexPath.row])!
            let dataa = try? Data(contentsOf: url)
            if let imageData = dataa {
                let imagee = UIImage(data: imageData)
                cell.imageView?.image = imagee
            }
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.text = list.names[indexPath.row] + " - $" + list.price[indexPath.row]
        }
        
        return cell
    }
    
    @objc func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
            TitleLabel.title = serial.connectedPeripheral!.name
            ConnectBtn.title = "Disconnect"
            testingCarts(cart: serial.connectedPeripheral!.name!, setVal: false)
            ConnectBtn.tintColor = UIColor.red
            ConnectBtn.isEnabled = true
            serial.sendMessageToDevice("initialize")
        } else if serial.centralManager.state == .poweredOn {
            TitleLabel.title = "Bluetooth Serial"
            ConnectBtn.title = "Connect"
            ConnectBtn.tintColor = view.tintColor
            ConnectBtn.isEnabled = true
            serial.sendMessageToDevice("DISCONNECT")
        } else {
            TitleLabel.title = "Bluetooth Serial"
            ConnectBtn.title = "Connect"
            ConnectBtn.tintColor = view.tintColor
            ConnectBtn.isEnabled = false
            serial.sendMessageToDevice("DISCONNECT")
        }
    }
    
    func sendName(inputtemp2 : String) {
        var inputtemp = inputtemp2
        if inputtemp == "double" {
            serial.sendMessageToDevice("Duplicate scan")
        } else {
            inputtemp = inputtemp.substring(to: inputtemp.index(before: inputtemp.endIndex))
            var input = inputtemp
            var index: Int = -1
            for var x in 0...data.idArray.count-1 {
                var testStr = String(data.idArray[x])
                if testStr == input {
                    index = x
                    break
                }
            }
            if index != -1 {
                print(data.nameArray[index])
                serial.sendMessageToDevice(data.nameArray[index])
                serial.sendMessageToDevice(",")
                serial.sendMessageToDevice(String(data.priceArray[index]))
                serial.sendMessageToDevice(",")
                serial.sendMessageToDevice("notpurchased")
                serial.sendMessageToDevice(",")
                serial.sendMessageToDevice("noerror")
            } else {
                serial.sendMessageToDevice("Item not found")
            }
        }
        
    }
    
    func serialDidReceiveString(_ message: String) {
        // add the received text to the textView, optionally with a line break at the end
        print(message)
        if !temprfid.contains(message) {
            temprfid.append(message)
            sendName(inputtemp2: message)
        } else {
            sendName(inputtemp2: "double")
        }
        
        let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
        //if pref == ReceivedMessageOption.newline.rawValue { mainTextView.text! += "\n" }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
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

