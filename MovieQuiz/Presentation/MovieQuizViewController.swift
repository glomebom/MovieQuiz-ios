import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // Связь элементов на экране и кода
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
//    // Переменная-счетчик количества правильных ответов
    private var correctAnswers: Int = 0
    
    // Константа и переменная для фабрики вопросов
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    // Константа и переменная для показа алерта
    private let alertPresenter = AlertPresenter()
    private var alertModel: AlertModel?
    
    // Экземпляр класса статистики
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
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
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        
        // Включение кнопок
        changeStateButtons(isEnabled: true)
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
        
        // Отключение кнопок
        changeStateButtons(isEnabled: false)
        
        // Константа для хранения данных из текущего mock`а
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        // Константа для записи значения ответа пользователя на вопрос
        let givenAnswer = true
        
        // Вызов метода проверки правильности ответа на вопрос
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // Приватный метод выполняемый при нажатии кнопки НЕТ
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        // Отключение кнопок
        changeStateButtons(isEnabled: false)
        
        // Константа для хранения данных из текущего mock`а
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        // Константа для записи значения ответа пользователя на вопрос
        let givenAnswer = false
        
        // Вызов метода проверки правильности ответа на вопрос
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
        self.correctAnswers = 0
        self.presenter.resetQuestionIndex()
        
        // Вызов метода показа алерта с попыткой загрузки данных
        self.showAlert(quiz: alert)
    }

    // Приватный метод показа вопроса на экране
    private func show(quiz step: QuizStepViewModel) {
        
        // Задание значений элементам экран из view-модели
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        
        // Убираем рамку которая остается от предыдущего вызова метода проверки ответа на вопрос
        imageView.layer.borderWidth = 0
    }
    
    // Приватный метод проверки ответа на вопрос
    private func showAnswerResult(isCorrect: Bool) {
        // Параметры рамки изображения
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        
        // Окраски рамки изображения в зависимости от ответа
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // Увеличение счетчика правильных ответов
        if isCorrect {
            correctAnswers += 1
        }
        
        // Запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Показываем следующий mock или результаты через 1 секунду
            guard let self = self else { return } // разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
        }
    }
    
    // Приватный метод показ следующего mock`а или результатов
    private func showNextQuestionOrResults() {
        
        // Если текущий mok был последним
        if presenter.isLastQuestion() {
            
            //Сохранение лучшего результата квиза и увеличение счетчиков статистики
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            // Текст алерта по результатам квиза
            let text =  "Ваш результат: \(String(correctAnswers))" + "/10" + "\n" + "Количество сыгранных квизов: \(statisticService.gamesCount)" + "\n" + "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))" + "\n" + "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            // Создание модели алерта
            alertModel = alertPresenter.createAlert(correct: correctAnswers, total: presenter.questionsAmount, message: text)
            guard let alertModel = alertModel else { return }
            
            // Вызов метода показа модели алерта
            self.showAlert(quiz: alertModel)
            
            // Сброс значений счетчиков
            self.correctAnswers = 0
            self.presenter.resetQuestionIndex()
            
        } else {
            
            // Переход к следующему вопросу
            presenter.switchToTheNextQuestion()
            
            // Показ индикатора
            activityIndicator.startAnimating()
            
            self.questionFactory?.requestNextQuestion() // Запрашиваем следующий вопрос
            
            // Скрытие индикатора
            activityIndicator.stopAnimating()
        }
    }
    
    // Приватный метод включения/отключения кнопок
    private func changeStateButtons(isEnabled: Bool) {
            yesButton.isEnabled = isEnabled
            noButton.isEnabled = isEnabled
        }
}
