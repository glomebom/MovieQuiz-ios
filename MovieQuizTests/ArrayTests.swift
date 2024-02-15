//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Gleb on 10.02.2024.
//

import Foundation
import XCTest
@testable import MovieQuiz // Импортируем наше приложение для тестирования

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        //Дано
        let array = [1,1,2,3,5]
        
        //Когда
        let value = array[safe: 2]
        
        //Тогда
        XCTAssertNotNil(value) // Элемент по индексу существует
        XCTAssertEqual(value, 2) // Элемент равен 2
        
//        дано — массив (например, массив чисел) из 5 элементов,
//        когда — мы берём элемент по индексу 2, используя наш сабскрипт,
//        тогда — этот элемент существует и равен третьему элементу из массива (потому что отсчёт индексов в массиве начинается с 0).
    }
    
    func testGetValueOutOfRange() throws {
        //Дано
        let array = [1,1,2,3,5]
        
        //Когда
        let value = array[safe: 20]
        
        //Тогда
        XCTAssertNil(value)
    }
}
