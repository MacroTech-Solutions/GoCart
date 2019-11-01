//
//  ListProductsTableViewController.swift
//  Simple Shopping
//
//  Created by Arya Tschand on 9/6/19.
//  Copyright © 2019 HTHS. All rights reserved.
//

import UIKit

class ListProductsTableViewController: UITableViewController {

    var dataArray = [SavedData]()
    var data: SavedData!
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Data.plist")
    var index = -1
    
    @IBOutlet weak var titleLabel: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let alert = UIAlertController(title: "Delete Product", message: "Are You Sure You Want to Delete Product?", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Delete", style: .default, handler: { (action) in
                self.data.lists[self.index].names.remove(at: indexPath.row)
                self.data.lists[self.index].price.remove(at: indexPath.row)
                self.data.lists[self.index].url.remove(at: indexPath.row)
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
        titleLabel.title = data.lists[index].name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.lists[index].names.count
    }
    
    
    @IBAction func AddProduct(_ sender: Any) {
        data.lists[index].names.append("")
        data.lists[index].url.append("")
        data.lists[index].price.append("")
        performSegue(withIdentifier: "new", sender: self)
        saveData()
        
    }
    
    // Populate rows and delete a player if the information is incomplete
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "product", for: indexPath)
       
        if indexPath.row < data.lists[index].url.count {
            if data.lists[index].url[indexPath.row] != "" {
                let url = URL(string: data.lists[index].url[indexPath.row])!
                let dataa = try? Data(contentsOf: url)
                if let imageData = dataa {
                    let imagee = UIImage(data: imageData)
                    cell.imageView?.image = imagee
                }
            }
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.text = data.lists[index].names[indexPath.row] + " - " + data.lists[index].price[indexPath.row]
        }
        
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
        if segue.identifier == "new" {
            let NewProductTableViewController = segue.destination as! NewProductTableViewController
            NewProductTableViewController.index = index
            saveData()
        }
    }

}
