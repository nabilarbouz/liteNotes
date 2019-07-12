//
//  NoteViewController.swift
//  liteNotes
//
//  Created by Nabil Arbouz on 7/10/19.
//  Copyright © 2019 Nabil Arbouz. All rights reserved.
//

import UIKit
import CoreData


class NoteViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedFolder : Folder? {
        didSet {
            loadNotes()
        }
    }
    
    var notes = [Note]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)

        let note = notes[indexPath.row]
        
        cell.textLabel?.text = note.title
        
        return cell
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new note", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add a new note", style: .default) { (action) in
            let newNote = Note(context: self.context)
            
            newNote.title = textField.text!
            
            newNote.parentFolder = self.selectedFolder
            
            self.notes.append(newNote)
            
            self.saveNotes()
        }
        
        alert.addTextField { (field) in
            field.placeholder = "Adde a new note"
            textField = field
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveNotes() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadNotes(with request: NSFetchRequest<Note> = Note.fetchRequest(), predicate: NSPredicate? = nil) {
       
        let folderPredicate = NSPredicate(format: "parentFolder.name MATCHES %@", selectedFolder!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, additionalPredicate])
        } else {
            request.predicate = folderPredicate
        }
        
        do {
            notes = try context.fetch(request)
        } catch {
            print("Error loading the notes: \(error)")
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToContent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ContentViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
           destinationVC.selectedNote = notes[indexPath.row]
            if let destinationText = notes[indexPath.row].noteContent?.content {
                destinationVC.loadedText = destinationText
            }
        }
    }
}

extension NoteViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Note> = Note.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadNotes(with: request, predicate: predicate)
        
    }
    
    //this function returns the original list once the user clears the search bar text area
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadNotes()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
