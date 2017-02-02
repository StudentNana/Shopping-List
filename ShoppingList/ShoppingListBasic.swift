//
//  ShoppingListBasic.swift
//  ShoppingList
//
//  Created by Anton Kusch on 31/01/17.
//  Copyright © 2017 Anton Kusch. All rights reserved.
//

import Foundation
import EVReflection


class ShoppingItem: EVObject {
    var entityId: Int = 0
    var name: String = ""
    var bought: Bool = false
    
    required init() {}

    init(entityId: Int, name: String) {
        self.entityId = entityId
        self.name = name
    }
    
    override var hashValue: Int {
        get {
            return entityId.hashValue << 15 + name.hashValue
        }
    }
    
    static func ==(lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {
        return lhs.entityId == rhs.entityId && lhs.name == rhs.name
    }
}

class ShoppingList: EVObject {

    var entityId: Int = 0
    var name: String = ""
    var items = [ShoppingItem]()
    
    required init() {}

    init(name: String) {
        self.name = name;
    }

    init(entityId: Int, name: String) {
        self.entityId = entityId;
        self.name = name;
    }
    
    func getItemById(itemId: Int) throws -> ShoppingItem {
        for item in items {
            if (item.entityId == itemId) {
                return item
            }
        }
        throw "Item with id \(itemId) not found"
    }
}

extension String: Error {}
