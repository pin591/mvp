//
//  DBManager.swift
//  RandomUser
//
//  Created by Ana Rebollo Pin on 12/8/18.
//  Copyright © 2018 Ana Rebollo Pin. All rights reserved.
//

import UIKit
import CoreData

class  DBManager {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
    
    func saveUserLocally(user: User) {
    
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

    func fetchUser(field: String? ,filter: String?) -> Set<User> {
        
        var randomUser = Set<User>()
        
        if (filter != nil) {
            request.predicate = NSPredicate(format: "\(field!) = %@", filter!)
        }
        do {
            let result = try context.fetch(request)
            
            let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            request.sortDescriptors = sortDescriptors
            
            for data in result as! [NSManagedObject] {
                if let name = data.value(forKey: "name") as? String,
                    let surname = data.value(forKey: "surname") as? String,
                    let gender = data.value(forKey: "gender") as? String,
                    let email = data.value(forKey: "email") as? String,
                    let picture = data.value(forKey: "picture") as? String,
                    let phone = data.value(forKey: "phone") as? String,
                    let registeredDate = data.value(forKey: "registerDate") as? String {
                    let location = Location(street: "qaaaa", city: "bb", state: "ccc")
                    let user = User(name: name, surname: surname,
                                    email: email, picture: picture,
                                    phone: phone, gender: gender,
                                    registerDate: registeredDate,
                                    location: location)
                    randomUser.insert(user)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return randomUser
    }
}
