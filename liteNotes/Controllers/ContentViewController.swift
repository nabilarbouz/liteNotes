//
//  ContentViewController.swift
//  liteNotes
//
//  Created by Nabil Arbouz on 7/11/19.
//  Copyright © 2019 Nabil Arbouz. All rights reserved.
//

import UIKit
import CoreData

class ContentViewController: UIViewController, UITextViewDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var textContentArray = [NoteContent]()
    
    var selectedNote : Note? {
        didSet {
            loadContent()
        }
    }
    
    var loadedText : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textArea.delegate = self
        textArea.text = loadedText
    }
    
    
    @IBOutlet var textArea: UITextView!

    
    func textViewDidEndEditing(_ textView: UITextView) {
        let newContent = NoteContent(context: context)
        
        newContent.content = textView.text
        newContent.parentNote = selectedNote
        
        textContentArray.append(newContent)

        saveContent()
    }
    
    
    func saveContent() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    
    
    func loadContent(with request : NSFetchRequest<NoteContent> = NoteContent.fetchRequest()) {
        
        let notePredicate = NSPredicate(format: "parentNote.title MATCHES %@", selectedNote!.title!)
        
        request.predicate = notePredicate
        
        do {
            textContentArray = try context.fetch(request)
        } catch {
            print("Error loading the note's content: \(error)")
        }
    

    }
}
