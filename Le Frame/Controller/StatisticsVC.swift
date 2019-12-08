//
//  NewStatisticsVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 27/11/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit
import CoreData

class StatisticsVC: UIViewController {

    @IBOutlet weak var cell1: UIView! // Games played
    @IBOutlet weak var cell2: UIView! // Games won
    @IBOutlet weak var cell3: UIView! // Average game length
    
    var cells = [UIView]()

    var stats : [Game] = [Game]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadStats()
        
        cells = [cell1, cell2, cell3]
        setup()
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        //TODO: Implement reset function with alert
        let title = "Reset Data?"
        let message = "Are you sure you want to reset all data? This cannot be undone"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Reset", style: .destructive) { (action) in
            self.deleteAllData()
            self.loadStats()
            self.setup()
        }
        let nevermindAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(nevermindAction)
        alert.addAction(deleteAction)

        present(alert, animated: true, completion: nil)
    }
    
    func setup() {
        setupUI()
        setupValue(for: cell1, with: getNumberOfGames())
        setupValue(for: cell2, with: getNumberOfWins())
        
        let averageGameLength = getAverageGameLength()
        let averageGameLengthText = Utilities.formatSeconds(seconds: averageGameLength)
        setupValue(for: cell3, with: averageGameLengthText)
    }
    
    func setupUI() {
        for cell in cells {
            cell.backgroundColor = #colorLiteral(red: 0, green: 0.8419571519, blue: 0, alpha: 0.3414490582)
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 2
        }
        
    }
    
    func setupValue(for cell: UIView, with value: Any) {
        for subview in cell.subviews {
            if subview.tag == 1 {
                if let valueLabel = subview as? UILabel {
                    valueLabel.text = "\(value)"
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


    // MARK: - Statistics Functions
    func loadStats() {
        let request : NSFetchRequest<Game> = Game.fetchRequest()
        do {
            stats = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
    func getAverageGameLength() -> Int {
        var totalSeconds : Double = 0
        var nofGames : Double = 0
        for game in stats {
            nofGames += 1
            totalSeconds += Double(game.duration)
        }
        if nofGames == 0 {
            return 0
        }
        
        let average = totalSeconds/nofGames
        return Int(average.rounded())
    }
    
    func getNumberOfWins() -> Int {
        var nofWins = 0
        for game in stats {
            if game.didWin {
                nofWins += 1
            }
        }
        return nofWins
    }
    
    func getNumberOfGames() -> Int {
        return stats.count
    }
    
    func deleteAllData() {
        
        for game in stats {
            context.delete(game)
        }
        
    }
}
