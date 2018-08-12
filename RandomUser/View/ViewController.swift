//
//  ViewController.swift
//  RandomUser
//
//  Created by Ana Rebollo Pin on 10/8/18.
//  Copyright © 2018 Ana Rebollo Pin. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var randomUsers = Set<User>()
    var selectedUser: User?
    var dbManager = DBManager()
    let filterFields = ["name","surname","email"]

    
    var url = URL(string: "https://api.randomuser.me/?results=2")!
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.configuration)
    typealias JSONDictionaryHandler = (([String:AnyObject]?) -> Void)

    @IBAction func FetchUser(_ sender: Any) {
        self.downloadJSONFromURL(_completion: { (data) in })
    }
    
    @IBAction func FilterUsers(_ sender: Any) {
        let alertController = UIAlertController(title: "Add filter",
                                                message: "",
                                                preferredStyle: .alert)
        
        let pickerView = UIPickerView(frame: CGRect(x: 30, y: 30, width: 200, height: 100))
        pickerView.delegate = self
        pickerView.dataSource = self
        alertController.view.addSubview(pickerView)
        
        let textField = UITextView(frame: CGRect(x: 30, y: 130, width: 200, height: 30))
        alertController.view.addSubview(textField)

        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let filter = textField.text
            var selectedValue = self.filterFields[pickerView.selectedRow(inComponent: 0)]

            self.randomUsers = self.dbManager.fetchUser(field: selectedValue, filter: filter)
            self.tableView.reloadData()
        }
        
        alertController.addAction(confirmAction)
        
        let height = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.30)
        alertController.view.addConstraint(height);
        self.present(alertController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.randomUsers = dbManager.fetchUser(field: nil, filter: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return randomUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CustomUICell
        let position = randomUsers.index(randomUsers.startIndex, offsetBy: indexPath.row)
        cell.printCell(user: randomUsers[position])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let position = randomUsers.index(randomUsers.startIndex, offsetBy: indexPath.row)
        selectedUser = randomUsers[position]
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
        detailVC.user = selectedUser
        navigationController?.pushViewController(detailVC, animated: false)
    }
    
    func mapDTOInModel(user:RandomAPIUser) {
        let currentUser = User(name: user.name.first, surname: user.name.last,
                            email: user.email, picture: user.picture.medium.absoluteString,
                            phone: user.cell, gender: user.gender,
                            registerDate: user.registered.date,
                            location: Location(street: user.location.street,
                                               city: user.location.city,
                                               state: user.location.state))
        
        self.randomUsers.insert(currentUser)
        DispatchQueue.main.async { [unowned self] in
            self.dbManager.saveUserLocally(user: currentUser)
            self.tableView.reloadData()
        }
    }
    
    func downloadJSONFromURL(_completion: @escaping JSONDictionaryHandler) {
        let request = URLRequest(url: self.url)
        let dataTask = session.dataTask(with: request)
        {(data, response,error) in
            if error == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        if let data = data {
                            do {
                                let callResult = try JSONDecoder().decode(RandomAPIResult.self, from:data)
                                for user in callResult.results {
                                    self.mapDTOInModel(user: user)
                                }
                            } catch let error as NSError {
                                print ("Error processing json data: \(error.description)")
                            }
                        }
                    default:
                        print("HTTP Response Code: \(httpResponse.statusCode)")
                    }
                }
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
        dataTask.resume()
    }
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete")
        { (action, view, handler) in
            let position = self.randomUsers.index(self.randomUsers.startIndex, offsetBy: indexPath.row)
            self.selectedUser = self.randomUsers[position]
            self.randomUsers.remove(at: position)
            self.tableView.reloadData()
        }
        deleteAction.backgroundColor = .gray
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterFields.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filterFields[row]
    }
}

