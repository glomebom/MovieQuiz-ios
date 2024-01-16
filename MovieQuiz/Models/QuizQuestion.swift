//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Gleb on 15.01.2024.
//

import Foundation

// Структура для вопроса
private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
    init(image: String, text: String, correctAnswer: Bool) {
        self.image = image
        self.text = text
        self.correctAnswer = correctAnswer
    }
}
