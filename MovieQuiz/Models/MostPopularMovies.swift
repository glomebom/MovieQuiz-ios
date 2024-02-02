//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Gleb on 30.01.2024.
//

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
    enum ParseError: Error {
        case ratingFailure
        case imageURLFailure
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
    
    let title: String
    let rating: String
    let imageURL: URL
    
    var resizedImage: URL {
        // Создание строки из адреса
        let urlString = imageURL.absoluteString
        // Изменение окончания строки
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        // Создаем новый URL
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        
        // Возвращаем новый URL
        return newURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        
        //self.rating = try container.decode(String.self, forKey: .rating)
        // Для случая когда rating в у фильма nil
        if let rating = try? container.decode(String.self, forKey: .rating) {
            self.rating = rating
        } else {
            self.rating = "0"
        }

        self.imageURL = try container.decode(URL.self, forKey: .imageURL)
    }
}

