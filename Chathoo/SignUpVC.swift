//
//  SignUpVC.swift
//  Chathoo
//
//  Created by Chingoo on 9/6/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButtonExtension!
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupTFDelegates()
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        AuthSerivce.instace.registerUser(withEmail: self.emailTF.text!, withUsername: self.usernameTF.text!, andPassword: self.passwordTF.text!) { (success, registerationError) in
            if success {
                AuthSerivce.instace.signInUser(withEmail: self.emailTF.text!, andPassword: self.passwordTF.text!, signInComplete: { (success, loginError) in
                    if success {
                        let presentingVC = self.presentingViewController
                        self.dismiss(animated: false, completion: {
                            presentingVC?.dismiss(animated: true, completion: nil)
                            
                        })
                    } else {
                        let alert = UIAlertController(title: "Registered, Sign In Failed", message: loginError!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(okay)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            } else {
                let alert = UIAlertController(title: "Sign Up Failed", message: registerationError!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    
}

extension SignUpVC: UITextFieldDelegate {
    
    func setupTFDelegates() {
        emailTF.delegate = self
        passwordTF.delegate = self
        confirmTF.delegate = self
        usernameTF.delegate = self
        
        passwordTF.isSecureTextEntry = true
        confirmTF.isSecureTextEntry = true
        
        signUpButton.isEnabled = false
        signUpButton.alpha = 0.5
        
        emailTF.addTarget(self, action: #selector(textFieldDelegates), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(textFieldDelegates), for: .editingChanged)
        confirmTF.addTarget(self, action: #selector(textFieldDelegates), for: .editingChanged)
        usernameTF.addTarget(self, action: #selector(textFieldDelegates), for: .editingChanged)
        
    }
    
   @objc func textFieldDelegates(sender: UITextField) {
        guard let email = emailTF.text, !email.isEmpty,
            let pw = passwordTF.text, !pw.isEmpty,
            let confirm = confirmTF.text, !confirm.isEmpty,
            let username = usernameTF.text, !username.isEmpty,
            passwordTF.text == confirmTF.text else {
                passwordTF.layer.borderWidth = 1
                passwordTF.layer.cornerRadius = 5
                confirmTF.layer.borderWidth = 1
                confirmTF.layer.cornerRadius = 5
                passwordTF.layer.borderColor = UIColor.red.cgColor
                confirmTF.layer.borderColor = UIColor.red.cgColor
                signUpButton.isEnabled = false
                signUpButton.alpha = 0.5
                return
        }
        passwordTF.layer.borderWidth = 0
        confirmTF.layer.borderWidth = 0
        signUpButton.isEnabled = true
        signUpButton.alpha = 1
    }
    
    
    
    
}

