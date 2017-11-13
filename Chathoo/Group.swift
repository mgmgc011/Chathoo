//
//  Group.swift
//  Chathoo
//
//  Created by Chingoo on 9/6/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import Foundation

class Group {
    private var _groupTitle: String
    private var _groupDesc: String
    private var _key: String
    private var _userCount: Int
    private var _users: [String]
    
    var groupTitle: String {
        return _groupTitle
    }
    
    var groupDesc: String {
        return _groupDesc
    }
    
    var key: String {
        return _key
    }
    
    var userCount: Int {
        return _userCount
    }
    
    var users: [String] {
        return _users
    }
    
    init(title: String, description: String, key: String, users: [String], userCount: Int) {
        self._groupTitle = title
        self._groupDesc = description
        self._key = key
        self._users = users
        self._userCount = userCount
    }
}




struct Channel: Codable {
    let groupTItle: String
    let groupDescription: String
    let key: String
    let userCount: Int
    let users: [String]
}
