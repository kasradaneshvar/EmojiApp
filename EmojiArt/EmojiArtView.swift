//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Kasra Daneshvar on 4/21/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class EmojiArtView: UIView , UIDropInteractionDelegate {
    
    var backgroundImage: UIImage? { didSet { setNeedsDisplay() } }
    
    func addLabel(with attributedString: NSAttributedString, centeredAt point: CGPoint) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label)
        addSubview(label) // "Add it as a `subView` to `self`.
    }
    
    override init(frame: CGRect) { // Absolutely no idea what and why these `init`'s are.
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy) // The fact that it's always allowing drops of `NSA..ing` matters here apparently.
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            let dropPoint = session.location(in: self) // Return location of drag in `self` coordinate system.
            for attributedString in providers as? [NSAttributedString] ?? [] {
                self.addLabel(with: attributedString, centeredAt: dropPoint)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        backgroundImage?.draw(in: bounds)
    }

}
