//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Gleb on 15.01.2024.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            // Ответ от загрузчика необходимо перевести в главный поток
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    // Если массив фильмов оказался пустым
                    if mostPopularMovies.items.isEmpty {
                        self.delegate?.didFailToLoadData(with: "Ошибка загрузки перечня фильмов" as! any Error)
                    // Если есть сообщение об ошибке
                    } else if mostPopularMovies.errorMessage != "" {
                        self.delegate?.didFailToLoadData(with: "\(mostPopularMovies.errorMessage)" as! any Error)
                    } else {
                    // Если все ошибок нет
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
            
            // Определяем рейтинг, рейтинг разный для каждого вопроса
            let rating = Float(movie.rating) ?? 0
            let randomRating = Int.random(in: 5..<10)
            let text = "Рейтинг этого фильма больше чем \(randomRating)?"
            let correctAnswer = rating > Float(randomRating)
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
