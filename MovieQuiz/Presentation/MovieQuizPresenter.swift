//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Gleb on 15.02.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // Экземпляр фабрики вопросов
    private var questionFactory: QuestionFactoryProtocol?
    // Ссылка на контроллер для передачи данных и обращения
    private weak var viewController: MovieQuizViewController?
    // Экземпляр класса сервиса статистики
    private let statisticService: StatisticService! /*= StatisticServiceImplementation()*/
    
    // Экземпляр модели вопроса
    private var currentQuestion: QuizQuestion?
    // Количество вопросов
    private let questionsAmount: Int = 10
    // Количество правильных ответов
    private var correctAnswers: Int = 0
    // Переменная-счетчик количества правильных ответов
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        // Показ индикатора
        viewController.activityIndicator.hidesWhenStopped = true
        viewController.activityIndicator.startAnimating()
    }
    
    //     MARK: - QuestionFactoryDelegate
    
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
    
    func didLoadDataFromServer() {
        // Скрытие индикатора
        viewController?.activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion() // Запрашиваем следующий вопрос
    }
    
    func didFailToLoadData(with error: Error) {
        // Вызываем метод показа алерта с ошибкой, в сообщение для алерта передаем текст ошибки
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // Метод проверки на последний вопрос
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // Метод сброса счетчика вопросов
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // Метод увеличения сечтчика вопроса
    func switchToTheNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // Метод конвертации вопроса в view-модель
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // Приватный метод включения/отключения кнопок
    private func changeStateButtons(isEnabled: Bool) {
        viewController?.yesButton.isEnabled = isEnabled
        viewController?.noButton.isEnabled = isEnabled
    }
    
    // Нажатие на кнопку ДА
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    // Нажатие на кнопку НЕТ
    func noButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: false)
    }
    
    // Проверка нажатия ДА/НЕТ
    func didAnswer(isYes: Bool) {
        // Отключение кнопок
        changeStateButtons(isEnabled: false)
        
        // Константа для хранения данных из текущего вопроса
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        // Константа для записи значения ответа пользователя на вопрос
        let givenAnswer = isYes
        
        // Вызов метода проверки правильности ответа на вопрос
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // Метод проверки ответа на вопрос
    func proceedWithAnswer(isCorrect: Bool) {
        
        // Увеличение счетчика правильных ответов
        if isCorrect {
            correctAnswers += 1
        }
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    // Метод показ следующего вопроса или результатов
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            let text = makeResultMessage()
            
            viewController?.alertModel = viewController?.alertPresenter.createAlert(correct: correctAnswers, total: questionsAmount, message: text)
            guard let alertModel = viewController?.alertModel else { return }
            viewController?.showAlert(quiz: alertModel) // ОШИБКА 2: `show(quiz:)` не определён
        } else {
            self.switchToTheNextQuestion()
            // Показ индикатора
            viewController?.activityIndicator.startAnimating()
            questionFactory?.requestNextQuestion()
            // Скрытие индикатора
            viewController?.activityIndicator.stopAnimating()
        }
    }
    
    // Метод записи лучшего результата в хранилище и формирования строки сообщения для алерта с результатами
    func makeResultMessage() -> String {
        
        //Сохранение лучшего результата квиза и увеличение счетчиков статистики
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        // Параметры лучшего результата
        let bestGame = statisticService.bestGame
        
        // Формирование констант для итоговой строки
        let currentResult = "Ваш результат: \(String(correctAnswers))" + "/10"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        // Формирование итоговой строки для алерта
        let resultMessage = [currentResult, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
}
