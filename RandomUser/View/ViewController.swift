//
//  ViewController.swift
//  RandomUser
//
//  Created by Ana Rebollo Pin on 10/8/18.
//  Copyright © 2018 Ana Rebollo Pin. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var randomUsers = Set<User>()
    var selectedUser: User?
    
    var url = URL(string: "https://api.randomuser.me/?results=2")!
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.configuration)
    typealias JSONDictionaryHandler = (([String:AnyObject]?) -> Void)

    
    @IBAction func FetchUser(_ sender: Any) {
        downloadJSONFromURL(_completion: { (data) in })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLocalRepos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return randomUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
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
            self.saveUserLocally(user: currentUser)
            self.tableView.reloadData()
        }
    }
    
    func downloadJSONFromURL(_completion: @escaping JSONDictionaryHandler)
    {
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            let position = self.randomUsers.index(self.randomUsers.startIndex, offsetBy: indexPath.row)
            self.selectedUser = self.randomUsers[position]
            self.randomUsers.remove(at: position)
            self.tableView.reloadData()
        }
        deleteAction.backgroundColor = .gray
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func saveUserLocally(user: User) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(user.name, forKey: "name")
        newUser.setValue(user.surname, forKey: "surname")
        newUser.setValue(user.gender, forKey: "gender")
        newUser.setValue(user.email, forKey: "email")
        newUser.setValue(user.picture, forKey: "picture")
        newUser.setValue(user.phone, forKey: "phone")
        newUser.setValue(user.registerDate, forKey: "registerDate")
        do {
            try context.save()
        } catch {
            print("Failed saving repos in DB")
        }
    }
    
    func fetchLocalRepos() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let name = data.value(forKey: "name") as? String,
                   let surname = data.value(forKey: "surname") as? String,
                   let gender = data.value(forKey: "gender") as? String,
                   let email = data.value(forKey: "email") as? String,
                   let picture = data.value(forKey: "picture") as? String,
                   let phone = data.value(forKey: "phone") as? String,
                   let registeredDate = data.value(forKey: "phone") as? String {
                   let location = Location(street: "qaaaa", city: "bb", state: "ccc")
                   let user = User(name: name, surname: surname,
                         email: email, picture: picture,
                         phone: phone, gender: gender,
                         registerDate: registeredDate,
                         location: location)
                    
                    randomUsers.insert(user)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
