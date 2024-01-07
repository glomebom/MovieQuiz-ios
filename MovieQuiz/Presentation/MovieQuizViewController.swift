import UIKit

final class MovieQuizViewController: UIViewController {
    
    // Связь элементов на экране и кода
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    // Структура для отображения результатов в алерте
    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
        init(title: String, text: String, buttonText: String) {
            self.title = title
            self.text = text
            self.buttonText = buttonText
        }
    }
    
    // Структура для вопроса
    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
        init(image: String, text: String, correctAnswer: Bool) {
            self.image = image
            self.text = text
            self.correctAnswer = correctAnswer
        }
    }
    
    // Структура для отображения вопроса на экране
    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
        init(image: UIImage, question: String, questionNumber: String) {
            self.image = image
            self.question = question
            self.questionNumber = questionNumber
        }
    }
    
    // Массив mok`ов
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    // Переменная-счетчик текущего вопроса
    private var currentQuestionIndex: Int = 0
    // Переменная-счетчик количества правильных ответов
    private var correctAnswers: Int = 0
    
    // Приватный метод конвертации mok`а в view-модель
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    // Приватный метод показа mok`а на экране
    private func show(quiz step: QuizStepViewModel) {
        
        // Задание значений элементам экран из view-модели mok`а
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
        imageView.layer.cornerRadius = 6
        
        // Окраски рамки изображения в зависимости от ответа
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // Увеличение счетчика правильных ответов
        if isCorrect {
            correctAnswers += 1
        }
        
        // Запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Показываем следующий mok или результаты через 1 секунду
            self.showNextQuestionOrResults()
        }
        
    }
    
    // Приватный метод показ следующего mock`а или результатов
    private func showNextQuestionOrResults() {
        
        // Если текущий mok был последним
        if currentQuestionIndex == questions.count - 1 {
            
            // Текст в переменную для удобства редактирования
            let text = "Ваш результат: \(String(correctAnswers))" + "/10"/* + "\n" + "Количество сыгранных квизов: 1" + "\n" + "Рекорд 0/0 (дата время)" + "\n" + "Средняя точность: 00.00%"*/
            
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
            
            // Константа для данных следующего mok`а
            let nextQuestion = questions[currentQuestionIndex]
            // Константа для модели mok`а
            let viewModel = convert(model: nextQuestion)
            
            // Вызов метода для показа следующего mok`а на экране
            show(quiz: viewModel)
            
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
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            
            // Задаем исходные значения для начала нового раунда
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            // Константа для выбора 0-го элемента из массива mok`ов
            let firstQuestion = self.questions[self.currentQuestionIndex]
            // Константа для модели mok`а первого вопроса
            let viewModel = self.convert(model: firstQuestion)
            
            // Вызов метода показа первого mok`а
            self.show(quiz: viewModel)
        }
        
        // Добавление действия к алерту
        alert.addAction(action)
        
        // Показ алерта
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Показ первого вопроса
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    
    // Приватный метод выполняемый при нажатии кнопки ДА
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        // Константа для хранения данных из текущего mok`а
        let currentQuestion = questions[currentQuestionIndex]
        // Константа для записи значения ответа пользователя на вопрос
        let givenAnswer = true
        
        // Вызов метода проверки правильности ответа на вопрос
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
    
    // Приватный метод выполняемый при нажатии кнопки НЕТ
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        // Константа для хранения данных из текущего mok`а
        let currentQuestion = questions[currentQuestionIndex]
        // Константа для записи значения ответа пользователя на вопрос
        let givenAnswer = false
        
        // Вызов метода проверки правильности ответа на вопрос
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
