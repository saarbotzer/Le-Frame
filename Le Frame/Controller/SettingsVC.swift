//
//  NewSettingsVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 25/11/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit
import StoreKit

class SettingsVC: UIViewController {

    @IBOutlet weak var sumModeSwitch: UISegmentedControl!
    @IBOutlet weak var soundsSwitch: UISegmentedControl!
    @IBOutlet weak var hintsSwitch: UISegmentedControl!
    
    @IBOutlet weak var switchesStackView: UIStackView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    @IBOutlet weak var statisticsBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var rateBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        updateDefaultValues()
    }
    
    func updateUI() {
        navigationController?.navigationBar.tintColor = UIColor.white
        let barAppearance = UINavigationBar.appearance()
        barAppearance.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        barAppearance.shadowImage = UIImage()
        barAppearance.isTranslucent = true

        roundButtonUI(button: statisticsBtn, text: "Statistics")
        roundButtonUI(button: infoBtn, text: "Info")
        roundButtonUI(button: shareBtn, text: "Share")
        roundButtonUI(button: rateBtn, text: "Rate us!")
        
        setTextColor(for: soundsSwitch, color: UIColor.white)
        setTextColor(for: hintsSwitch, color: UIColor.white)
        setTextColor(for: sumModeSwitch, color: UIColor.white)
    }
    
    func setTextColor(for segmentedControl: UISegmentedControl, color: UIColor) {
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: color], for: .normal)
    }
    
    func roundButtonUI(button: UIButton, text: String) {
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        
        let label = UILabel(frame: CGRect(x: 0, y: statisticsBtn.frame.height, width: statisticsBtn.frame.width, height: 20))
        label.textAlignment = .center
        label.text = text
        label.textColor = UIColor.white
        button.addSubview(label)
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
    
    @IBAction func statsBtnTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToStatistics", sender: nil)
    }
    
    @IBAction func infoBtnTapped(_ sender: UIButton) {
//        performSegue(withIdentifier: "goToInfo", sender: nil)
        performSegue(withIdentifier: "goToHowTo", sender: nil)
    }
    
    @IBAction func rateBtnTapped(_ sender: UIButton) {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        }
        //TODO: Do something if iOS < 10.3?
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        // TODO: Add actual link
        
        let url = URL(string: "https://itunes.apple.com/us/app/myapp/idxxxxxxxx?ls=1&mt=8")
        let activityViewController = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
