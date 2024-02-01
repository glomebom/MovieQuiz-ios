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
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
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
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
            }
            
            // Определяем рейтинг // рейтинг был разным для каждого вопроса
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            // После того как данные получены, возвращаем вопрос через делегат в основной поток
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
        
        // ПРЕДЫДУЩАЯ ВЕРСИЯ МЕТОДА
        //        guard let index = (0..<movies.count).randomElement() else {
        //            delegate?.didReceiveNextQuestion(question: nil)
        //            return
        //        }
        //
        //        let question = movies[safe: index]
        
        //let questionMovie = movies[safe: index]
        
        // Т.к. модели разные нужно приводить типы
        // Рейтинг переводим из String -> Int и вычисляем ответ в сравнении
        //        guard let rating = questionMovie?.rating as? Int else { return }
        //        let answer = rating > 6 ? true : false
        //
        //        // Передаем в метод показа значения из модели MostPopularMovie
        //        let question: QuizQuestion = QuizQuestion(image: questionMovie?.imageURL ?? Data(), text: questionMovie?.title ?? String(), correctAnswer: answer)
        
        //        delegate?.didReceiveNextQuestion(question: question)
    }
}


// Массив mock`ов
//private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false)
//    ]
