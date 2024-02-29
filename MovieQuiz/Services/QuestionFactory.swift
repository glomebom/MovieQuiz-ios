//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Gleb on 15.01.2024.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    // Обработка ошибок возвращаемых в поле errorMessage ответа от сервера
    private enum MoviesError: Error, LocalizedError {
        case custom(message: String)
        
        var errorDescription: String? {
            switch self {
            case .custom(message: let message):
                return NSLocalizedString(message, comment: message)
            }
        }
    }
    
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // Переменная массива объектов получаемых по результатам запроса
    private var movies: [MostPopularMovie] = []
    
    // Метод формирования случайного вопроса и правильного ответа
    private func makeQuestion(from film: MostPopularMovie) -> [String: Bool] {
        
        // Константа рейтинга из загруженных данных
        let rating = Float(film.rating) ?? 0
        // Константа рейтинга для формирования вопроса
        let randomRating = Int.random(in: 5..<10)
        // Определяем сравнение которое будет указано в вопросе
        let condition = ["graterThan": "больше", "lessThan": "меньше"]
        // Константа для правильного ответа
        var correctAnswer: Bool
        
        // Выбор сравнения больше/меньше для вопроса
        guard let randomCondition = condition.randomElement() else { return ["Error":false] }
        
        // Формирование вопроса
        let text = "Рейтинг этого фильма \(randomCondition.value) чем \(randomRating)?"
 
        // Определение правильного ответа исходя из сформированного вопроса
        correctAnswer = rating > Float(randomRating) ? (randomCondition.key == "graterThan" ? true : false) : (randomCondition.key == "lessThan" ? true : false)
        
        // Возвращаем объект с результатами
        return [text: correctAnswer]
    }
    
    // Метод загрузки данных
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            // Ответ от загрузчика необходимо перевести в главный поток
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    // Если errorMessage не пустое
                    if mostPopularMovies.errorMessage != "" {
                        self.delegate?.didFailToLoadData(with: MoviesError.custom(message: mostPopularMovies.errorMessage))
                    } else {
                        // Если ошибок нет
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    }
                    // Если есть ошибки с кодом
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    // Метод запроса следующего вопроса из массива объектов
    func requestNextQuestion() {
        // Запуск получения данных по сети в отдельном потоке, асинхронно
        DispatchQueue.global().async { [weak self] in
            // Выбор произвольного элемента массива для показа
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            
            // Загрузка данных по ссылке
            var imageData = Data()
            do {
                // Загрузка увеличенной картинки с помощью метода вычисляемого значения resizedImage
                imageData = try Data(contentsOf: movie.resizedImage)
            } catch {
                print("Failed to load image")
                // Передача информации об ошибке загрузки в основной поток
                DispatchQueue.main.async{
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
            
            // Константа с случайным вопросом и правильным ответом
            let questionToShow: [String: Bool] = makeQuestion(from: movie)
            
            // Константы вопроса и правильного ответа
            let text = questionToShow.first?.key
            let correctAnswer = questionToShow.first?.value
            
            // Формирование модели вопроса
            guard let text = text, let correctAnswer = correctAnswer else { return }
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            // После того как данные получены, возвращаем вопрос через делегат в основной поток
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
