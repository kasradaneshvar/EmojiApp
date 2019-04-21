//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Kasra Daneshvar on 4/21/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {
    
    var backgroundImage: UIImage? { didSet { setNeedsDisplay() } }

    override func draw(_ rect: CGRect) {
        // Drawing code
        backgroundImage?.draw(in: bounds)
    }

}
