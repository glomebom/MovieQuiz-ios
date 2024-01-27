//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Gleb on 17.01.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
