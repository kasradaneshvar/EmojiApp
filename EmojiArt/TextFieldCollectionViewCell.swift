//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by Kasra Daneshvar on 4/25/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    var resignationHandler: (() ->  Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) { // `CollectionViewCell`'s don't have a pointer to their collection view. A way should be found to talk to the collection view. Here, it is done with a closure.
        resignationHandler?() // "Any one interested in when the textField resigns can set the closure to something. Look at `cellForItemAt`.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
