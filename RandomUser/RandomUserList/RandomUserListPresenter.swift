//
//  RamdomUserListPresenter.swift
//  RandomUser
//
//  Created by Ana Rebollo Pin on 25/8/18.
//  Copyright © 2018 Ana Rebollo Pin. All rights reserved.
//

import Foundation

class RandomUserListPresenter {
    
    let delegate: RandomUserListDelegate
    let model = RandomUserListModel()
    
    var userListSize: Int? {
        get { return model.usersSize }
    }
    
    init(delegate: RandomUserListDelegate) {
        self.delegate = delegate
        loadData()
    }
    
    func loadData() {
        delegate.showLoading()
        var timer = Timer.scheduledTimer(timeInterval: 10, target: self,
                                         selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        delegate.hideLoading()
    }
    
    func userAt(position: Int) -> User{
        return model.at(position: position)
    }
    
    
}


