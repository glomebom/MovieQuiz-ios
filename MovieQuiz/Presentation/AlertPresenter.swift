//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Gleb on 18.01.2024.
//

import Foundation

final class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    
    // Метод создания модели алерта
    func createAlert(correct: Int, total: Int, message: String) -> AlertModel {
        // Задание параметров модели алерта
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            text: message,
            buttonText: "Сыграть еще раз")
        
        return alertModel
    }
}
