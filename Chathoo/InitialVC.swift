//
//  InitialVC.swift
//  Chathoo
//
//  Created by Chingoo on 9/6/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func strangerModeAction(_ sender: Any) {
        AuthSerivce.instace.signInAnonymously { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.errorAlert("Something Went Wrong!", message: (error?.localizedDescription)!)
            }
        }
        
    }
    
    
    func errorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}
