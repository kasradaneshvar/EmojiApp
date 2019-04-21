//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Kasra Daneshvar on 4/21/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate {
    
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    // ↓ Step 1/3 of drop: `canHandle`.
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    // ↓ Step 2/3 of drop: `sessionUpdate`.
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy) // Other than `.move` or `.cancel`.
    }
    
    var imageFetcher: ImageFetcher!
    
    // ↓ Step 3/3 of drop: `perform`.
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) { // Accept the drop. Recieve the drop. Call the closure.
        imageFetcher = ImageFetcher() { (url, image) in // `init` in `ImageFetcher` is unclear.
            DispatchQueue.main.async { // It doesn't put it on the `main` queue`.
                self.emojiArtView.backgroundImage = image
            }
        }
        
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            if let url = nsurls.first as? URL { // In case there is more than one drag.
                self.imageFetcher.fetch(url)
            }
        }
        session.loadObjects(ofClass: UIImage.self) { images in
            if let image = images.first as? UIImage { // If the `as?` fails, it just does nothing. User has to try another image.
                self.imageFetcher.backup = image
            }
        }
    }
    @IBOutlet weak var emojiArtView: EmojiArtView!
}
