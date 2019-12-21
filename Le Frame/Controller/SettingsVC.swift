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

    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var sumModeSwitch: UISegmentedControl!
    @IBOutlet weak var soundsSwitch: UISegmentedControl!
    @IBOutlet weak var hintsSwitch: UISegmentedControl!
    
    @IBOutlet weak var switchesStackView: UIStackView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    @IBOutlet weak var statisticsBtn: UIButton!
    @IBOutlet weak var howToBtn: UIButton!
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
        
        if #available(iOS 13.0, *) {
            closeBtn.isHidden = true
        }

        setupRoundButton(button: statisticsBtn)
        setupRoundButton(button: howToBtn)
        setupRoundButton(button: shareBtn)
        setupRoundButton(button: rateBtn)
        
        setupSegmentedControl(segmentedControl: soundsSwitch)
        setupSegmentedControl(segmentedControl: hintsSwitch)
        setupSegmentedControl(segmentedControl: sumModeSwitch)
    }
    
    
    func setupSegmentedControl(segmentedControl: UISegmentedControl) {
        let color = UIColor.white
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: color], for: .normal)
    }
    
    func setupRoundButton(button: UIButton) {
        
        let buttonWidth = button.frame.width
        
        button.layer.cornerRadius = buttonWidth / 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.clipsToBounds = true
        
        let whiteImage = button.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        button.setImage(whiteImage, for: .normal)
        button.tintColor = .white

        button.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
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
        
        var chosenSumMode = 10
        
        switch chosenSegmentIndex {
        case 0:
            chosenSumMode = 10
        case 1:
            chosenSumMode = 11
        default:
            return
        }
        
        if gameSumMode.getRawValue() == chosenSumMode {
            return
        }
        
        defaults.set(chosenSumMode, forKey: "SumMode")
        
        let alertTitle = "Removal sum"
        let alertMessage = "Removal sum for the current game has already been set on \(gameSumMode.getRawValue()). This change will be active in the next game"
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Got it", style: .default, handler: nil)

        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
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
    
    @IBAction func howToBtnTapped(_ sender: UIButton) {
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
    
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
