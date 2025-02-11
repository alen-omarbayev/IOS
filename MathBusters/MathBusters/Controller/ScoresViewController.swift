//
//  ScoresViewController.swift
//  MathBusters
//
//  Created by Ален Омарбаев on 12.11.2024.
//

import UIKit

class ScoresViewController: UIViewController {
    
    @IBOutlet weak var scoresLabel: UILabel!
    
    var playerScores: [PlayerScore] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlayerScores() // Загрузка сохраненных данных
        displayScores()
                
        loadPlayerScores()
        // Do any additional setup after loading the view.
    }
    func loadPlayerScores() {
        if let data = UserDefaults.standard.data(forKey: "playerScores") {
            do {
                let decoder = JSONDecoder()
                playerScores = try decoder.decode([PlayerScore].self, from: data)
            } catch {
                print("Ошибка при загрузке данных игроков: \(error)")
            }
        }
    }
    func displayScores() {
        var scoresText = "Лучшие результаты:\n\n"
            
        for playerScore in playerScores {
            scoresText += "\(playerScore.nickname): \(playerScore.highScore) очков\n"
        }
            
        scoresLabel.text = scoresText
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
