//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Gleb on 15.01.2024.
//

import Foundation
import UIKit

// Структура для отображения вопроса на экране
struct QuizStepViewModel {
    
    let image: UIImage
    let question: String
    let questionNumber: String
    init(image: UIImage, question: String, questionNumber: String) {
        self.image = image
        self.question = question
        self.questionNumber = questionNumber
    }
}
