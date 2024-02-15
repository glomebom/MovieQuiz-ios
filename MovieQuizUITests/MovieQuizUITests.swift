//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Gleb on 11.02.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // Это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
        
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")

    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    // Тест алерта завершения игры
    func testResultAlert() {
        sleep(2)
        
        for _ in Range (1...10) {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let resultAlert = app.alerts["alertWindow"]
        let alertTitle = resultAlert.label
        let alertButton = resultAlert.buttons.firstMatch.label
        
        XCTAssertTrue(resultAlert.exists)
        XCTAssertEqual(alertTitle, "Этот раунд окончен!")
        XCTAssertEqual(alertButton, "Сыграть еще раз")
    }
    
    // Тест скрытия алерта завершения игры
    func testResultAlertDismiss() {
        sleep(2)
        
        for _ in Range (1...10) {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let resultAlert = app.alerts["alertWindow"]
        resultAlert.buttons.firstMatch.tap()
        
        sleep(5)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(resultAlert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
    
}
