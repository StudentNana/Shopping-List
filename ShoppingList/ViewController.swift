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
    
    
}
