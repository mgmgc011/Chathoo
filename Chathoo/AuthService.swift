//
//  AuthService.swift
//  Chathoo
//
//  Created by Chingoo on 9/6/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase


class AuthSerivce {
    static let instace = AuthSerivce()
    
    
    func registerUser(withEmail email: String, withUsername username: String, andPassword password: String, signUpComplete: @escaping(_ success: Bool, _ error: NSError?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let user = user else {
                signUpComplete(false, error as NSError?)
                return
            }
            
            let userData = [kUSERNAME: username,
                            kEMAIL: user.email!,
                            kUID: user.uid,
                            kLIKES: 0,
                            kPROVIDER: user.providerID] as [String : Any]
            
            
            DataService.instance.createDBUser(uid: user.uid, userData: userData)
            signUpComplete(true, nil)
        }
    }
    
    func signInUser(withEmail email: String, andPassword password: String, signInComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                signInComplete(false, error)
                return
            }
            signInComplete(true, nil)
        }
    }
    
    func signInAnonymously(signInComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().signInAnonymously { (user, error) in
            guard user != nil else {
                signInComplete(false, error)
                return
            }
            signInComplete(true, nil)
        }
    }
    
    
    
    
    
}
