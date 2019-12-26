//
//  StatisticsVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 27/11/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit
import CoreData

class StatsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!

    var gamesData : [Game] = [Game]()
    
    var stats : [StatDimension : [StatMeasure : Any]] = [:]
    
    let sortedMeasures : [StatMeasure] = [.gamesPlayed, .gamesWon, .gamesWithoutHints, .averageGameLength, .fastestWin, .totalGamesLength]
    
    
    var cellsData : [Stat] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        loadStats()

        setup()
    }
    
    // MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedMeasures.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
//        let stat = cellsData[indexPath.section]
        
        let measure = sortedMeasures[indexPath.section]
        let value = stats[.all]![measure]!
        
        let titleLabel = UILabel()
//        titleLabel.text = stat.title
        let titleText = formatStatLabel(measure: measure)
        titleLabel.text = titleText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(titleLabel)
        
        let valueLabel = UILabel()
//        valueLabel.text = stat.dataString
        let valueText = formatValueLabel(measure: measure, value: value)
        valueLabel.text = valueText
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -20),
            valueLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: valueLabel.leadingAnchor, constant: 20)
        ])
        
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        cell.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        
        let cellColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5)
        
        cell.backgroundColor = cellColor
        
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func formatStatLabel(measure: StatMeasure) -> String {
        switch measure {
        case .gamesPlayed:
            return "Games played"
        case .gamesWon:
            return "Games won"
        case .averageGameLength:
            return "Average game length"
        case .fastestWin:
            return "Fastest win"
        case .totalGamesLength:
            return "Total time played"
        default:
            return measure.getRawValue()
        }
    }
    
    func formatValueLabel(measure: StatMeasure, value: Any) -> String {
        
        switch measure {
        case .gamesPlayed, .gamesWon, .gamesWithoutHints:
            if let valueAsInt = value as? Int {
                return "\(valueAsInt)"
            }
        case .averageGameLength, .totalGamesLength:
            if let valueAsDouble = value as? Double {
                let valueAsInt = Int(valueAsDouble)
                return valueAsInt == 0 ? "No games played" : Utilities.formatSeconds(seconds: valueAsInt)
            }
        case .fastestWin:
            if let valueAsInt = value as? Int {
                return valueAsInt == 0 ? "No games won" : Utilities.formatSeconds(seconds: valueAsInt)
            }
        default:
            return "\(value)"
        }
        
        return "\(value)"
    }
    
    // TODO: Delete
    func getAverageGameLength() -> Int {
        var totalSeconds : Double = 0
        var nofGames : Double = 0
        for game in gamesData {
            nofGames += 1
            totalSeconds += Double(game.duration)
        }
        if nofGames == 0 {
            return 0
        }
        
        let average = totalSeconds/nofGames
        return Int(average.rounded())
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
        
        createMeasures()
        cellsData = []

        if gamesData.count == 0 {
            cellsData.append(Stat(title: "Play a game to see statistics!", dataString: ""))
            tableView.reloadData()
            return
        }
        
        let averageGameLength = getAverageGameLength()
        let averageGameLengthText = averageGameLength == 0 ? "No games played" : Utilities.formatSeconds(seconds: averageGameLength)

        
        let fastestWinText = getFastestWin() == 0 ? "No games won" : Utilities.formatSeconds(seconds: getFastestWin())

        cellsData.append(Stat(title: "Games played", dataString: "\(getNumberOfGames())"))
        cellsData.append(Stat(title: "Games won", dataString: "\(getNumberOfWins())"))
        cellsData.append(Stat(title: "Average game length", dataString: averageGameLengthText))
        cellsData.append(Stat(title: "Fastest win", dataString: fastestWinText))

        tableView.reloadData()
        
//        print(stats)
    }
    



    // MARK: - Statistics Functions
    func loadStats() {
        let request : NSFetchRequest<Game> = Game.fetchRequest()
        do {
            gamesData = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
    
    
    func createMeasures() {
        let dimensionsAvailable : [StatDimension] = [.all, .tenSumMode, .elevenSumMode]

        var numberOfGames : [StatDimension : Int] = [.all : 0, .tenSumMode : 0, .elevenSumMode : 0]
        var numberOfGamesWithoutHints : [StatDimension : Int] = [.all : 0, .tenSumMode : 0, .elevenSumMode : 0]
        var numberOfWins : [StatDimension : Int] = [.all : 0, .tenSumMode : 0, .elevenSumMode : 0]
        var totalSeconds : [StatDimension : Int] = [.all : 0, .tenSumMode : 0, .elevenSumMode : 0]
        var fastestWin : [StatDimension : Int] = [.all : 0, .tenSumMode : 0, .elevenSumMode : 0]

        var dimensionToAdd : [StatDimension] = [.all]
        
        for game in gamesData {
            
            let gameDuration = Int(game.duration)
            
            if Int(game.sumMode) == 10 {
                dimensionToAdd.append(.tenSumMode)
            } else if Int(game.sumMode) == 11 {
                dimensionToAdd.append(.elevenSumMode)
            }
            for dimension in dimensionToAdd {
                numberOfGames[dimension]! += 1
                if game.didWin {
                    if fastestWin[dimension]! == 0 {
                        fastestWin[dimension] = gameDuration
                    } else if gameDuration < fastestWin[dimension]! {
                        fastestWin[dimension] = gameDuration
                    }
                    numberOfWins[dimension]! += 1
                }
                
                if game.nofHintsUsed == 0 {
                    numberOfGamesWithoutHints[dimension]! += 1
                }
                
                totalSeconds[dimension]! += gameDuration

            }
        }
        
        for dimension in dimensionsAvailable {
            stats[dimension] = [:]
            
            stats[dimension]![.gamesPlayed] = numberOfGames[dimension]
            stats[dimension]![.gamesWon] = numberOfWins[dimension]
            stats[dimension]![.averageGameLength] = Double(totalSeconds[dimension]!) / Double(numberOfGames[dimension]!)
            stats[dimension]![.totalGamesLength] = totalSeconds[dimension]
            stats[dimension]![.fastestWin] = fastestWin[dimension]
            stats[dimension]![.gamesWithoutHints] = numberOfGamesWithoutHints[dimension]
        }
    }
    
    func createStats(with dimension: StatDimension, and measures: [StatMeasure]) {
        stats[dimension] = [:]

        for measure in measures {
            stats[dimension]?[measure] = ""
        }
    }
    
    
    
    func getNumberOfWins() -> Int {
        var nofWins = 0
        for game in gamesData {
            if game.didWin {
                nofWins += 1
            }
        }
        return nofWins
    }
    
    func getNumberOfGames() -> Int {
        return gamesData.count
    }
    
    func getFastestWin() -> Int {
        var minLength = 0
        for game in gamesData {
            if game.didWin {
                if minLength == 0 {
                    minLength = Int(game.duration)
                }
                if game.duration < minLength {
                    minLength = Int(game.duration)
                }
            }
        }
        
        return minLength
    }
    
    func deleteAllData() {
        
        for game in gamesData {
            context.delete(game)
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

struct Stat {
    let title: String
    let dataString: String
}

struct StatTwo {
    let type: StatMeasure?
    let title: String?
    let data: Any?
    let dataString: String?
}


enum StatDimension {
    case all, tenSumMode, elevenSumMode, withHints, withoutHints
}

enum StatMeasure: String {
    case gamesPlayed = "Games played"
        , gamesWon = "Games won"
        , averageGameLength = "Average game length"
        , totalGamesLength = "Total time played"
        , fastestWin = "Fastest win"
        , commonLosingReason = "Mainly lose because of"
        , gamesWithoutHints = "Games without hints"
    
    func getRawValue() -> String {
        return self.rawValue
    }
}
