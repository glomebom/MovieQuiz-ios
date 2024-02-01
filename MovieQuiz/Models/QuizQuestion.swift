//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Gleb on 15.01.2024.
//

import Foundation
import UIKit

// Структура для вопроса
struct QuizQuestion {
//    let image: String
    let image: Data
    let text: String
    let correctAnswer: Bool
//    init(image: String, text: String, correctAnswer: Bool) {
//        self.image = image
    init(image: Data, text: String, correctAnswer: Bool) {
        self.image = image
        self.text = text
        self.correctAnswer = correctAnswer
    }
    
//    let imageData = try Data(contentsOf: someImageURL) // try, потому что загрузка данных по URL может быть и не успешной
//    let image = UIImage(data: imageData)
}
