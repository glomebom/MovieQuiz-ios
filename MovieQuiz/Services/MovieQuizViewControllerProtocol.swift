//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Gleb on 16.02.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAlert(quiz result: AlertModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showNetworkError(message: String)
}
