//
//  FirstViewController.swift
//  Chathoo
//
//  Created by Chingoo on 8/28/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import UIKit
import FirebaseAuth

class FeedVC: UIViewController {
    
    
    @IBOutlet weak var feedTB: UITableView!
    var groups = [Group]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTB.delegate = self
        feedTB.dataSource = self
        loadGroups()
    }
    
    private func loadGroups() {
        let currentUser = Auth.auth().currentUser

        if let userUID = currentUser?.uid {
            DataService.instance.getMyGroups(forUID: userUID, handler: { (fetchedGroups) in
                self.groups = fetchedGroups

                print(fetchedGroups)
            })


        }
        
        
        
    }
    
    
    @IBAction func signOutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let initialVC = storyboard.instantiateViewController(withIdentifier: "InitialVC") as? InitialVC
            self.present(initialVC!, animated: true, completion: nil)
        } catch {
            print(error)
        }
    }
    
    
}





extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = feedTB.dequeueReusableCell(withIdentifier: "cell") as? FeedCell else { return UITableViewCell() }
        
        
        return cell
    }
    
    
}








