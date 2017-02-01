//
//  ShoppingListBasic.swift
//  ShoppingList
//
//  Created by Anton Kusch on 31/01/17.
//  Copyright © 2017 AG. All rights reserved.
//

import Foundation


class ShoppingItem: Equatable, Hashable {
    var entityId: Int
    var description: String
    var bought: Bool = false
    
    init(entityId: Int, description: String) {
        self.entityId = entityId
        self.description = description
    }
    
    var hashValue: Int {
        get {
            return entityId.hashValue << 15 + description.hashValue
        }
    }
    
    static func ==(lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {
        return lhs.entityId == rhs.entityId && lhs.description == rhs.description
    }
}

class ShoppingList {
    var entityId: Int = 0
    var name: String
    var items = Set<ShoppingItem>()
    
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

protocol ShoppingListDAO {
    func getLists() throws -> [ShoppingList]
    func addList(list: ShoppingList) throws
    func removeList(listId: Int) throws
    func getListById(id: Int) throws -> ShoppingList
    func addItemToList(listId: Int, item: ShoppingItem) throws
    func removeItemFromList(listId: Int, itemId: Int) throws
    func setBoughtToItemFromList(listId: Int, itemId: Int) throws
}

extension String: Error {}

class SimpleShoppingListDAO: ShoppingListDAO {
    
    var lists = [ShoppingList]()
    var listsIdCounter: Int = 0
    var itemsIdCounter: Int = 0
    
    internal func setBoughtToItemFromList(listId: Int, itemId: Int) throws {
        let list = try getListById(id: listId)
        let item = try list.getItemById(itemId: itemId)
        item.bought = true
    }

    internal func removeItemFromList(listId: Int, itemId: Int) throws {
        let list = try getListById(id: listId)
        let item = try list.getItemById(itemId: itemId)
        list.items.remove(item)
    }

    internal func addItemToList(listId: Int, item: ShoppingItem) throws {
        let list = try getListById(id: listId)
        item.entityId = itemsIdCounter
        itemsIdCounter += 1
        list.items.insert(item)
    }

    internal func getListById(id: Int) throws -> ShoppingList {
        for list in lists {
            if (list.entityId == id) {
                return list
            }
        }
        throw "List with id \(id) not found"
    }

    internal func removeList(listId: Int) throws {
        // TODO
    }

    internal func getLists() throws -> [ShoppingList] {
        return lists
    }

    internal func addList(list: ShoppingList) throws {
        if (!listExists(listName: list.name)) {
            list.entityId = listsIdCounter
            listsIdCounter += 1
            lists.append(list)
        } else {
            throw "List with name \(list.name) already exists"
        }
    }
    
    func listExists(listName: String) -> Bool {
        for list in lists {
            if (list.name == listName) {
                return true
            }
        }
        return false
    }
}

