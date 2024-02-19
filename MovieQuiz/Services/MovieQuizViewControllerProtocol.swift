//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Gleb on 16.02.2024.
//

import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    var yesButton: UIButton! { get }
    var noButton: UIButton! { get }
    
    var alertModel: AlertModel? { get set }
    var activityIndicator: UIActivityIndicatorView! { get set }
    
    func show(quiz step: QuizStepViewModel)
    func showAlert(quiz result: AlertModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showNetworkError(message: String)
}
