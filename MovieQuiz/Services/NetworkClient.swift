//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Gleb on 29.01.2024.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    // Метод запроса/ответа по API
    func fetch(url: URL, handler: @escaping (Result<Data,Error>) -> Void) {
        // Преобразуем ссылку в URL-запрос
        let request = URLRequest(url: url)
        
        // Проверяем, пришла ли ошибка
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // Возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }

        task.resume()
    }
}
