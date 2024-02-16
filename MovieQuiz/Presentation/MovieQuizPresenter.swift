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
    
    //Шаг 5
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    
    // Экземпляр класса статистики
    var statisticService: StatisticService = StatisticServiceImplementation()
    
    
    var currentQuestion: QuizQuestion?
    
    // Ссылка на контроллер для передачи данных и обращения
    weak var viewController: MovieQuizViewController?
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        // Отключение кнопок
        changeStateButtons(isEnabled: false)
        
        // Константа для хранения данных из текущего mock`а
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        // Константа для записи значения ответа пользователя на вопрос
        let givenAnswer = isYes
        
        // Вызов метода проверки правильности ответа на вопрос
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // Приватный метод включения/отключения кнопок
    private func changeStateButtons(isEnabled: Bool) {
        viewController?.yesButton.isEnabled = isEnabled
        viewController?.noButton.isEnabled = isEnabled
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        
        // Включение кнопок
        changeStateButtons(isEnabled: true)
    }
    
    // Метод показ следующего вопроса или результатов
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            //Сохранение лучшего результата квиза и увеличение счетчиков статистики
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            //Текст результата игры
            let text =  "Ваш результат: \(String(correctAnswers))" + "/10" + "\n" + "Количество сыгранных квизов: \(statisticService.gamesCount)" + "\n" + "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))" + "\n" + "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            viewController?.alertModel = viewController?.alertPresenter.createAlert(correct: correctAnswers, total: questionsAmount, message: text)
            guard let alertModel = viewController?.alertModel else { return }
            viewController?.showAlert(quiz: alertModel) // ОШИБКА 2: `show(quiz:)` не определён
            // Сброс значений счетчиков
            self.correctAnswers = 0
            self.restartGame()
        } else {
            self.switchToTheNextQuestion()
            // Показ индикатора
            viewController?.activityIndicator.startAnimating()
            questionFactory?.requestNextQuestion()
            // Скрытие индикатора
            viewController?.activityIndicator.stopAnimating()
        }
    }
        
    // Метод проверки на последний вопрос
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // Метод сброса счетчика вопросов
    func restartGame() {
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
