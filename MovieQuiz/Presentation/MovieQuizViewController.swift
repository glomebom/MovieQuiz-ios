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
    
    // Экземпляр класса статистики
    private var statisticService = StatisticServiceImplementation()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ЧАСТЬ ПРАКТИЧЕСКОГО ЗАДАНИЯ ПО СПРИНТУ 5 - не используется в итоговом задании
        // Чтение файла inception.json размещенного в директории проекта и вызов метода getMovie()
        //        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //        print(documentsURL)
        //        let fileName = "inception.json"
        //        //        let fileName = "top250MoviesIMDB.json"
        //        documentsURL.appendPathComponent(fileName)
        //        print(documentsURL)
        //        let jsonString = try? String(contentsOf: documentsURL)
        //        guard let movieBase = getMovie(from: jsonString!) else { return }
        //        print(movieBase)
        //        // Сериализация movieBase
        //        if let movieBaseEncode = try? JSONEncoder().encode(movieBase) {
        //            print(String(data: movieBaseEncode, encoding: .utf8)!)
        //        }
        
        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
        
        alertPresenter.delegate = self
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
    
    // ЧАСТЬ ПРАКТИЧЕСКОГО ЗАДАНИЯ ПО СПРИНТУ 5 - не используется в итоговом задании
    // Метод сериализации в модель Movie версия 1 с протоколом decode
    //    func getMovie(from jsonString: String) -> Movie? {
    //        // Форматирование данных
    //        guard let data = jsonString.data(using: .utf8) else { return nil}
    //        do {
    //            // используем метод `JSONSerialization.deocde(...`, который возвращает структуру данных
    //            let movie = try JSONDecoder().decode(Movie.self, from: data)
    //            return movie
    //        } catch {
    //            print("Failed to parse: \(error.localizedDescription)")
    //        }
    //        return nil
    //    }
    
    // Метод сериализации в модель Movie версия 2
    //    func getMovie(from jsonString: String) -> Movie? {
    //        var movie: Movie? = nil
    //
    //        do {
    //            // Форматирование данных
    //            guard let data = jsonString.data(using: .utf8) else { return nil}
    //
    //            // Сериализация данных
    //            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    //
    //            // Присвоение констант для модели Movie из прочитанного файла
    //            guard let json = json,
    //                  let id = json["id"] as? String,
    //                  let title = json["title"] as? String,
    //                  let jsonYear = json["year"] as? String,
    //                  let year = Int(jsonYear),
    //                  let image = json["image"] as? String,
    //                  let releaseDate = json["releaseDate"] as? String,
    //                  let jsonRuntimeMins = json["runtimeMins"] as? String,
    //                  let runtimeMins = Int(jsonRuntimeMins),
    //                  let directors = json["directors"] as? String,
    //                  let actorList = json["actorList"] as? [Any] else {
    //                return nil
    //            }
    //
    //            // Переменная для массива актеров
    //            var actors: [Actor] = []
    //
    //            // Цикл по массиву актеров с присвоением полей модели Actor
    //            for actor in actorList {
    //                guard let actor = actor as? [String: Any],
    //                      let id = actor["id"] as? String,
    //                      let image = actor["image"] as? String,
    //                      let name = actor["name"] as? String,
    //                      let asCharacter = actor["asCharacter"] as? String else {
    //                    return nil
    //                }
    //
    //                // Константа для записи прочитанных из массива значений модели Actor
    //                let mainActor = Actor(id: id,
    //                                      image: image,
    //                                      name: name,
    //                                      asCharacter: asCharacter)
    //
    //                // Добавление записанного элемента модели Actor к массиву актеров
    //                actors.append(mainActor)
    //            }
    //
    //            // Запись значений прочитанных из файла в модель Movie
    //            movie = Movie(id: id,
    //                          title: title,
    //                          year: year,
    //                          image: image,
    //                          releaseDate: releaseDate,
    //                          runtimeMins: runtimeMins,
    //                          directors: directors,
    //                          actorList: actors)
    //        } catch {
    //            print("Failed to parse: \(jsonString)")
    //        }
    //
    //        return movie
    //    }
    
    
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
            
            //Сохранение лучшего результата квиза и увеличение счетчиков статистики
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            // Текст алерта по результатам квиза
            let text =  "Ваш результат: \(String(correctAnswers))" + "/10" + "\n" + "Количество сыгранных квизов: \(statisticService.gamesCount)" + "\n" + "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))" + "\n" + "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            // Создание модели алерта
            alertModel = alertPresenter.createAlert(correct: correctAnswers, total: questionsAmount, message: text)
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
