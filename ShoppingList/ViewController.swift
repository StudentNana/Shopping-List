//
//  ViewController.swift
//  ShoppingList
//
//  Created by Sagitova Gulnaz on 01.02.17.
//  Copyright © 2017 Sagitova Gulnaz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    let base_url = "http://localhost:8080/shopping/"

    @IBOutlet var textFieldNewList: UITextField!
    var tableView: UITableView  =   UITableView()
    var lists = [ShoppingList]()
    
    var refreshControl = UIRefreshControl()
    
    @IBAction func btnAddList(_ sender: AnyObject) {
        print("add List")
        if (textFieldNewList.text != "") {
            let list = ShoppingList(name: textFieldNewList.text!)
            
            let url = URL(string: base_url + "list")
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
                        // TODO show error
                    }
                }
            }
            
            task.resume()
            textFieldNewList.text = ""
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
        refreshTable()
        
//        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshtable:", for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        
    }
    
        // Scroll
//        let numberOfSections = self.tableView.numberOfSections
//        let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
//        let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
//        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
    
    
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

        cell.tag = lists[indexPath.row].entityId
        
//        cell.imageView?.isUserInteractionEnabled = true
//        cell.imageView?.tag = lists[indexPath.row].entityId
        
        return cell
    }
    
    // delete list
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let list = lists[indexPath.row]
            
            let url = URL(string: base_url + "list/\(list.entityId)")
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
                        // TODO show error
                    }
                }
            }
            
            task.resume()
            
        }
    }
    // selected list
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //print("selected")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTable() {
        print("refresh")
        let url = URL(string: base_url + "list")
            
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
                    // TODO show error
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
