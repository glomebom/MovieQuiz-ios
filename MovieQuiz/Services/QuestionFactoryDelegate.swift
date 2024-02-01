//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Gleb on 17.01.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // Сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // Сообщение об успешной загрузке
}
