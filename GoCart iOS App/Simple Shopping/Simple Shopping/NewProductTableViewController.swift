//
//  NewProductTableViewController.swift
//  Simple Shopping
//
//  Created by Arya Tschand on 9/6/19.
//  Copyright © 2019 HTHS. All rights reserved.
//

import UIKit

class NewProductTableViewController: UITableViewController, UISearchBarDelegate {

    var dataArray = [SavedData]()
    var data: SavedData!
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Data.plist")
    var index = 0
    
    var filteredData: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SearchBar.delegate = self as! UISearchBarDelegate
    }
    
    @IBOutlet weak var SearchBar: UISearchBar!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? filteredData : filteredData.filter { (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.SearchBar.showsCancelButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        saveData()
        data = dataArray[0]
        filteredData = data.nameArray
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if data.lists[index].names[data.lists[index].names.count-1] == "" {
            data.lists[index].names.remove(at: data.lists[index].names.count-1)
        }
        saveData()
    }
    
    // Populate rows and delete a player if the information is incomplete
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "product", for: indexPath)
        //let image = cell.viewWithTag(1) as! UIImageView
        
        var find: Int = data.nameArray.index(of: filteredData[indexPath.row])!
        if verifyUrl(urlString: data.urlArray[find]) == true {
            
        } else  {
            data.urlArray[find] = data.urlArray[find].substring(to: data.urlArray[find].index(before: data.urlArray[find].endIndex))
        }
        
        let url = URL(string: data.urlArray[find])!
        let dataa = try? Data(contentsOf: url)
        
        if let imageData = dataa {
            let imagee = UIImage(data: imageData)
            cell.imageView?.image = imagee
        }
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.text = filteredData[indexPath.row]
        
        return cell
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        data.lists[index].names[data.lists[index].names.count-1] = (filteredData[indexPath.row])
        var find: Int = data.nameArray.index(of: filteredData[indexPath.row])!
        data.lists[index].price[data.lists[index].names.count-1] = (data.priceArray[find])
        data.lists[index].url[data.lists[index].names.count-1] = (data.urlArray[find])
        saveData()
        _ = self.navigationController?.popViewController(animated: true)
        
        saveData()
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
