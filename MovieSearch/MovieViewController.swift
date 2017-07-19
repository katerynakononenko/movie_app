//
//  MovieViewController.swift
//  MovieSearch
//
//  Created by Kateryna Kononenko on 2/19/17.
//  Copyright © 2017 movie. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class MovieViewController:UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate{
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var movieCollections: UICollectionView!
    @IBOutlet weak var searchBarView: UISearchBar!
    var numberOfItemsPerRow:Int = 1;
    
    let margin: CGFloat = 5, cellsPerRow: CGFloat = 3;

    var movies = [Movie]()
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Movies"
        
        movieCollections.delegate = self;
        searchBarView.delegate = self
        
        
        movieCollections.dataSource = self
     
        
        
        /***
         Customising the flow layout of collection view so we can have 3 columns per row.
        **/
        guard let flowLayout = movieCollections?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin) // not required
        setCollectionViewCellsDisplay(for: view.bounds.size)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailView", let viewController = segue.destination as? MovieDetailViewController, let movie = sender as? Movie {
            viewController.movie = movie
        }
    }
    
        /**
            This code retains the size of the screen in case of orientation change
        **/
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setCollectionViewCellsDisplay(for: size)
    }
    
    
        /**
            This here is a func that helps in setting the height and width of each cell
        **/
    func setCollectionViewCellsDisplay(for size: CGSize) {
        guard let collectionView = movieCollections, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * (cellsPerRow - 1)
        let itemWidth = (size.width - marginsAndInsets) / cellsPerRow
        var cellsHeight: CGFloat = (itemWidth * 3) / 2
        cellsHeight = cellsHeight - 10;
        flowLayout.itemSize = CGSize(width: itemWidth, height: cellsHeight)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == movies.count - 1 && page != -1 {
            page += 1
            fetchMovieFromIMDB(text: searchBarView.text!)
        }
        let movie = movies[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movie_item",for:indexPath as IndexPath) as! MovieItem
        cell.movie_image.sd_setImage(with: URL(string: movie.poster), placeholderImage: UIImage(named: "empty_profile"))
        cell.movie_name.text = movie.title
        return cell
    }
    
    /**
        This handles when a an item is clicked from movie items
     **/
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailView", sender: movies[indexPath.item])
    }
    
    
    /**
        Search bar textDidChange implemented here
     **/
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 3){
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MovieViewController.fetchMovies), object: nil)
            self.perform(#selector(MovieViewController.fetchMovies), with: nil, afterDelay: 0.5)
        }
    }
    
    func fetchMovies() {
        movies = []
        page = 1
        fetchMovieFromIMDB(text: searchBarView.text!)
    }
    
    /**
        This func here is to refresh the table
    **/
    func refreshTable(){
        movieCollections.reloadData();
    }
    
    
    
    
    /**
        This func handles fetching of movies from the OMDB API
     **/
    func fetchMovieFromIMDB(text:String){
            let parameters = [
                "email":"",
                "password":"",
            ]
            
            let url:String = "https://www.omdbapi.com/?s=\(text)&page=\(page)";
        activityIndicator.startAnimating()
            Alamofire.request(url, method: .post, parameters: parameters).responseJSON { [weak self] (response) in
                self?.activityIndicator.stopAnimating()
                if let jsonObject = response.result.value {
                    
                    let json = JSON(jsonObject)
                    
                        let data = json["Search"].arrayValue

                        for movie in data {
                            self?.movies.append(Movie(json: movie))
                        }
                    
                    if data.isEmpty {
                        self?.page = -1
                    }
                    
                    DispatchQueue.main.async {
                        self?.movieCollections.reloadData()
                    }
                    
                }else{

                    self?.activityIndicator.stopAnimating()
                    self?.page = -1
                }
            }
    }
}





