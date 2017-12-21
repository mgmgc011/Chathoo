//
//  TitleVC.swift
//  Chathoo
//
//  Created by Chingoo on 12/20/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import UIKit


class DescriptionVC: UIViewController, UITextFieldDelegate {
    
    var groupTitle : String?
    var groupDescription : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        print(groupTitle)
    }
    
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "Verdana", size: 17)
        lb.textColor = .black
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.text = "Add Description"
        return lb
    }()
    
    let inputTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 17)
        tf.backgroundColor = .white
        tf.textAlignment = .center
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let textFieldLine: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let countLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10)
        lb.textColor = .black
        lb.textAlignment = .right
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "0/30"
        return lb
    }()
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
        
        let image = UIImage(named: "back_btn")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleBack))
    }
    
    private func setupViews() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.view.addSubview(inputTextField)
        inputTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 100).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        
        inputTextField.becomeFirstResponder()
        inputTextField.addTarget(self, action: #selector(TitleVC.textfieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        
        self.view.addSubview(textFieldLine)
        textFieldLine.topAnchor.constraint(equalTo: inputTextField.bottomAnchor).isActive = true
        textFieldLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        textFieldLine.leftAnchor.constraint(equalTo: inputTextField.leftAnchor).isActive = true
        textFieldLine.widthAnchor.constraint(equalTo: inputTextField.widthAnchor).isActive = true
        
        self.view.addSubview(countLabel)
        countLabel.topAnchor.constraint(equalTo: textFieldLine.bottomAnchor).isActive = true
        countLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        countLabel.leftAnchor.constraint(equalTo: inputTextField.leftAnchor).isActive = true
        countLabel.rightAnchor.constraint(equalTo: inputTextField.rightAnchor).isActive = true
    }
    
    @objc func textfieldDidChange(textField: UITextField) {
        if let textcount = textField.text?.count, textcount >= 30 {
            textField.textColor = .red
            countLabel.textColor = .red
        } else {
            textField.textColor = .black
            countLabel.textColor = .black
        }
        countLabel.text = "\(textField.text!.count)/30"
    }
    
    @objc func handleNext() {
        
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
}












