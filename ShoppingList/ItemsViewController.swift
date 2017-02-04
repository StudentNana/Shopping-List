//
//  ItemsViewController.swift
//  ShoppingList
//
//  Created by Sagitova Gulnaz on 03.02.17.
//  Copyright © 2017 Sagitova Gulnaz. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var newItem: UITextField!
    @IBOutlet var listNameLabel: UILabel!
    var list: ShoppingList = ShoppingList()
    var listName: String!
    var listId: Int!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(list.items.count)
        return list.items.count
    }
    
    func tableView(_ cellForRowAttableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellItem") as! ItemTableViewCell
        cell.itemName.text = self.list.items[indexPath.row].name
        cell.boughtButton.setTitle(self.list.items[indexPath.row].bought ? "Yes" : "No", for: .normal)
        cell.boughtButton.tag = self.list.items[indexPath.row].entityId
        if (!self.list.items[indexPath.row].bought) {
            cell.boughtButton.addTarget(self, action: #selector(ItemsViewController.itemBought), for: .touchUpInside)
        }
        return cell
    }
    
    func itemBought(sender: UIButton) {
        let entityId = sender.tag
        print("item Bought")
        let url = URL(string: ViewController.base_url + "list/\(listId!)/item/\(entityId)/bought")
        var request: URLRequest = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error)
                return// TODO show error message
            }
            
            let httpResponse = response as? HTTPURLResponse
            
            print("Data:\(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
            
            if (httpResponse?.statusCode == 200) {
                DispatchQueue.main.async{
                    LoadingOverlay.shared.hideOverlayView()
                    self.refreshTable()
                }
            } else {
                DispatchQueue.main.async{
                    LoadingOverlay.shared.hideOverlayView()
                    self.showDefaultError()
                }
            }
        }
        
        task.resume()
    }
    
    @IBAction func addItem(_ sender: AnyObject) {
        print("add Item")
        if (newItem.text != "") {
            let list = ShoppingItem(name: newItem.text!)
            
            let url = URL(string: ViewController.base_url + "list/\(listId!)/item")
            var request: URLRequest = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.httpBody = list.toJsonData()
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                
                guard let data = data, error == nil else {
                    return // TODO show error message
                }
                
                let httpResponse = response as? HTTPURLResponse
                
                print("Data:\(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                
                if (httpResponse?.statusCode == 201) {
                    DispatchQueue.main.async{
                        LoadingOverlay.shared.hideOverlayView()
                        self.refreshTable()
                    }
                } else {
                    DispatchQueue.main.async{
                        LoadingOverlay.shared.hideOverlayView()
                        self.showDefaultError()
                    }
                }
            }
            
            task.resume()
            newItem.text = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.listNameLabel.text = self.listName
        
        self.tableView.separatorStyle = .none
        refreshTable()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTable() {
        print("refresh")
        let url = URL(string: ViewController.base_url + "list/\(listId!)")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            
            guard let data = data, error == nil else {
                return // TODO show error message
            }
            
            let httpResponse = response as? HTTPURLResponse
            
            print("Data:\(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
            
            if (httpResponse?.statusCode == 200) {
                let json: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                print("json:\(json)")
                self.list = ShoppingList(json:json as String)
                
                DispatchQueue.main.async{
                    LoadingOverlay.shared.hideOverlayView()
                    self.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async{
                    LoadingOverlay.shared.hideOverlayView()
                    self.showDefaultError()
                }
            }
        }
        
        LoadingOverlay.shared.showOverlay(view: self.view)
        
        task.resume()
        
        print("Done!!!")
    }
    
    // delete list
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = list.items[indexPath.row]
            
            let url = URL(string: ViewController.base_url + "list/\(list.entityId)/item/\(item.entityId)")
            var request: URLRequest = URLRequest(url: url!)
            request.httpMethod = "DELETE"
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                
                guard let data = data, error == nil else {
                    return // TODO show error message
                }
                
                let httpResponse = response as? HTTPURLResponse
                
                print("Data:\(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                
                if (httpResponse?.statusCode == 200) {
                    DispatchQueue.main.async{
                        LoadingOverlay.shared.hideOverlayView()
                        self.refreshTable()
                    }
                } else {
                    DispatchQueue.main.async{
                        LoadingOverlay.shared.hideOverlayView()
                        self.showDefaultError()
                    }
                }
            }
            
            task.resume()
            
        }
    }
    

    /*
        Everything below should go to base class
    */
    
    func showDefaultError() {
        showError(title: "Error", message: "Ooops! Something wrong", buttonTitle: "Ok")
    }
    
    func showError(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButton(withTitle: buttonTitle)
        alert.show()
    }
    
    func refresh() {
        if (tableView.refreshControl?.isRefreshing)! {
            tableView.refreshControl?.endRefreshing()
        }
        refreshTable()
    }

}
