//
//  StatisticsVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 02/11/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit
import CoreData

class StatisticsVC: UITableViewController {

    var stats : [Game] = [Game]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var averageGameLengthLabel: UILabel!
    @IBOutlet weak var nofGamesLabel: UILabel!
    @IBOutlet weak var nofWinsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadStats()
        
        updateLabels()
    }

    @IBAction func resetBtnPressed(_ sender: Any) {
        deleteAllData()
    }
    
    func updateLabels() {
        let averageGameLength = getAverageGameLength()
        let nofGames = getNumberOfGames()
        let nofWins = getNumberOfWins()
        
        averageGameLengthLabel.text = String(averageGameLength)
        nofGamesLabel.text = String(nofGames)
        nofWinsLabel.text = String(nofWins)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
    

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
        return average
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
        
        tableView.reloadData()
    }
}
