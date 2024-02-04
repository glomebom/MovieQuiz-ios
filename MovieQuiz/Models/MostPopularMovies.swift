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
