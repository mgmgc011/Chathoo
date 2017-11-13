//
//  SignInVC.swift
//  Chathoo
//
//  Created by Chingoo on 9/6/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var signInButton: UIButtonExtension!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTFDelegates()
    }
    
    @IBAction func signInAction(_ sender: Any) {
        if emailTF.text != nil && passwordTF.text != nil {
            AuthSerivce.instace.signInUser(withEmail: emailTF.text!, andPassword: passwordTF.text!, signInComplete: { (success, error) in
                if success {
                    let presentingVC = self.presentingViewController
                    self.dismiss(animated: true, completion: {
                        presentingVC?.dismiss(animated: true, completion: nil)
                    })
                } else {
                    self.errorAlert("Sign In Failed", message: error!.localizedDescription)
                }
                
            })
        }
    }
    
    @IBAction func closeBtnAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}




extension SignInVC: UITextFieldDelegate {
    
    func setupTFDelegates() {
        emailTF.delegate = self
        passwordTF.delegate = self
        
        passwordTF.isSecureTextEntry = true
        
        signInButton.isEnabled = false
        signInButton.alpha = 0.5
        
        emailTF.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        
    }
    
    @objc func textFieldIsNotEmpty(sender: UITextField) {
        guard
            let email = emailTF.text, !email.isEmpty,
            let pw = passwordTF.text, !pw.isEmpty else {
                signInButton.isEnabled = false
                signInButton.alpha = 0.5
                return
        }
        signInButton.isEnabled = true
        signInButton.alpha = 1
    }
    
    func errorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
