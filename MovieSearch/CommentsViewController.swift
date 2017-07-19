//
//  CommentsViewController.swift
//  MovieSearch
//
//  Created by Kateryna Kononenko on 3/8/17.
//  Copyright © 2017 movie. All rights reserved.
//

import UIKit
import RealmSwift

class CommentsViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate {

    var movie: Movie!
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if movie.comments == nil {
            return 0
        }
        return movie.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        cell.comment.text = movie.comments[indexPath.row].comment
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let comment = Comment()
        comment.comment = textField.text
        if movie.comments == nil {
            movie.comments = List<Comment>()
        }
        movie.comments.append(comment)
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(movie, update: true)
        }
        
        tableView.reloadData()
        textField.text = ""
        textField.resignFirstResponder()
        
        return true
    }
}
