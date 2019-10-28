//
//  SettingsVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 26/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {

    @IBOutlet weak var soundsSwitch: UISegmentedControl!
    @IBOutlet weak var sumModeSwitch: UISegmentedControl!
    @IBOutlet weak var hintsSwitch: UISegmentedControl!
    
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateDefaultValues()
        
    }
    
    func updateDefaultValues() {
        
        let soundsOn = defaults.bool(forKey: "SoundsOn")
        let showHintsOn = defaults.bool(forKey: "ShowHintsOn")
        let sumMode = defaults.integer(forKey: "SumMode")
        
        if soundsOn {
            soundsSwitch.selectedSegmentIndex = 0
        } else {
            soundsSwitch.selectedSegmentIndex = 1
        }
        
        if showHintsOn {
            hintsSwitch.selectedSegmentIndex = 0
        } else {
            hintsSwitch.selectedSegmentIndex = 1
        }
        
        
        if sumMode == 10 {
            sumModeSwitch.selectedSegmentIndex = 0
        } else if sumMode == 11 {
            sumModeSwitch.selectedSegmentIndex = 1
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 4
        case 1:
            return 2
        case 2:
            return 3
        default:
            return 0
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Switches Functions
    
    @IBAction func soundsSwitched(_ sender: UISegmentedControl) {
        let chosenSegmentIndex = sender.selectedSegmentIndex

        switch chosenSegmentIndex {
        case 0:
            // TODO: Add sounds on function
            defaults.set(true, forKey: "SoundsOn")
        case 1:
            // TODO: Add sounds off function
            defaults.set(false, forKey: "SoundsOn")
        default:
            return
        }
    }
    
    @IBAction func sumSwitched(_ sender: UISegmentedControl) {
        let chosenSegmentIndex = sender.selectedSegmentIndex

        // TODO: Make sumMode change for the next game
        switch chosenSegmentIndex {
        case 0:
            defaults.set(10, forKey: "SumMode")
        case 1:
            defaults.set(11, forKey: "SumMode")
        default:
            return
        }
    }
    
    @IBAction func showHintsSwitched(_ sender: UISegmentedControl) {
        let chosenSegmentIndex = sender.selectedSegmentIndex

        switch chosenSegmentIndex {
        case 0:
            // TODO: Turn on hints
            defaults.set(true, forKey: "ShowHintsOn")
        case 1:
            // TODO: Turn off hints
            defaults.set(false, forKey: "ShowHintsOn")
        default:
            return
        }
    }
    
    
    // MARK: - Navigation Functions
    
    @IBAction func donePressed(_ sender: Any) {
//        dismiss(animated: self, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
}
