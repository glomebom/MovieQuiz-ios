//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Gleb on 19.01.2024.
//

import Foundation

// Структура для отображения результатов в алерте
struct AlertModel {
    let title: String
    let text: String
    let buttonText: String
    init(title: String, text: String, buttonText: String) {
        self.title = title
        self.text = text
        self.buttonText = buttonText
    }
}
