//
//  Movie.swift
//  MovieQuiz
//
//  Created by Gleb on 22.01.2024.
//

import Foundation

struct Actor {
    let id: String
    let image: String
    let name: String
    let asCharacter: String
    
    init(id: String, image: String, name: String, asCharacter: String) {
        self.id = id
        self.image = image
        self.name = name
        self.asCharacter = asCharacter
    }
}

struct Movie {
    let id: String
    let title: String
    let year: Int
    let image: String
    let releaseDate: String
    let runtimeMins: Int
    let directors: String
    let actorList: [Actor]
    
    init(id: String, title: String, year: Int, image: String, releaseDate: String, runtimeMins: Int, directors: String, actorList: [Actor]) {
        self.id = id
        self.title = title
        self.year = year
        self.image = image
        self.releaseDate = releaseDate
        self.runtimeMins = runtimeMins
        self.directors = directors
        self.actorList = actorList
    }
}
