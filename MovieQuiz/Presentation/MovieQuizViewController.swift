import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // Связь элементов на экране и кода
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //    // Переменная-счетчик количества правильных ответов
    //    var correctAnswers: Int = 0
    
    // Константа и переменная для фабрики вопросов
    private var questionFactory: QuestionFactoryProtocol?
    
    // Константа и переменная для показа алерта
    let alertPresenter = AlertPresenter()
    
    var alertModel: AlertModel?
    
    //    // Экземпляр класса статистики
    //    var statisticService: StatisticService = StatisticServiceImplementation()
    
    // Экземпляр класса MovieQuizPresenter
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Делегат фабрики вопросов
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        // Делегат класса показа алерта
        alertPresenter.delegate = self
        
        // Показ индикатора
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        // Загрузка данных
        questionFactory?.loadData()
        
        presenter.viewController = self
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        // Скрытие индикатора
        activityIndicator.stopAnimating()
        
        questionFactory?.requestNextQuestion() // Запрашиваем следующий вопрос
    }
    
    func didFailToLoadData(with error: Error) {
        // Вызываем метод показа алерта с ошибкой, в сообщение для алерта передаем текст ошибки
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - AlertPresenterDelegate
    
    // Метод для показа результатов раунда квиза
    func showAlert(quiz result: AlertModel) {
        
        // Константа для алерта
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        // Константа для caption`а кнопки и действий выполняемых по нажатию на кнопку
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            
            // разворачиваем слабую ссылку
            guard let self = self else { return }
            
            questionFactory?.requestNextQuestion() // Запрашиваем следующий вопрос
        }
        
        // Добавление действия к алерту
        alert.addAction(action)
        
        // Указание идентификатора для теста алерта
        alert.view.accessibilityIdentifier = "alertWindow"
        
        // Показ алерта
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    // Приватный метод выполняемый при нажатии кнопки ДА
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // Приватный метод выполняемый при нажатии кнопки НЕТ
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private functions
    
    // Метод показа ошибки
    private func showNetworkError(message: String) {
        // Скрытие индикатора
        activityIndicator.stopAnimating()
        // Константа для алерта, message берем из ошибки error.localizedDescription
        let alert = AlertModel(title: "Ошибка",
                               text: message,
                               buttonText: "Попробовать ещё раз")
        
        // Сброс значений счетчиков
        self.presenter.correctAnswers = 0
        self.presenter.restartGame()
        
        // Вызов метода показа алерта с попыткой загрузки данных
        self.showAlert(quiz: alert)
    }
    
    // Метод показа вопроса на экране
    func show(quiz step: QuizStepViewModel) {
        
        // Задание значений элементам экран из view-модели
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        
        // Убираем рамку которая остается от предыдущего вызова метода проверки ответа на вопрос
        imageView.layer.borderWidth = 0
    }
    
    // Приватный метод проверки ответа на вопрос
    func showAnswerResult(isCorrect: Bool) {
        // Параметры рамки изображения
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        
        // Окраски рамки изображения в зависимости от ответа
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // Увеличение счетчика правильных ответов
        if isCorrect {
            presenter.correctAnswers += 1
        }
        
        // Запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Показываем следующий mock или результаты через 1 секунду
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
}
