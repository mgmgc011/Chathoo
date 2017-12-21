//
//  DataService.swift
//  Chathoo
//
//  Created by Chingoo on 9/6/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth




class DataService {
    
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child(kUSERS)
    private var _REF_GROUPS = DB_BASE.child(kGROUPS)
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    
    //    MARK: USER
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func getUserProfile(forUID uid: String, handler: @escaping (_ user: User)-> ()) {
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: { (userSnapshot) in
            let username = userSnapshot.value(forKey: kUSERNAME) as! String
            let userEmail = userSnapshot.value(forKey: kEMAIL) as! String
            let userUID = userSnapshot.value(forKey: kUID) as! String
            let likes = userSnapshot.value(forKey: kLIKES) as! Int
            let provider = userSnapshot.value(forKey: kPROVIDER) as! String
            let groups = userSnapshot.value(forKey: kGROUPS) as! [String]
            let imageURL = userSnapshot.value(forKey: kIMAGEURL) as! String
            let user = User(username: username, email: userEmail, uid: userUID, likes: likes, provider: provider, groups: groups, imageUrl: imageURL)
            handler(user)
        })
    }
    
//    func updateUserProfile(forUID uid: String, withUser: User, handler: @escaping (_ updated: Bool, _ error: Error?) -> ()) {
//        let currentUID = Auth.auth().currentUser?.uid
//        Auth.auth().currentUser?.updatePassword(to: <#T##String#>, completion: <#T##UserProfileChangeCallback?##UserProfileChangeCallback?##(Error?) -> Void#>)
//    }
    
    func likeUser(from fromUID: String, to toUID: String) {
        REF_USERS.child(toUID).updateChildValues([kLIKES: fromUID])
        REF_USERS.child(fromUID).updateChildValues([kLIKED: toUID])
    }
    
    
    
    //    MARK: GROUPS
    func createGroup(withTitle title: String, andDescription description: String, forUserIds ids: [String], handler: @escaping (_ groupCreated: Bool, _ error: Error?) -> ()) {
        let values = [kTITLE: title, kDESCRIPTION: description, kMEMBERS: ids] as [String : Any]
        REF_GROUPS.childByAutoId().updateChildValues(values) { (error, database) in
            if error != nil {
                handler(false, error!)
            }
            handler(true, nil)
        }
    }
    
    // Add to Edit Group page
    func validateGroupOwner(forGroupUID uid: String, handler: @escaping (_ isOwner: Bool) -> ()) {
        let userUID = Auth.auth().currentUser?.uid
        if uid == userUID {
            handler(true)
        } else {
            handler(false)
        }
    }
    
    
    //    CALL validateGroupOwner BEFORE
    func changeGroupInfo(forGroupID uid: String, withTitle title: String, andDescription description: String, handler: @escaping (_ groupUpdated: Bool, _ error: Error?) -> ()) {
        let values = [kTITLE: title, kDESCRIPTION: description]
        REF_GROUPS.child(uid).updateChildValues(values) { (error, database) in
            guard error == nil else {
                handler(false, error)
                return
            }
            handler(true, nil)
        }
    }
    
    func getAllGroups(handler: @escaping (_ groupsArray: [Group]) -> ()) {
        var groupsArray = [Group]()
        REF_GROUPS.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for group in snapshot {
                let userArray = group.childSnapshot(forPath: kUSERS).value as! [String]
                let title = group.childSnapshot(forPath: kTITLE).value as! String
                let description = group.childSnapshot(forPath: kDESCRIPTION).value as! String
                let group = Group(title: title, description: description, key: group.key, users: userArray, userCount: userArray.count)
                groupsArray.append(group)
            }
            handler(groupsArray)
        })
    }
    
    func getMyGroups(forUID uid: String, handler: @escaping (_ groupsArray: [Group]) -> ()) {
        var groupsArray = [Group]()
        REF_GROUPS.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for groupSnap in snapshot {
                let userArray = groupSnap.childSnapshot(forPath: kUSERS).value as! [String]
                if userArray.contains(uid) {
                    let title = groupSnap.childSnapshot(forPath: kTITLE).value as! String
                    let description = groupSnap.childSnapshot(forPath: kDESCRIPTION).value as! String
                    let group = Group(title: title, description: description, key: groupSnap.key, users: userArray, userCount: userArray.count)
                    groupsArray.append(group)
                }
            }
            handler(groupsArray)
        })
    }
    
    func joinGroup(userUID uid: String, toGroupUID groupUID: String, handler: @escaping (_ groupJoined: Bool, _ error: Error?) -> ()) {
        let groupValue = [kMEMBERS: uid]
        let userValue = [kGROUPS: groupUID]
        REF_GROUPS.child(groupUID).updateChildValues(groupValue) { (error, database) in
            if error == nil {
                self.REF_USERS.child(uid).updateChildValues(userValue)
                handler(true, nil)
            } else {
                handler(false, error)
            }
        }
    }
    
    func createGroup(creatorUID creator_UID: String, groupUID group_UID: String, groupName group_Name: String, description desc: String, handler: @escaping (_ groupCreated: Bool, _ error: Error?) -> ()) {
        
        let value = [kADMINS:creator_UID, kGROUPUID:group_UID, kGROUPNAME:group_Name, kDESCRIPTION: desc, kUSERS: [creator_UID]] as [String : Any]
        REF_GROUPS.child(group_UID).updateChildValues(value) { (error, database) in
            if error == nil {
                handler(true, nil)
            } else {
                handler(false, error)
            }
        }
        
    }
    
    
//    func leaveGroup(userUID uid: String, fromGroupUID groupUID: String, handler: @escaping (_ groupLeft: Bool, _ error: Error?) -> ()) {
//        
//    }
    
    
}













