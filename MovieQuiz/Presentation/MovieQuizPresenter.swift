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
    private weak var viewController: MovieQuizViewControllerProtocol?
    // Экземпляр класса сервиса статистики
    private let statisticService: StatisticService!
    
    // Экземпляр модели вопроса
    private var currentQuestion: QuizQuestion?
    // Количество вопросов
    private let questionsAmount: Int = 10
    // Количество правильных ответов
    private var correctAnswers: Int = 0
    // Переменная-счетчик количества правильных ответов
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol?) {
        
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        viewController?.showLoadingIndicator()
    }
    
    //     MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        
        // Включение кнопок
        viewController?.changeStateButtons(isEnabled: true)
    }
    
    func didLoadDataFromServer() {
        // Скрытие индикатора
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion() // Запрашиваем следующий вопрос
    }
    
    func didFailToLoadData(with error: Error) {
        // Вызываем метод показа алерта с ошибкой, в сообщение для алерта передаем текст ошибки
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // Метод проверки на последний вопрос
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // Метод сброса счетчика вопросов
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // Метод увеличения сечтчика вопроса
    private func switchToTheNextQuestion() {
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
    
    // Нажатие на кнопку ДА
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    // Нажатие на кнопку НЕТ
    func noButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: false)
    }
    
    // Проверка нажатия ДА/НЕТ
    private func didAnswer(isYes: Bool) {
        // Отключение кнопок
        viewController?.changeStateButtons(isEnabled: false)
        
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
    private func proceedWithAnswer(isCorrect: Bool) {
        // Увеличение счетчика правильных ответов
        if isCorrect {
            correctAnswers += 1
        }
        
        // Вызов метода окраски рамки
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    // Метод показ следующего вопроса или результатов
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            // Вызов метода формирования текста с результатами
            let text = makeResultMessage()
            
            // Формируем модель алерта
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            
            // Вызов метода показа алерта
            viewController?.show(quiz: alertModel)
        } else {
            // Увеличение индекса вопроса в массиве
            switchToTheNextQuestion()
            // Показ индикатора
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
            // Скрытие индикатора
            viewController?.hideLoadingIndicator()
        }
    }
    
    // Метод записи лучшего результата в хранилище и формирования строки сообщения для алерта с результатами
    private func makeResultMessage() -> String {
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
