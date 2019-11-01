//
//  SavedArrays.swift
//  Simple Shopping
//
//  Created by Arya Tschand on 9/3/19.
//  Copyright © 2019 HTHS. All rights reserved.
//

import Foundation

class SavedData: Codable {
    var nameArray: [String] = []
    var idArray: [String] = []
    var priceArray: [String] = []
    var urlArray: [String] = []
    var loggedin: Bool = false
    var lists: [ShoppingList] = []
    var name: String = ""
    var email: String = ""
    var userKey: String = ""
}
