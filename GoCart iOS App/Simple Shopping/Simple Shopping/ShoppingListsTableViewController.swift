//
//  ShoppingListsTableViewController.swift
//  Simple Shopping
//
//  Created by Arya Tschand on 9/6/19.
//  Copyright © 2019 HTHS. All rights reserved.
//

import UIKit

class ShoppingListsTableViewController: UITableViewController {

    var dataArray = [SavedData]()
    var data: SavedData!
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Data.plist")
    var select = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if (editingStyle == .delete) {
                let alert = UIAlertController(title: "Delete List", message: "Are You Sure You Want to Delete List?", preferredStyle: .alert)
                let delete = UIAlertAction(title: "Delete", style: .default, handler: { (action) in
                    self.data.lists.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                })
                alert.addAction(delete)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        saveData()
        data = dataArray[0]
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.lists.count
    }
    
    
    @IBAction func AddList(_ sender: Any) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add List", message: "Enter list name", preferredStyle: .alert)
        
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "list name"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            var blank: ShoppingList = ShoppingList()
            self.data.lists.append(blank)
            self.data.lists[self.data.lists.count-1].name = textField!.text!
            self.performSegue(withIdentifier: "newlist", sender: self)
            self.saveData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    // Populate rows and delete a player if the information is incomplete
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath)
        cell.textLabel?.text = data.lists[indexPath.row].name
        return cell
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newlist" {
            let ListProductsTableViewController = segue.destination as! ListProductsTableViewController
            var selectedIndexPath = tableView.indexPathForSelectedRow
            ListProductsTableViewController.index = data.lists.count-1
            saveData()
        } else if segue.identifier == "select" {
            let ListProductsTableViewController = segue.destination as! ListProductsTableViewController
            var selectedIndexPath = tableView.indexPathForSelectedRow
            ListProductsTableViewController.index = selectedIndexPath!.row
            saveData()
        }
    }

}
