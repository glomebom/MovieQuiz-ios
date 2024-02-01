//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Gleb on 30.01.2024.
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.errorMessage = try container.decode(String.self, forKey: .errorMessage)
        self.items = try container.decode([MostPopularMovie].self, forKey: .items)
    }
}

struct MostPopularMovie: Codable {
    // создаём кастомный enum для обработки ошибок
//    enum ParseError: Error {
//        case ratingFailure
//        case imageURLFailure
//    }
    
    let title: String
    let rating: String //Int//
    let imageURL: URL //Data//
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        
        self.rating = try container.decode(String.self, forKey: .rating)
        // Преобразование String -> Int
//        let rating = try container.decode(String.self, forKey: .rating)
//        guard let ratingValue = Int(rating) else {
//            throw ParseError.ratingFailure
//        }
//        self.rating = ratingValue
        
        self.imageURL = try container.decode(URL.self, forKey: .imageURL)
        // Преобразование URL -> Data
//        let imageURL = try container.decode(URL.self, forKey: .imageURL)
//        let imageData = try Data(contentsOf: imageURL)
//        self.imageURL = imageData
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}

