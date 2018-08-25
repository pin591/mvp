//
//  RandomUserListViewcontroller.swift
//  RandomUser
//
//  Created by Ana Rebollo Pin on 25/8/18.
//  Copyright © 2018 Ana Rebollo Pin. All rights reserved.
//

import UIKit

class RandomUserListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension RandomUserListViewController: UITableViewDataSource {
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CustomUICell
        return cell
    }
}

extension RandomUserListViewController: RandomUserListDelegate {
    
}
