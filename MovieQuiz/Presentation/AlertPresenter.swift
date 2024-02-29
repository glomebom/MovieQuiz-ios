//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Gleb on 18.01.2024.
//

import Foundation
import UIKit

final class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?

    func showAlert(controller: UIViewController, alertModel: AlertModel) {
        
        let alert = UIAlertController(title: alertModel.title, message: alertModel.text, preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion!()
        }
        // Добавление действия к алерту
        alert.addAction(action)
        
        // Указание идентификатора для теста алерта
        alert.view.accessibilityIdentifier = "alertWindow"
        
        // Показ алерта
        controller.present(alert, animated: true, completion:nil)
    }
}
