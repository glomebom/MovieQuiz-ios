//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Gleb on 15.02.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    // Количество вопросов
    let questionsAmount: Int = 10
    // Переменная-счетчик количества правильных ответов
    private var currentQuestionIndex: Int = 0
    
    // Метод проверки на последний вопрос
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // Метод сброса счетчика вопросов
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    // Метод увеличения сечтчика вопроса
    func switchToTheNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // Метод конвертации mock`а в view-модель
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
}
