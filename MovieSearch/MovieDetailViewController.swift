//
//  MovieDetailViewController.swift
//  MovieSearch
//
//  Created by Kateryna Kononenko on 2/19/17.
//  Copyright © 2017 movie. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON
import RealmSwift

class MovieDetailViewController:UIViewController{
    
    
    @IBOutlet weak var movie_image: UIImageView!
    @IBOutlet weak var release_date: UILabel!
    @IBOutlet weak var rated: UILabel!
    @IBOutlet weak var ratings: UILabel!
    
    @IBOutlet weak var btn_add_to_favorite: UIButton!
    @IBOutlet weak var acitivityIndicator: UIActivityIndicatorView!
    
    var movie: Movie!
    var isFavorite = false
   
    @IBAction func addToFavorites(_ sender: Any) {
        let realm = try! Realm()
        
        
        if isFavorite == false {
            
            try! realm.write {
                movie.isFavorite = true
            }
            
            btn_add_to_favorite.setTitle("Remove from Favorites", for: .normal)
        } else {
            
            
            try! realm.write {
                movie.isFavorite = false
            }
            
            btn_add_to_favorite.setTitle("Add to Favorites", for: .normal)
        }
        
        try! realm.write {
            realm.add(movie, update: true)
        }
        
        
        isFavorite = !isFavorite
    }
    

    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        /**
            Setting border background
        **/
        btn_add_to_favorite.backgroundColor = .clear
        btn_add_to_favorite.layer.cornerRadius = 5
        btn_add_to_favorite.layer.borderWidth = 1
        btn_add_to_favorite.layer.borderColor = UIColor.blue.cgColor

        
        
        fetchMovieFromIMDB()
       displayMovieInfo()
        
        let realm = try! Realm()
        let allMovies = realm.objects(Movie.self).filter("movie_id == %@", movie.movie_id)
        print("all movies: \(allMovies.count)")
        if let result = realm.objects(Movie.self).filter("movie_id == %@", movie.movie_id).first {
            if result.isFavorite == false {
                try! realm.write {
                    movie.isFavorite = false
                }
                
            } else {
                try! realm.write {
                    movie.isFavorite = true
                }
                isFavorite = true
                btn_add_to_favorite.setTitle("Remove from Favorites", for: .normal)
            }
        } else {
            try! realm.write {
                movie.isFavorite = false
            }
        }
    }
    
    func fetchMovieFromIMDB(){
        
        
        let url:String = "https://www.omdbapi.com/?i=\(movie.movie_id!)";
        
        acitivityIndicator.startAnimating()
        Alamofire.request(url, method: .post, parameters: nil).responseJSON { [weak self] (response) in
            self?.acitivityIndicator.stopAnimating()
            if let jsonObject = response.result.value {
                
                let json = JSON(jsonObject)
                
                self?.movie = Movie(json: json)
                
                DispatchQueue.main.async {
                    self?.displayMovieInfo()
                }
                
            }else{
                // TODO:
                // show error dialog
            }
        }
    }

    
    func displayMovieInfo() {
        if let url = URL(string: movie.poster) {
            movie_image.sd_setImage(with: url)
        }
        if let movieTitle = movie.title {
            title = movieTitle
        }
        if let date = movie.realeased {
            release_date.text = "Date released: \(date)"
        }
        if let movieRated = movie.rated {
            rated.text = "Rated: \(movieRated)"
        }
        
        ratings.text = "Score: \(movie.ratings) / 100"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? CommentsViewController {
            viewController.movie = movie
        }
    }
}

