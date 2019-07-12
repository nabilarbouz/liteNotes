//
//  FolderViewController.swift
//  liteNotes
//
//  Created by Nabil Arbouz on 7/10/19.
//  Copyright © 2019 Nabil Arbouz. All rights reserved.
//

import UIKit
import CoreData

class FolderViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var folders = [Folder]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadFolders()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return folders.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        
        cell.textLabel?.text = folders[indexPath.row].name
        
        return cell
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a folder", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newFolder = Folder(context: self.context)
            
            newFolder.name = textField.text!
            
            self.folders.append(newFolder)
            
            self.saveFolders()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func saveFolders() {
        do {
            try context.save()
        } catch {
            print("There was an error saving the folders: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadFolders() {
        let request : NSFetchRequest<Folder> = Folder.fetchRequest()
        
        do {
            folders = try context.fetch(request)
        } catch {
            print("There was an error loading the folders: \(error)")
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNotes", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NoteViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedFolder = folders[indexPath.row]
        }
    }

}
