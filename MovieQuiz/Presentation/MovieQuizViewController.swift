import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // Связь элементов на экране и кода
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Константа алерта
    private let alertPresenter = AlertPresenter()
    
    // Экземпляр класса MovieQuizPresenter
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        // Скругляем углы imageView при загрузке
        imageView.layer.cornerRadius = 20
        
        // Скрытие контейнеров постера и вопроса до загрузки данных
        hideViewAndLabel()
        
        // Свойство показа индикатора
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: - Actions
    
    // Приватный метод выполняемый при нажатии кнопки ДА
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // Приватный метод выполняемый при нажатии кнопки НЕТ
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Functions
    
    // Метод показа вопроса на экране
    func show(quiz step: QuizStepViewModel) {

        // Показываем элементы
        showViewAndLabel()
        
        // Задание значений элементам экран из view-модели
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
                
        // Убираем рамку которая остается от предыдущего ответа
        imageView.layer.borderWidth = 0
    }
    
    // Метод для показа алерта
    func show(quiz result: AlertModel) {
        // Вызов метода показа алерта с результатами
        alertPresenter.showAlert(controller: self, alertModel: result)
    }
    
    // Метод показа индикатора
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    // Метод скрытия индикатора
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // Метод показа постера и вопроса
    func showViewAndLabel() {
        imageView.alpha = 1.0
        textLabel.alpha = 1.0
    }
    
    // Метод скрытия постера и вопроса
    func hideViewAndLabel() {
        imageView.alpha = 0
        textLabel.alpha = 0
    }
    
    // Приватный метод включения/отключения кнопок
    func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // Метод подсветки постера в зависимости от ответа
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    // Метод показа ошибки
    func showNetworkError(message: String) {
        // Скрытие индикатора
        hideLoadingIndicator()
        
        // Константа для алерта, message берем из ошибки error.localizedDescription
        let alertModel = AlertModel(title: "Ошибка",
                                    text: message,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
            self?.presenter.restartGame()
        })
        
        // Вызов метода показа алерта
        self.show(quiz: alertModel)
    }
}
