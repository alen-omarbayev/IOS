//
//  ViewController.swift
//  MathBusters
//
//  Created by Ален Омарбаев on 24.10.2024.
//

import UIKit
import AVFoundation

struct PlayerScore: Codable {
    let nickname: String
    var highScore: Int
}

class ViewController: UIViewController {
    
    @IBOutlet weak var easeQuestionButton: UIButton!
    @IBOutlet weak var gradeCoinsLabel: UILabel!
    @IBOutlet weak var levelControl: UISegmentedControl!
    
    var previousProgressTintColor: UIColor?
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var problemLabel: UILabel!
    
    @IBOutlet weak var timerContainerView: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var answerField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var restartButton: UIButton!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    
    var timer: Timer?
    var countDown: Int = 30
    var answer: Double?
    var score: Int = 0
    var levelscore: Int = 0
    var audioPlayer: AVAudioPlayer?
    var highScore: Int = 0
    var gradeCoins: Int = 0
    var scoreCount: Int = 10
    var username: String = ""
    
    var navigationBarPreviousTintColor: UIColor?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        loadHighScore()
        showUsernameInputAlert()
        loadGradeCoins()
        updateHighScoreLabel()
        generateProblem(forLevel: levelControl.selectedSegmentIndex)
        previousProgressTintColor = progressView.progressTintColor
        levelControl.addTarget(self, action: #selector(levelChanged), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarPreviousTintColor = navigationController?.navigationBar.tintColor
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scheduleTimer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = navigationBarPreviousTintColor
    }
    

    func setupUI(){
        timerContainerView.layer.cornerRadius = 5
        answerField.keyboardType = .decimalPad
        highScoreLabel.text = "High Score: \(highScore)"
    }
    func showUsernameInputAlert() {
        let alert = UIAlertController(title: "Введите ваше имя", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Имя"
        }
        let startAction = UIAlertAction(title: "Начать", style: .default) { _ in
            guard let enteredName = alert.textFields?.first?.text, !enteredName.isEmpty else {
                self.showUsernameInputAlert() // Повторный ввод, если имя пустое
                return
            }
            self.username = enteredName
            self.savePlayerScore(nickname: self.username, score: self.highScore)
            self.loadUserData()
            self.generateProblem(forLevel: self.levelControl.selectedSegmentIndex)
            self.scheduleTimer()
        }
        alert.addAction(startAction)
        present(alert, animated: true)
    }
    func loadUserData() {
        highScore = UserDefaults.standard.integer(forKey: "\(username)_highScore")
        gradeCoins = UserDefaults.standard.integer(forKey: "\(username)_gradeCoins")
        updateHighScoreLabel()
        gradeCoinsLabel.text = "A+: \(gradeCoins)"
    }
    func saveUserData() {
        UserDefaults.standard.set(highScore, forKey: "\(username)_highScore")
        UserDefaults.standard.set(gradeCoins, forKey: "\(username)_gradeCoins")
    }
    func generateProblem(forLevel level: Int, useCurrentLevelScore: Bool = false) {
        var firstDigit: Int
        var startingInteger: Int
        var endingInteger: Int
        let arithmeticOperator: String = ["+", "-", "x", "/"].randomElement()!
        
        
        switch level{
        case 0:
            levelscore = 1
            firstDigit = Int.random(in: 0...9)
            startingInteger = 0
            endingInteger = 9
            if arithmeticOperator == "/" {
                startingInteger = 1
            }
        case 1:
            levelscore = 2
            firstDigit = Int.random(in: 10...99)
            startingInteger = 10
            endingInteger = 99
        case 2:
            levelscore = 3
            firstDigit = Int.random(in: 100...999)
            startingInteger = 100
            endingInteger = 999
        default:
            return
        }
        
        levelscore = useCurrentLevelScore ? levelscore : level + 1
        
        
        if arithmeticOperator == "-" {
            endingInteger = firstDigit // ограничиваем, чтобы secondDigit не превышал firstDigit
        }
        
        let secondDigit = Int.random(in: startingInteger...endingInteger)
        
        problemLabel.text = "\(firstDigit) \(arithmeticOperator) \(secondDigit) = "
        
        switch arithmeticOperator {
        case "+":
            answer = Double(firstDigit + secondDigit)
        case "-":
            answer = Double(firstDigit - secondDigit)
        case "x":
            answer = Double(firstDigit * secondDigit)
        case "/":
            answer = Double(firstDigit) / Double(secondDigit)
        default:
            answer = nil
        }
    }

    func scheduleTimer(){
        countDown = 30
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerUI), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateTimerUI(){
        countDown -= 1
        timerLabel.text = "00:\(countDown)"
        if countDown < 10{
            timerLabel.text = "00:0\(countDown)"
        }
        progressView.progress = Float(30 - countDown) / 30
        if countDown <= 10{
            progressView.progressTintColor = .red
        }else {
            progressView.progressTintColor = previousProgressTintColor
        }
        
        if countDown <= 0{
            timer?.invalidate()
            answerField.isEnabled = false
            submitButton.isEnabled = false
            progressView.progressTintColor = previousProgressTintColor
        }
        
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        guard let text = answerField.text else{
            print("text is nil")
            return
        }
        guard !text.isEmpty else{
            print("text is empty")
            return
        }
        guard let answer = Double(text) else{
            print("couldnt convert text \(text) to double")
            return
        }
        print("answer: \(answer)")
        if answer == self.answer{
            playSound(named: "right_answer")
            updateHighScore()
            saveUserData()
            score += levelscore
            scoreLabel.text = "Score: \(score)"
            generateProblem(forLevel: levelControl.selectedSegmentIndex)
            scheduleTimer()
            updateGradeCoins()
            timerLabel.text = "00:\(countDown)"
            answerField.text = ""
            if score >= 10 && levelControl.selectedSegmentIndex == 0{
                playSound(named: "new_level")
                levelControl.selectedSegmentIndex = 1
                levelChanged()
            }
            if score < 0 && levelControl.selectedSegmentIndex == 1 {
                levelControl.selectedSegmentIndex = 0
                levelChanged()
                levelControl.setNeedsLayout()
                print("Level Easy")
            }
            else if score >= 20 && levelControl.selectedSegmentIndex == 1{
                playSound(named: "new_level")
                levelControl.selectedSegmentIndex = 2
                levelChanged()
            }
            else if score < 0 && levelControl.selectedSegmentIndex == 2{
                levelControl.selectedSegmentIndex = 1
                levelChanged()
                levelControl.setNeedsLayout()
                print("Level Medium")
            }
        }
        else{
            playSound(named: "wrong_answer")
            score -= levelscore
            scoreLabel.text = "Score: \(score)"
            generateProblem(forLevel: levelControl.selectedSegmentIndex)
            answerField.text = ""
        }
        
    }
    
    @IBAction func restartButtonTapped(_ sender: Any) {
        resetGame()
    }
    @objc func levelChanged(){
        resetGame()
        score = 0
        scoreLabel.text = "Score: \(score)"
        generateProblem(forLevel: levelControl.selectedSegmentIndex)
        scheduleTimer()
    }
    func resetGame(){
        updateHighScore()
        score = 0
        scoreLabel.text = "Score: \(score)"
        generateProblem(forLevel: levelControl.selectedSegmentIndex)
        answerField.isEnabled = true
        submitButton.isEnabled = true
        scheduleTimer()
        answerField.text = ""
        progressView.progressTintColor = previousProgressTintColor
    }
    func updateHighScore() {
        if score > highScore {
            highScore = score
            saveUserData()
            saveHighScore()
            updateHighScoreLabel()
            
            savePlayerScore(nickname: "выбранныйНикнейм", score: highScore)

        }
    }
    func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "highScore")
    }
    func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "highScore")
    }
    func updateHighScoreLabel() {
            highScoreLabel.text = "High Score: \(highScore)"
        }
    func saveGradeCoins() {
        UserDefaults.standard.set(gradeCoins, forKey: "gradeCoins")
    }

    func loadGradeCoins() {
        gradeCoins = UserDefaults.standard.integer(forKey: "gradeCoins")
        gradeCoinsLabel.text = "A+: \(gradeCoins)"
    }

    func updateGradeCoins() {
        if score >= scoreCount && score <= scoreCount + 10 {
            gradeCoins += 1
            gradeCoinsLabel.text = "A+: \(gradeCoins)"
            scoreCount += 10
            saveGradeCoins() // Сохраняем обновленное количество A+
            saveUserData()
        }
    }
    
    @IBAction func easeQuestionButtonTapped(_ sender: Any) {
        guard gradeCoins > 0 else {
            print("Недостаточно A+ для облегчения вопроса")
            return
        }
            
            // Понижаем уровень сложности вопроса, если игрок не на минимальном уровне
        let currentLevel = levelControl.selectedSegmentIndex
        if currentLevel > 0 {
            gradeCoins -= 1
            gradeCoinsLabel.text = "A+: \(gradeCoins)"
            saveGradeCoins()
                
                // Генерация вопроса на один уровень ниже
            generateProblem(forLevel: currentLevel - 1, useCurrentLevelScore: true)
        }else {
            print("Вопрос уже на минимальном уровне сложности")
        }
    }
    func simplifyQuestion() {
        if gradeCoins > 0 {
            // Определяем уровень ниже текущего
            let lowerLevel = max(levelControl.selectedSegmentIndex - 1, 0)
            
            // Уменьшаем валюту
            gradeCoins -= 1
            gradeCoinsLabel.text = "A+: \(gradeCoins)"
            saveGradeCoins()
            
            // Генерируем новый вопрос для уровня ниже
            generateProblem(forLevel: lowerLevel, useCurrentLevelScore: true)
        }
    }
    func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Не удалось найти аудиофайл \(soundName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Ошибка воспроизведения звука: \(error.localizedDescription)")
        }
    }
    
    func savePlayerScore(nickname: String, score: Int) {
        var scores = loadAllPlayerScores()
        if let index = scores.firstIndex(where: { $0.nickname == nickname }) {
            // Обновляем, если игрок уже есть
            scores[index].highScore = max(scores[index].highScore, score)
        } else {
            // Добавляем нового игрока
            scores.append(PlayerScore(nickname: nickname, highScore: score))
        }
        if let encodedData = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encodedData, forKey: "playerScores")
        }
    }

    func loadAllPlayerScores() -> [PlayerScore] {
        guard let savedData = UserDefaults.standard.data(forKey: "playerScores"),
              let savedScores = try? JSONDecoder().decode([PlayerScore].self, from: savedData) else {
            return []
        }
        return savedScores
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scoresVC = segue.destination as? ScoresViewController {
            scoresVC.playerScores = loadAllPlayerScores()
        }
    }

}

