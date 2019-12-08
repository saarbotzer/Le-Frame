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
        print("reset")
        deleteAllData()
    }
    
    func setup() {
        setupUI()
        setupValue(for: cell1, with: getNumberOfGames())
        setupValue(for: cell2, with: getNumberOfWins())
        setupValue(for: cell3, with: getAverageGameLength())
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
    
    func getAverageGameLength() -> Double {
        var totalSeconds : Double = 0
        var nofGames : Double = 0
        for game in stats {
            nofGames += 1
            totalSeconds += Double(game.duration)
        }
        
        let average = totalSeconds/nofGames
        return average.rounded()
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
