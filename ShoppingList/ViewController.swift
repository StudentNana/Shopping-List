//
//  ViewController.swift
//  ShoppingList
//
//  Created by Sagitova Gulnaz on 01.02.17.
//  Copyright © 2017 Sagitova Gulnaz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var textFieldNewList: UITextField!
    var tableView: UITableView  =   UITableView()
    var items: [String] = ["Kaisers", "Lidl", "Rossmann", "Kaisers", "Lidl", "Rossmann", "Kaisers", "Lidl", "Rossmann","Kaisers", "Lidl", "Rossmann", "Kaisers", "Lidl", "Rossmann", "Kaisers", "Lidl", "Rossmann"]
    
    @IBAction func btnAddList(_ sender: AnyObject) {
        print("add List")
        textFieldNewList.text = "Hallo"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.frame         =   CGRect(x: 0, y: 70, width: 320, height: 700)
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        // Scroll
        let numberOfSections = self.tableView.numberOfSections
        let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
        let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(items.count)
        return items.count
    }
    
    func tableView(_ cellForRowAttableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func example() {
        do {
            let dao: ShoppingListDAO  = SimpleShoppingListDAO()
            let list1 = ShoppingList(entityId: 0, name: "List 1")
            let item1 = ShoppingItem(entityId: 0, description: "Item 1")
            dao.addList(list: list1)
            try dao.addItemToList(listId: 0, item: item1)
            dao.addList(list: list1);
            let list2 = ShoppingList(entityId: 0, name: "List 2")
            dao.addList(list: list2)
            let item2 = ShoppingItem(entityId: 0, description: "Item 2")
            let item3 = ShoppingItem(entityId: 0, description: "Item 3")
            try dao.addItemToList(listId: 1, item: item2)
            try dao.addItemToList(listId: 1, item: item3)
            print("done")
        } catch {
            print(error)
        }
    }
    
}
