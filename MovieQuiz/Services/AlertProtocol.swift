//
//  AlertProtocol.swift
//  MovieQuiz
//
//  Created by Gleb on 18.01.2024.
//

import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(quiz result: AlertModel)
}
