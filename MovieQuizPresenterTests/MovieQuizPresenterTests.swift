//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Gleb on 19.02.2024.
//


import Foundation
import XCTest
@testable import MovieQuiz


final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var yesButton: UIButton!

    var noButton: UIButton!

    var alertModel: MovieQuiz.AlertModel?

    var activityIndicator: UIActivityIndicatorView!

    func show(quiz step: MovieQuiz.QuizStepViewModel) {
    }

    func showAlert(quiz result: MovieQuiz.AlertModel) {
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
    }

    func showNetworkError(message: String) {
    }
}


final class MovieQuizPresenterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

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
