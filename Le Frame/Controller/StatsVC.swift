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

    var stats : [Game] = [Game]()
    
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
        return cellsData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let stat = cellsData[indexPath.section]
        
        let titleLabel = UILabel()
        titleLabel.text = stat.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.text = stat.dataString
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
        cellsData = []

        if stats.count == 0 {
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
    
    func getFastestWin() -> Int {
        var minLength = 0
        for game in stats {
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
        
        for game in stats {
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
