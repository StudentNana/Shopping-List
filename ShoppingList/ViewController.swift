//
//  ViewController.swift
//  ShoppingList
//
//  Created by Sagitova Gulnaz on 01.02.17.
//  Copyright © 2017 Sagitova Gulnaz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    let dao: ShoppingListDAO  = SimpleShoppingListDAO()

    @IBOutlet var textFieldNewList: UITextField!
    var tableView: UITableView  =   UITableView()
    var lists = [ShoppingList]()
//    var items: [String] = ["Kaisers", "Lidl", "Rossmann", "Kaisers", "Lidl", "Rossmann", "Kaisers", "Lidl", "Rossmann","Kaisers", "Lidl", "Rossmann", "Kaisers", "Lidl", "Rossmann", "Kaisers", "Lidl", "Rossmann"]

    @IBAction func btnAddList(_ sender: AnyObject) {
        print("add List")
        if (textFieldNewList.text != "") {
            let list = ShoppingList(name: textFieldNewList.text!)
            do {
                try dao.addList(list: list)
            } catch {
                print(error)
                let alert = UIAlertController(title: "Error", message: "List with this name already exists", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                // show error in popup
            }
            textFieldNewList.text = ""
            refreshTable()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.frame         =   CGRect(x: 5, y: 70, width: 360, height: 700)
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        // Scroll
//        let numberOfSections = self.tableView.numberOfSections
//        let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
//        let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
//        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(lists.count)
        return lists.count
    }
    
    func tableView(_ cellForRowAttableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.contentView.transform = CGAffineTransform(scaleX: -1,y: 1);
        cell.imageView?.transform = CGAffineTransform(scaleX: -1,y: 1);
        cell.textLabel?.transform = CGAffineTransform(scaleX: -1,y: 1);
        cell.textLabel?.text = lists[indexPath.row].name
        cell.imageView?.image = UIImage(named: "arrow")

        return cell
    }
    // delete list
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            lists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    // selected list
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("selected")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func refreshTable() {
        do {
            try lists = dao.getLists()
        } catch {
            print(error)
            // show error in popup
        }
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }

    func example() {
        do {
            let dao: ShoppingListDAO  = SimpleShoppingListDAO()
            let list1 = ShoppingList(entityId: 0, name: "List 1")
            let item1 = ShoppingItem(entityId: 0, description: "Item 1")
            try dao.addList(list: list1)
            try dao.addItemToList(listId: 0, item: item1)
            try dao.addList(list: list1);
            let list2 = ShoppingList(entityId: 0, name: "List 2")
            try dao.addList(list: list2)
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
