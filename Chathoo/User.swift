//
//  User.swift
//  Chathoo
//
//  Created by Chingoo on 9/12/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import Foundation



class User {
    private var _username: String
    private var _userEmail: String
    private var _userUID: String
    private var _likes: Int
    private var _provider: String
    private var _joinedGroups: [String]
    
    
    var username: String {
        return _username
    }
    
    var userEmail: String {
        return _userEmail
    }
    
    var userUID: String {
        return _userUID
    }
    
    var likes: Int {
        return _likes
    }
    
    var provider: String {
        return _provider
    }
    
    var joinedGroups: [String] {
        return _joinedGroups
    }
    
    init(username: String, email: String, uid: String, likes: Int, provider: String, groups: [String]) {
        self._username = username
        self._userEmail = email
        self._userUID = uid
        self._likes = likes
        self._provider = provider
        self._joinedGroups = groups
    }
    
}
