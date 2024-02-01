//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Gleb on 30.01.2024.
//

//{"id":"tt2356777",
//    "rank":"1",
//    "rankUpDown":"0",
//    "title":"True Detective",
//    "fullTitle":"True Detective (TV Series 2014–)",
//    "year":"2014",
//    "image":"https://m.media-amazon.com/images/M/MV5BNTEzMzBiNGYtYThiZS00MzBjLTk5ZWItM2FmMzU3Y2RjYTVlXkEyXkFqcGdeQXVyMjkwOTAyMDU@._V1_Ratio0.6763_AL_.jpg",
//    "crew":"",
//    "imDbRating":"8.9",
//    "imDbRatingCount":"630193"
//}

import Foundation

struct MostPopularMovies: Codable {
    
    private enum Keys: CodingKey {
        case errorMessage, items
    }
    
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
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
    
    let title: String
    let rating: String//String //Int//
    let imageURL: URL //Data//
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        
        self.rating = try container.decode(String.self, forKey: .rating)
        // Преобразование String -> Int
//        let rating = try container.decode(String.self, forKey: .rating)
//        guard let ratingValue = Float(rating) else {
//            throw ParseError.ratingFailure
//        }
//        self.rating = ratingValue
        
        self.imageURL = try container.decode(URL.self, forKey: .imageURL)
        // Преобразование URL -> Data
//        let imageURL = try container.decode(URL.self, forKey: .imageURL)
//        let imageData = try Data(contentsOf: imageURL)
//        self.imageURL = imageData
    }
}

