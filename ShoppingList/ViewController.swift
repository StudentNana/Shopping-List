//
//  ViewController.swift
//  ShoppingList
//
//  Created by Sagitova Gulnaz on 01.02.17.
//  Copyright © 2017 Sagitova Gulnaz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    static let base_url = "http://localhost:8080/shopping/"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textFieldNewList: UITextField!
    var lists = [ShoppingList]()
    
    @IBAction func btnAddList(_ sender: AnyObject) {
        print("add List")
        if (textFieldNewList.text != "") {
            let list = ShoppingList(name: textFieldNewList.text!)
            
            let url = URL(string: ViewController.base_url + "list")
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
            textFieldNewList.text = ""
        }
    }
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        refreshTable()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func refresh() {
        if (tableView.refreshControl?.isRefreshing)! {
            tableView.refreshControl?.endRefreshing()
        }
        refreshTable()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(lists.count)
        return lists.count
    }
    
    func tableView(_ cellForRowAttableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.titleLabel.text = self.lists[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showItems", sender: self)
        print("here0")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("here1")
        if (segue.identifier == "showItems") {
            print("here2")
            let upcoming: ItemsViewController = segue.destination as! ItemsViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let listName = self.lists[indexPath.row].name
            let listId = self.lists[indexPath.row].entityId
            upcoming.listName = listName
            upcoming.listId = listId
            self.tableView.deselectRow(at: indexPath, animated: true)
            print("here3")
        }
    }

    
    // delete list
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let list = lists[indexPath.row]
            
            let url = URL(string: ViewController.base_url + "list/\(list.entityId)")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTable() {
        print("refresh")
        let url = URL(string: ViewController.base_url + "list")
            
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                
            guard let data = data, error == nil else {
                return // TODO show error message
            }
            
            let httpResponse = response as? HTTPURLResponse
            
            //print("Data:\(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
            
            if (httpResponse?.statusCode == 200) {
                let json: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                print("json:\(json)")
                self.lists = [ShoppingList](json:json as String)
                
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
    
}

public class LoadingOverlay {
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView) {
        overlayView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        overlayView.center = view.center
        overlayView.backgroundColor = UIColor.blue
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        overlayView.addSubview(activityIndicator)
        view.addSubview(overlayView)
        activityIndicator.startAnimating()
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
