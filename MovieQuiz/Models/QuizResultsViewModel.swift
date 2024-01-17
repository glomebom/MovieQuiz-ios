//
//  QuizResultsViewModel.swift
//  MovieQuiz
//
//  Created by Gleb on 15.01.2024.
//

import Foundation

// Структура для отображения результатов в алерте
struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
    init(title: String, text: String, buttonText: String) {
        self.title = title
        self.text = text
        self.buttonText = buttonText
    }
}
