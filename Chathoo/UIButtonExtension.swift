//
//  UIButtonExtension.swift
//  Chathoo
//
//  Created by Chingoo on 8/29/17.
//  Copyright © 2017 Chingoo. All rights reserved.
//

import UIKit

class UIButtonExtension: UIButton {


    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    

}
