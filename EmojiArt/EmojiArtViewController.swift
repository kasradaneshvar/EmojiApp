//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Kasra Daneshvar on 4/21/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

    // `UICollectionViewDelegateFlowLayout` is to have the default layout for the collection. `self` is automatically also its delegate.
class EmojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    //    var emojiArtView: EmojiArtView!
    var emojiArtView = EmojiArtView()
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet{
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView) // Note that here `emojiArtView` has to be initialized(?).
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) { // This is to set the size of the view when zoomed. Also in `emojiArt..Image` where it's first set.
        scrollViewHeight.constant = scrollView.contentSize.height // Note `contentSize`
        scrollViewWidth.constant = scrollView.contentSize.width
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { // Compare with `scrollView.addSubview`. Why need both?
        return emojiArtView
    }
    
    var emojiArtBackgroundImage: UIImage? { // Why need another var? Also `contentSize` is set here. Compare with the previous.
        get {
            return emojiArtView.backgroundImage
        }
        set {
            scrollView?.zoomScale = 1.0 // Where else could this be set?
            emojiArtView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero // Isn't this unwrapping twice? `UIImage` has `var size`?
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView.contentSize = size
            scrollViewHeight?.constant = size.height // Note the "optional chain": in case there is a `prepare`.
            scrollViewWidth?.constant = size.width
            if let dropZone = self.dropZone, size.width > 0, size.height > 0 { // This apparently doesn't do what is expected when a drop happens.
                scrollView.zoomScale = max(dropZone.frame.size.width / size.width, dropZone.frame.size.height / size.height) // Needs some calculation.
            }
        }
    }
    
    // MARK: Colleciton view.
    
    var emojis = "👹👾🧣🐮🐒🦅🐥🐃🦘🌱🌴🌷🌹🌏☂️🌈🌪☄️🥦🥑🍅🍉🍇🍒🍎".map { String($0) } // The model; an array of `String`.
    
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet {
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self // ↑ These two are the first things that have to be set in a `collectionView`.
            emojiCollectionView.dragDelegate = self // First step to drag from collection.
            emojiCollectionView.dropDelegate = self // Not setting this first took a while to figure out why "`collectionView` is not responding to any drop action".
        }
    }
    
    private var addingEmoji = false
    
    @IBAction func addEmoji() { // The "right" approach with a cell with a target-action is to have it send it to a custom cell. But here it's simplified.
        addingEmoji = true
        emojiCollectionView.reloadSections(IndexSet(integer: 0)) // This calls `cellForItem`, which switches the cell. Also what is `IndexSet`? "Docs".
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int { // Why not a `var`?
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { // Again, why not a `var`?
        switch section {
        case 0: return 1
        case 1: return emojis.count
        default: return 0
        }
    }
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0)) // For accessibility. Default to 64.0.
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) // Best guess, identify the "type" of cell to be reused. Or else, why need?
            if let emojiCell = cell as? EmojiCollectionViewCell { // This seems like it won't work: eventually `cell` is being returned, but `emojiCell` is being set up. Surprisingly, it does work.
                emojiCell.label.attributedText = NSAttributedString(string: emojis[indexPath.item], attributes: [.font:font])
            }
            return cell
        } else if addingEmoji {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiInputCell", for: indexPath)
            if let inputCell = cell as? TextFieldCollectionViewCell {
                inputCell.resignationHandler = { [weak self, unowned inputCell] in // There can be a memory cycle: `self` to `collectionView` to `cell` to `closure` to `self`. There also could have been a multi-threaded issue: "if cells were being scrolled off and scrolled back on, like in the homework".
                    if let text = inputCell.textField.text {
                        self?.emojis = (text.map { String($0) } + self!.emojis).uniquified // Second `self` was `!`ed because the first one would break if `nil`.
                    }
                    self?.addingEmoji = false
                    self?.emojiCollectionView.reloadData()
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEmojiButtonCell", for: indexPath)
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if addingEmoji && indexPath.section == 0 {
            return CGSize(width: 300, height: 80) // The nubmers should be set based on the size of the font that the user chose, accessibility, etc.
        } else {
            return CGSize(width: 80, height: 80)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { // This is called right before it displays a cell. Here, used to bring up keyboard.
        if let inputCell = cell as? TextFieldCollectionViewCell {
            inputCell.textField.becomeFirstResponder()
        }
    }
    
    //MARK: - UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] { // The logic to these stubs is not completely clear still.
        session.localContext = collectionView // This is so that for example when dropping to the collection view adding a new cell could be avoided. Also interestingly the context might not always be `collectionView`(How?).
        return dragItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] { // This is for "multiple drag".
        return dragItem(at: indexPath)
    }
    
    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] { // Return a `NSAttributedString`: an `itemProvider`. Other examples: UIImage, NSURL, etc.
        if !addingEmoji, let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString)) // `object` must "know" how to be a provider. Like a `NSAttributedString`.
            dragItem.localObject = attributedString // If the drag is within the app, don't go throw the procedure (assumingly) in the drag from earlier. " It's going to work when dragging from collection view to other apps, but when dragging locally, it will use this".
            return [dragItem]
        } else {
            return []
        }
    }
    
    // MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal { // Normally the `Proposal` is either `.copy`, `.move` or `.cancel`. Here the constructor also takes an `intent` that tells if a new cell should be added.
        // ⚠️ Why is `destinationIndexPath` 'optional'?
        if let indexPath = destinationIndexPath, indexPath.section == 1 {
            let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView // This is to distinguish the context for `operation`.
            return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0) // Destination may be "pathalogical", thus `??`.
        for item in coordinator.items { // "Might be dropping multiple items".
            if let sourceIndexPath = item.sourceIndexPath { // Apparently this does more than a `if let`; it shows that the drag is comming from `self` "because we have the `sourceIndexPath`. (?)
                if let attributedString = item.dragItem.localObject as? NSAttributedString { // What is `.dragItem` exactly?
                    collectionView.performBatchUpdates({ // Use this to insure that the collection view doesn't run out of sync with the model, which might occure in the `delete-insert` process. (Probably?) In general, used when doing multiple adjustments to table/collectionViews.
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destinationIndexPath.item)
                        // Then update collection view. "Do not 'reload data' in the middle of a drag because it resets the whole world. Bad".
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else { // No `sourceIndexPath`, so it's comming from "outside". In this case, it might take time for the content to be ready, so a 'placeholder' should be used until it arrives.
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell")) // Also takes a closure where `reusableCell` can be 'initialized' or do the `dequeue..Cell` which "is not goint to get called because it's a placeholder. Or do the 'outlet' setup. Here, there is no outlet.
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in // This closure is what it gives back, asyncronously, `onCompletion`.
                    DispatchQueue.main.async {
                        if let attributedString = provider as? NSAttributedString {
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in // `inser...th` might be different than `destination...th`, because 'loading' can take time.
                                self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
                
            }
        }
    }
    
    // MARK: Drop to `dropZone`.
    
    // Shouldn't the object that the interaction is being added to be specified? [Later answer: yes, look at `var dropZone`]
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
    // This needs a little more focus.
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) { // Accept the drop. Recieve the drop. Call the closure.
        imageFetcher = ImageFetcher() { (url, image) in // `init` in `ImageFetcher` is unclear.
            DispatchQueue.main.async { // It doesn't put it on the `main` queue`.
                //                self.emojiArtView.backgroundImage = image ---> Instead of setting this directly, use `var emojiArtBackgro..ge`
                self.emojiArtBackgroundImage = image
            }
        }
        
        session.loadObjects(ofClass: NSURL.self) { nsurls in // `loadObject`'s purpose is unclear.
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
}
