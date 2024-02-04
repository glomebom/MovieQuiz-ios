//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Gleb on 30.01.2024.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result <MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesURL: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/MostPopularTVs/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        // Вызов метода класса описывающего механизм запроса
        // Передаем в качестве параметра нужный URL
        // Передаем в замыкание возвращаемый объект либо данные либо ошибка
        networkClient.fetch(url: mostPopularMoviesURL) { result in
            // Перебираем то что передалось в замыкание исходя из значений описанных в структуре сетевого запроса
            // .failtrue или .success оно же Result.failure(error) Result.success(error)
            switch result {
                // Если вернулся код success то константу data передаем дальше
            case .success(let data):
                do { // Пробуем декодировать данные в структуру модели MostPopularMovies c полем ошибки и массивом объектов класса MostPopularMovie
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch { // Иначе отдаем в замыкание ошибку действия по которой описаны в структуре сетевого запроса
                    handler(.failure(error))
                }
                // Иначе отдаем в замыкание ошибку константой которая не описана в родительском замыкании действия по которой описаны в структуре сетевого запроса
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
