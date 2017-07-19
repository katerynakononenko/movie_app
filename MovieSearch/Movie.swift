//
//  Movie.swift
//  MovieSearch
//
//  Created by Kateryna Kononenko on 2/19/17.
//  Copyright © 2017 movie. All rights reserved.
//

import Foundation
import SwiftyJSON
import Realm
import RealmSwift

class Comment: Object {
    dynamic var comment: String!
}

class Movie: Object {
    
    dynamic var movie_id:String!
    dynamic var title:String!
    dynamic var ratings:Int = 0
    dynamic var rated:String!
    dynamic var realeased:String!
    dynamic var poster:String!
    var comments:List<Comment>!
    dynamic var isFavorite: Bool = false
    
    init(json: JSON) {
        super.init()
        self.movie_id = json["imdbID"].stringValue
        self.title = json["Title"].stringValue
        self.ratings = json["Metascore"].intValue
        self.rated = json["Rated"].stringValue
        self.realeased = json["Year"].stringValue
        self.poster = json["Poster"].stringValue
    }
    
    override class func primaryKey() -> String {
        return "movie_id"
    }
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
}


