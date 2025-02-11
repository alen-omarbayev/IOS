import UIKit
import AVFoundation

class ViewController: UIViewController {

    var audioPlayer: AVAudioPlayer?
    
    let soundFiles = ["A", "B", "C", "D", "E", "F", "G"]
    
    var isRecording = false
    var recordedSequence: [Int] = []
    var recordings: [String: [Int]] = [:]

    var timer: Timer?
    var secondsElapsed = 0
    
    @IBOutlet weak var RecButton: UIButton!
    
    @IBOutlet weak var timerLable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func recButtonPressed(_ sender: UIButton) {
        isRecording.toggle()
        
        if isRecording {
            secondsElapsed = 0 // Сбрасываем таймер
                updateTimerLabel() // Обновляем метку в начале
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            recordedSequence.removeAll()
            print("Запись начата")
            let attributedTitle = NSAttributedString(string: "STOP", attributes: [
                    .font: UIFont.systemFont(ofSize: 23, weight: .bold),
                    .foregroundColor: UIColor.red
                ])
                RecButton.setAttributedTitle(attributedTitle, for: .normal)
        } else {
            timer?.invalidate() // Останавливаем таймер
            timer = nil
            timerLable.text = "00:00"
            // Спрашиваем пользователя о названии записи
            let attributedTitle = NSAttributedString(string: "REC", attributes: [
                    .font: UIFont.systemFont(ofSize: 23, weight: .bold),
                    .foregroundColor: UIColor.black
                ])
                RecButton.setAttributedTitle(attributedTitle, for: .normal)
            let alert = UIAlertController(title: "Сохранение записи", message: "Введите название записи", preferredStyle: .alert)
            alert.addTextField()
            
            let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
                guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
                self?.recordings[name] = self?.recordedSequence
                print("Запись завершена и сохранена под названием '\(name)': \(self?.recordedSequence ?? [])")
            }
            
            alert.addAction(saveAction)
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            // Показать диалоговое окно для ввода названия
            if let viewController = sender.window?.rootViewController {
                viewController.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        // Спрашиваем пользователя, какую запись воспроизвести
        let alert = UIAlertController(title: "Воспроизведение записи", message: "Выберите запись для воспроизведения", preferredStyle: .actionSheet)
        
        for (name, sequence) in recordings {
            alert.addAction(UIAlertAction(title: name, style: .default) { [weak self] _ in
                print("Воспроизведение записи '\(name)'")
                self?.playSequence(sequence)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        // Показать диалоговое окно с выбором записи
        if let viewController = sender.window?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func updateTimer() {
        secondsElapsed += 1
        updateTimerLabel()
    }
    func updateTimerLabel() {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        timerLable.text = String(format: "%02d:%02d", minutes, seconds)
    }

    func playSequence(_ sequence: [Int]) {
        for (index, tag) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.0) {
                self.playButtonWithTag(tag)
            }
        }
    }

    func playButtonWithTag(_ tag: Int) {
        print("Воспроизводится кнопка с тегом: \(tag)")
        if let button = self.view.viewWithTag(tag) as? UIButton {
            self.view.layer.removeAllAnimations() // Останавливаем текущие анимации
            self.view.backgroundColor = button.backgroundColor
            
            UIView.animate(withDuration: 1.0, delay: 1.0, options: []) {
                self.view.backgroundColor = .white
            }
        }
        if tag >= 0 && tag < soundFiles.count {
            let soundFileName = soundFiles[tag]
            print("Загружается звук: \(soundFileName)")
            playSound(soundFileName: soundFileName)
        } else {
            print("Неверный тег кнопки или звука не существует")
        }
    }
    
    @IBAction func ButtonApressed(_ sender: UIButton) {
        let tag = sender.tag
                
        print("Нажата кнопка с тегом: \(tag)")
        if isRecording {
            recordedSequence.append(tag)
        }
        self.view.layer.removeAllAnimations()
        self.view.backgroundColor = sender.backgroundColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = .white
            }
        }
        if tag >= 0 && tag < soundFiles.count {
            let soundFileName = soundFiles[tag]
            print("Загружается звук: \(soundFileName)")
            playSound(soundFileName: soundFileName)
        } else {
            print("Неверный тег кнопки или звука не существует")
        }
        
        UIView.animate(withDuration: 0.3, // Длительность анимации в секундах
                       animations: {
                           sender.alpha = 0.5
                       }, completion: { _ in
                           UIView.animate(withDuration: 0.3) {
                               sender.alpha = 1.0 // Вернуть полную непрозрачность
                           }
                       })
    }

    func playSound(soundFileName: String) {
        guard let path = Bundle.main.path(forResource: soundFileName, ofType:"wav") else {
            print("Файл звука не найден")
            return
        }
        let url = URL(fileURLWithPath: path)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Ошибка загрузки файла звука")
        }
    }
}

