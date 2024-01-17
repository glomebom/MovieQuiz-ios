import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
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
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory?.delegate = self
        questionFactory?.requestNextQuestion()
        //        if let firstQuestion = questionFactory.requestNextQuestion() {
        //            currentQuestion = firstQuestion
        //            let viewModel = convert(model: firstQuestion)
        //            show(quiz: viewModel)
        //        }
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    
    // Приватный метод выполняемый при нажатии кнопки ДА
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        //        // Константа для хранения данных из текущего mock`а
        //        let currentQuestion = questions[currentQuestionIndex]
        
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
        
        //        // Константа для хранения данных из текущего mock`а
        //        let currentQuestion = questions[currentQuestionIndex]
        
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
            
            // Текст в переменную для удобства редактирования
            let text = correctAnswers == questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            //            "Ваш результат: \(String(correctAnswers))" + "/10"/* + "\n" + "Количество сыгранных квизов: 1" + "\n" + "Рекорд 0/0 (дата время)" + "\n" + "Средняя точность: 00.00%"*/
            
            // Задание параметров модели алерта
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            
            // Вызов метода для показа результатов раунда квиза
            show(quiz: viewModel)
            
        } else {
            
            // Переход к следующему вопросу
            currentQuestionIndex += 1
            
            //            // Константа для данных следующего mock`а
            //            let nextQuestion = questions[currentQuestionIndex]
            //            // Константа для модели mok`а
            //            let viewModel = convert(model: nextQuestion)
            //
            //            // Вызов метода для показа следующего mock`а на экране
            //            show(quiz: viewModel)
            
//            if let nextQuestion = questionFactory.requestNextQuestion() {
//                currentQuestion = nextQuestion
//                let viewModel = convert(model: nextQuestion)
//                
//                show(quiz: viewModel)
//            }
            
            self.questionFactory?.requestNextQuestion()
            
        }
    }
    
    // Приватный метод для показа результатов раунда квиза
    // Принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        
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
            
            //            // Константа для выбора 0-го элемента из массива mok`ов
            //            let firstQuestion = self.questions[self.currentQuestionIndex]
            //            // Константа для модели mok`а первого вопроса
            //            let viewModel = self.convert(model: firstQuestion)
            //
            //            // Вызов метода показа первого mok`а
            //            self.show(quiz: viewModel)
            
//            if let firstQuestion = self.questionFactory.requestNextQuestion() {
//                self.currentQuestion = firstQuestion
//                let viewModel = self.convert(model: firstQuestion)
//                
//                self.show(quiz: viewModel)
//            }
            
            questionFactory?.requestNextQuestion()
            
        }
        
        // Добавление действия к алерту
        alert.addAction(action)
        
        // Показ алерта
        self.present(alert, animated: true, completion: nil)
    }
    
}
