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
    
    let image: Data
    let text: String
    let correctAnswer: Bool
    
    init(image: Data, text: String, correctAnswer: Bool) {
        self.image = image
        self.text = text
        self.correctAnswer = correctAnswer
    }
}
