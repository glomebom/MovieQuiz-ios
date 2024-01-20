//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Gleb on 18.01.2024.
//

import Foundation

class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    
    // Метод создания модели алерта
    func createAlert(cAnswers: Int, qAmount: Int) -> AlertModel {
        // Текст в переменную для удобства редактирования
        let text = cAnswers == qAmount ? "Поздравляем, вы ответили на 10 из 10!" :
        "Вы ответили на \(cAnswers) из 10, попробуйте ещё раз!"
        //            "Ваш результат: \(String(correctAnswers))" + "/10"/* + "\n" + "Количество сыгранных квизов: 1" + "\n" + "Рекорд 0/0 (дата время)" + "\n" + "Средняя точность: 00.00%"*/
        
        // Задание параметров модели алерта
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть еще раз")

        return alertModel
    }
}
