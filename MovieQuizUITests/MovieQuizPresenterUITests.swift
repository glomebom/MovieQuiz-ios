//
//  MovieQuizPresenterUITests.swift
//  MovieQuizUITests
//
//  Created by Gleb on 16.02.2024.
//

import Foundation
import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var yesButton: UIButton!
    
    var noButton: UIButton!
    
    var alertModel: MovieQuiz.AlertModel?
    
    var alertPresenter: MovieQuiz.AlertPresenter?
    
    var activityIndicator: UIActivityIndicatorView!
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        <#code#>
    }
    
    func showAlert(quiz result: MovieQuiz.AlertModel) {
        <#code#>
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        <#code#>
    }
    
    func showNetworkError(message: String) {
        <#code#>
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
         XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
