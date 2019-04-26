//
//  EmojiArtDocumentTableViewController.swift
//  EmojiArt
//
//  Created by Kasra Daneshvar on 4/22/19.
//  Copyright © 2019 Kasra Daneshvar. All rights reserved.
//

import UIKit

class EmojiArtDocumentTableViewController: UITableViewController {

    var emojiArtDocuments = ["one", "Two", "Three"] // The model. Simple for now.
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Could have more sections, for example for "recent documents", etc.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emojiArtDocuments.count // Because there is only one section. Otherwise, had to `switch`.
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath) // Identifier was already set.

        // Configure the cell...
        cell.textLabel?.text = emojiArtDocuments[indexPath.row] // Getting data from the model.

        return cell
    }

    @IBAction func newEmojiArt(_ sender: UIBarButtonItem) {
        emojiArtDocuments += ["Untitled".madeUnique(withRespectTo: emojiArtDocuments)]
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() { // Set the preferred mode for `splitView`. Has to be put here because when layout changes in `splitView`, it resets the prefered mode.
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryHidden { // To prevent a loop where reseting `preferredDisplayMode` calls `viewWill..iews`
            splitViewController?.preferredDisplayMode = .primaryHidden
        }
    }
    
    // ↓ This is to allow editing the rows. If yes, it should remain unchanged. No need to override.
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // ↓ This one has to be implemented to commit edits to the model.
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            emojiArtDocuments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade) // Here, care must be taken to not get the model and the table out of sync (How?). Rowa have to be updated depending on how the model was updated.
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
