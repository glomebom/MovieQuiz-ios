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
    var completion: (() -> Void)?
}
