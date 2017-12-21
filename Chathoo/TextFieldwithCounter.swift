//
//  TextFieldwithCounter.swift
//  Chathoo
//
//  Created by Chingoo on 12/6/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import UIKit




class TextFieldwithCounter: UIView {
    
    let textfield: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.layer.borderWidth = 1.0
        tf.layer.borderColor = UIColor.oraColor().cgColor
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 10
        tf.textAlignment = .center
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Name the Group!"
        return tf
    }()
    
    let countLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.textColor = .black
        lb.textAlignment = .right
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = UIColor.oraColor()
        return lb
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.addSubview(countLabel)
        countLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        countLabel.widthAnchor.constraint(equalToConstant: 25).isActive = true
        countLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        countLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        self.addSubview(textfield)
        textfield.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        textfield.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textfield.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textfield.bottomAnchor.constraint(equalTo: countLabel.topAnchor).isActive = true
        
        
        
    }
    
    
    
    
    
    
}
