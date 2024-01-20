import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // Связь элементов на экране и кода
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    // Переменная-счетчик текущего вопроса
    private var currentQuestionIndex: Int = 0
    // Переменная-счетчик количества правильных ответов
    private var correctAnswers: Int = 0
    // Количество вопросов
    private let questionsAmount: Int = 10
    
    // Константа и переменная для фабрики вопросов
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    // Константа и переменная для показа алерта
    private let alertPresenter = AlertPresenter()
    private var alertModel: AlertModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
        
        alertPresenter.delegate = self
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        print("Вызов didReceiveNextQuestion:QuestionFactoryDelegate")
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    
    // Метод для показа результатов раунда квиза
    // Принимает вью модель AlertModel и ничего не возвращает
    func showAlert(quiz result: AlertModel) {
        print("Вызов showAlert")
        // Константа для алерта
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        // Константа для caption`а кнопки и действий выполняемых по нажатию на кнопку
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            
            // разворачиваем слабую ссылку
            guard let self = self else { return }
            
            // Задаем исходные значения для начала нового раунда
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            // Начало нового раунда
            questionFactory.requestNextQuestion()
        }
        
        // Добавление действия к алерту
        alert.addAction(action)
        
        // Показ алерта
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    // Приватный метод выполняемый при нажатии кнопки ДА
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
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
    
    // Приватный метод конвертации mock`а в view-модель
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // Приватный метод показа mock`а на экране
    private func show(quiz step: QuizStepViewModel) {
        
        // Задание значений элементам экран из view-модели mock`а
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
        if currentQuestionIndex == questionsAmount - 1 {
            
            // Создание модели алерта
            alertModel = alertPresenter.createAlert(cAnswers: correctAnswers, qAmount: correctAnswers)
            guard let alertModel = alertModel else { return }
            
            // Вызов метода показа модели алерта
            self.showAlert(quiz: alertModel)
            
        } else {
            
            // Переход к следующему вопросу
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
        }
    }
}
