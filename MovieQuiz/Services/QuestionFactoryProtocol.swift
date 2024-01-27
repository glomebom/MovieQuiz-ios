//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Gleb on 16.01.2024.
//

import Foundation

protocol QuestionFactoryProtocol: AnyObject {
    var delegate: QuestionFactoryDelegate? { get set }
    func requestNextQuestion()
}
