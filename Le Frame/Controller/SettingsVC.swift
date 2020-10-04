//
//  NewSettingsVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 21/12/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

class SettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Properties
    /// A dict that contains all of the settings. The key is the section name.
    let settingsSections: [String : [Setting]] =
        [
            "GAME": [
//                Setting(label: "Removal sum", segmentedControlSegments: ["10", "11"], segmentedControlSettingKey: .sumMode, segmentedControlAlertText: "Yes"),
                Setting(label: "Difficulty", segmentedControlSegments: ["Very easy", "Easy", "Normal", "Hard"], segmentedControlSettingKey: .difficulty, segmentedControlAlertText: "Yes", infoText: "Very easy - 3 next cards\n Easy - 2 next cards\nNormal - 1 next card\nHard - 1 next card, remove cards that sum to 11"),
//                Setting(label: "Done removing anytime", segmentedControlSegments: ["ON", "OFF"], segmentedControlSettingKey: .doneRemovingAnytime, segmentedControlAlertText: "Yes", segueName: nil),
//                Setting(label: "Remove when full board", segmentedControlSegments: ["YES", "NO"], segmentedControlSettingKey: .removeWhenFull, segmentedControlAlertText: "Yes", segueName: nil),
                Setting(label: "Highlight available moves", segmentedControlSegments: ["ON", "OFF"], segmentedControlSettingKey: .highlightAvailableMoves, segmentedControlAlertText: nil, segueName: nil, infoText: "Available spots and matching cards will be highlighted"),
                Setting(label: "Automatic hints", segmentedControlSegments: ["ON", "OFF"], segmentedControlSettingKey: .showHints, segmentedControlAlertText: "No"),
                Setting(label: "Sounds", segmentedControlSegments: ["ON", "OFF"], segmentedControlSettingKey: .soundsOn, segmentedControlAlertText: "No"),
                Setting(label: "Vibrate", segmentedControlSegments: ["ON", "OFF"], segmentedControlSettingKey: .hapticOn, segmentedControlAlertText: "No"),
//                Setting(label: "Ads", segmentedControlSegments: ["ON", "OFF"], segmentedControlSettingKey: .adsOn, segmentedControlAlertText: "No", infoText: "For tests"),
                Setting(label: "Statistics", segueName: .goToStatistics)
            ],
            "HELP": [
                Setting(label: "Tutorial", segueName: .goToTutorial),
                Setting(label: "FAQ", segueName: .goToFaq)
            ],
            "ABOUT": [
                Setting(label: "Credits", segueName: .goToAboutUs),
                Setting(label: "Privacy Policy", segueName: .privacyPolicy),
                Setting(label: "Rate us!", segueName: .rateUs),
                Setting(label: "Contact us", segueName: .goToContactUs),
                Setting(label: "Share", segueName: .share)
            ]
    ]
    
    /// All of the section names in the wanted order.
    let sectionNames = ["GAME", "HELP", "ABOUT"]
    
    let sectionFontName = "Kefa"
    let settingFontName = "Kefa"
    let sectionFontSize: CGFloat = 30.0
    let settingFontSize: CGFloat = 14.0
    
    let gotoIcon = "settings-goto-icon.png"
    
    let defaults = UserDefaults.standard
    var gameDifficulty: Difficulty = .default

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 13.0, *) {
            closeButton.isHidden = true
        }

        updateUI()
    }
    
    /// Updates the VC's UI
    func updateUI() {
        navigationController?.navigationBar.tintColor = UIColor.white
        let barAppearance = UINavigationBar.appearance()
        barAppearance.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        barAppearance.shadowImage = UIImage()
        barAppearance.isTranslucent = true
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 70
    }
    
    /// Called when the close button has been tapped
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = sectionNames[section]
        return settingsSections[sectionName]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        
        let sectionName = sectionNames[indexPath.section]
        if let setting = settingsSections[sectionName]?[indexPath.row] {
            cell = createCell(for: setting)
        }

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsSections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let sectionLabel = createHeaderLabel(text: sectionNames[section])
        
        headerView.addSubview(sectionLabel)
        
        NSLayoutConstraint.activate([
            sectionLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            sectionLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        if #available(iOS 13.0, *) {
            
        } else {
            sectionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == settingsSections.count - 1 {
//            return 30
//        }
//        return 0
//    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == settingsSections.count - 1 {
            let versionLabel = UILabel()
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                versionLabel.text = "Royal Frame version \(appVersion)"
                versionLabel.font = UIFont(name: versionLabel.font.familyName, size: 10)
                versionLabel.textColor = .white
                versionLabel.translatesAutoresizingMaskIntoConstraints = false
                
                let footerView = UIView()
                footerView.backgroundColor = .clear
                footerView.addSubview(versionLabel)
                
                versionLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
                versionLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 15).isActive = true
                
                return footerView
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionName = sectionNames[indexPath.section]
        
        if let segueName = settingsSections[sectionName]?[indexPath.row].segueName {
            if segueName == .rateUs {
                if #available(iOS 10.3,*){
                    SKStoreReviewController.requestReview()
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            } else if segueName == .privacyPolicy {
                guard let url = URL(string: "http://www.freeprivacypolicy.com/privacy/view/2a29fd7a265d51d96bf75c8f422b751c") else { return }
                UIApplication.shared.open(url)
                tableView.deselectRow(at: indexPath, animated: true)
            } else if segueName == .share {
                let url = URL(string: "https://apps.apple.com/il/app/royal-frame/id1490916476")
                let activityViewController = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
                present(activityViewController, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            } else if segueName == .goToContactUs {
                sendEmail()
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                performSegue(withIdentifier: segueName.getRawValue(), sender: nil)
            }
        }
    }
    
    // MARK: - Create Views
    
    /// Creates a UISegmentedControl for a setting row
    /// - Parameter setting: The Setting objects which contains the data to created the segmented control
    /// - Returns: The segmented control with the properties defined in setting, nil if the row doesn't have a segmented control
    func createSegmentedControl(for setting: Setting) -> SettingSegmentedControl? {
        let goldColor = UIColor(red: 1, green: 215.0/255.0, blue: 0, alpha: 1)
        let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let selectedColor = goldColor
        let textColor = UIColor.white
        let selectedTextColor = UIColor.black
        let borderColor = UIColor.white
        let borderWidth: CGFloat = 0
        let font = UIFont(name: settingFontName, size: settingFontSize)
        
        if setting.segmentedControlSegments != nil {
            let segmentedControl = SettingSegmentedControl(setting: setting)
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: font!], for: .normal)
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedTextColor, NSAttributedString.Key.font: font!], for: .selected)

            if #available(iOS 13.0, *) {
                segmentedControl.layer.borderColor = borderColor.cgColor
                segmentedControl.layer.borderWidth = borderWidth
                segmentedControl.layer.backgroundColor = backgroundColor.cgColor
                segmentedControl.selectedSegmentTintColor = selectedColor
            } else {
                segmentedControl.tintColor = selectedColor
            }

            segmentedControl.selectedSegmentIndex = updateDefaultSettings(for: setting.segmentedControlSettingKey)
                        
            segmentedControl.addTarget(self, action: #selector(segmentControlValueChanged(sender:)), for: .valueChanged)
            
            return segmentedControl
        }
        return nil
    }
    

    /// Called when a segmented control value has been changed.
    /// - Parameter sender: The segmented control
    @objc
    func segmentControlValueChanged(sender: SettingSegmentedControl) {
        if let settingKey = sender.settingKey {
            let keyRawValue = settingKey.getRawValue()
            switch settingKey {
            case .difficulty:
                var newDifficulty = "unknown"
                switch sender.selectedSegmentIndex {
                case 0:
                    newDifficulty = "veryEasy"
                case 1:
                    newDifficulty = "easy"
                case 2:
                    newDifficulty = "normal"
                case 3:
                    newDifficulty = "hard"
                default:
                    newDifficulty = "unknown"
                }
                defaults.set(newDifficulty, forKey: keyRawValue)
                
                if gameDifficulty.name != newDifficulty {
                    alertChange(for: sender.name!, currentValue: gameDifficulty.name)
                }
                
            case .sumMode:
                let newSumMode = sender.selectedSegmentIndex == 0 ? 10 : 11
                defaults.set(newSumMode, forKey: keyRawValue)

                if gameDifficulty.sumMode.getRawValue() != newSumMode {
                    alertChange(for: sender.name!, currentValue: gameDifficulty.sumMode)
                }
            case .showHints, .soundsOn, .doneRemovingAnytime, .hapticOn, .adsOn, .highlightAvailableMoves:
                let newValue = sender.selectedSegmentIndex == 0
                defaults.set(newValue, forKey: keyRawValue)
            }
        }
    }
    
    
    /// Shows an alert when a setting has been changed.
    /// - Parameters:
    ///   - settingName: The changed setting name
    ///   - currentValue: The current setted value that is about to be changed.
    func alertChange(for settingName: String, currentValue: Any) {
        let title = settingName
        let message = "This setting for the current game has already been set on \(currentValue). This change will be active in the next game"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Got it", style: .default, handler: nil)
        let newGameAction = UIAlertAction(title: "Start a new game", style: .default) { (action) in
            
            if let presenter = self.presentingViewController as? GameVC {
                
                presenter.addStats(because: .newGameWithNewDifficulty)
                
                // Using a delay because of a next cards animation location bug
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                    presenter.startNewGame()
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        }

        alert.addAction(okAction)
        alert.addAction(newGameAction)

        present(alert, animated: true, completion: nil)

    }
    
    /// Updates the defaults settings and returns the selected index for the segmented control.
    /// - Parameter settingKey: The setting to update the defaults for
    /// - Returns: The selected index for the setting's segmented control
    func updateDefaultSettings(for settingKey: SettingKey?) -> Int {
        var selectedSegmentIndex = 0

        let currentlySavedKeys = defaults.dictionaryRepresentation().keys
        
        if let defaultsKey = settingKey {
            let keyRawValue = defaultsKey.getRawValue()
            let keyExists = currentlySavedKeys.contains(keyRawValue)
            switch defaultsKey {
            case .sumMode:
                if keyExists {
                    let sumMode = defaults.integer(forKey: keyRawValue)
                    selectedSegmentIndex = sumMode == 10 ? 0 : 1
                } else {
                    defaults.set(10, forKey: keyRawValue)
                    selectedSegmentIndex = 0
                }
            case .soundsOn, .hapticOn, .showHints, .highlightAvailableMoves, .adsOn:
                if keyExists {
                    let settingOn = defaults.bool(forKey: keyRawValue)
                    selectedSegmentIndex = settingOn ? 0 : 1
                } else {
                    defaults.set(true, forKey: keyRawValue)
                    selectedSegmentIndex = 0
                }
            case .doneRemovingAnytime:
                if keyExists {
                    let doneRemovingAnytime = defaults.bool(forKey: keyRawValue)
                    selectedSegmentIndex = doneRemovingAnytime ? 0 : 1
                } else {
                    defaults.set(false, forKey: keyRawValue)
                    selectedSegmentIndex = 1
                }
            case .difficulty:
                if keyExists {
                    let difficultyString = defaults.string(forKey: keyRawValue)!
                    switch difficultyString {
                    case "veryEasy":
                        selectedSegmentIndex = 0
                    case "easy":
                        selectedSegmentIndex = 1
                    case "normal":
                        selectedSegmentIndex = 2
                    case "hard":
                        selectedSegmentIndex = 3
                    default:
                        selectedSegmentIndex = 2
                    }
                } else {
                    defaults.set("normal", forKey: keyRawValue)
                    selectedSegmentIndex = 2
                }
            }
        }
        
        return selectedSegmentIndex
    }
    
    /// Creates a header for the section
    /// - Parameter text: The text of the label
    /// - Returns: A UILabel with the wanted properties
    func createHeaderLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: sectionFontName, size: sectionFontSize)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /// Create a UITableViewCell for a Setting row
    /// - Parameter setting: The Setting object which contains the data to created the row cell
    /// - Returns: The table view cell of the setting
    func createCell(for setting: Setting) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let cellColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5)
        let selectedCellColor = cellColor.withAlphaComponent(0.9)
        
        // Cell label
        let label = UILabel()
        label.text = setting.label
        label.font = UIFont(name: settingFontName, size: settingFontSize)
        label.sizeToFit()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(label)

        var labelYAnchor = label.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        
        /// Two floors cell
        var specialCell = false
        let labelHeight : CGFloat = 20
        let segmentedControlHeight : CGFloat = 25
        var segmentedControlWidth : CGFloat = 100
                
        var segments: [Any]?
        switch setting.segmentedControlSettingKey {
        case .difficulty:
            segments = Difficulty.activeOptions
        case .hapticOn, .soundsOn, .showHints, .doneRemovingAnytime, .highlightAvailableMoves, .adsOn:
            segments = ["ON", "OFF"]
        default:
            segments = nil
        }
        
        
        if let numberOfSegments = segments?.count {
            if numberOfSegments > 2 {
                labelYAnchor = label.topAnchor.constraint(equalTo: cell.topAnchor, constant: 20)
                
                cell.heightAnchor.constraint(equalToConstant: labelHeight + segmentedControlHeight + 30).isActive = true
                cell.contentView.heightAnchor.constraint(equalToConstant: labelHeight + segmentedControlHeight + 30).isActive = true
                specialCell = true
            }
        }
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: labelHeight),
            labelYAnchor,
        ])
        
        let selectedBackgroundView = UIView(frame: cell.frame)

        if let segmentedControl = createSegmentedControl(for: setting) {
            
//            cell.addSubview(segmentedControl)
            cell.contentView.addSubview(segmentedControl)
            
            var segmentedControlYAnchor = segmentedControl.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
            var segmentedControlXAnchor = segmentedControl.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10)

            if specialCell {
                segmentedControlYAnchor = segmentedControl.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10)
                segmentedControlXAnchor = segmentedControl.centerXAnchor.constraint(equalTo: cell.centerXAnchor)
                segmentedControlWidth = cell.frame.width - 20
            }
            
            NSLayoutConstraint.activate([
                segmentedControlXAnchor,
                segmentedControlYAnchor,
                segmentedControl.heightAnchor.constraint(equalToConstant: segmentedControlHeight),
                segmentedControl.widthAnchor.constraint(equalToConstant: segmentedControlWidth),
            ])
            
            selectedBackgroundView.backgroundColor = .clear
        } else {
            // If there is a segmented control, the cell can't be selected
            selectedBackgroundView.backgroundColor = selectedCellColor
        }
        
        if let infoText = setting.infoText {
            
            let imageName = "question-mark-circle.jpg"
            let infoIconImage = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate) ?? UIImage(named: imageName)
            
            let infoButton = InfoButton()
            infoButton.setImage(infoIconImage, for: .normal)
            infoButton.tintColor = .white
            infoButton.contentMode = .scaleAspectFit
            
            infoButton.infoText = infoText
            infoButton.settingKey = setting.segmentedControlSettingKey
            
            infoButton.translatesAutoresizingMaskIntoConstraints = false
            
            infoButton.imageView?.contentMode = .scaleAspectFit
            
            infoButton.addTarget(self, action: #selector(infoButtonPressed(sender:)), for: .touchUpInside)
            
//            cell.addSubview(infoButton)
            cell.contentView.addSubview(infoButton)
            NSLayoutConstraint.activate([
                infoButton.heightAnchor.constraint(equalToConstant: labelHeight - 5),
                infoButton.widthAnchor.constraint(equalToConstant: labelHeight - 5),
                infoButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 7),
                infoButton.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 0)
            ])
        }
                
        if let segue = setting.segueName {
            if segue.hasSegue() {
                let gotoImage = UIImage(named: gotoIcon)?.withRenderingMode(.alwaysTemplate) ?? UIImage(named: gotoIcon)
                let gotoImageView = UIImageView(image: gotoImage)
                gotoImageView.tintColor = .white

                gotoImageView.translatesAutoresizingMaskIntoConstraints = false

                cell.addSubview(gotoImageView)
                NSLayoutConstraint.activate([
                    gotoImageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                    gotoImageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                    gotoImageView.heightAnchor.constraint(equalToConstant: 15),
                    gotoImageView.widthAnchor.constraint(equalToConstant: 15),
                ])
            }
        }
        
        cell.selectedBackgroundView = selectedBackgroundView

        cell.backgroundColor = cellColor
                
        return cell
    }
    
    /// Called when a setting's info button is pressed.
    /// - Parameter sender: The info button that got pressed
    @objc func infoButtonPressed(sender: InfoButton) {
        var alertTitle = ""
        
        switch sender.settingKey {
        case .difficulty:
            alertTitle = "Difficulty Levels"
        case .highlightAvailableMoves:
            alertTitle = "Highlight Moves"
        default:
            alertTitle = "Help"
        }
        
        if let infoText = sender.infoText {
            
            let alert = UIAlertController(title: alertTitle, message: infoText, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alert.addAction(okAction)

            present(alert, animated: true, completion: nil)

        }
    }
    
    // MARK: - ViewController Functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // To deselect rows with segue
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}

class SettingSegmentedControl : UISegmentedControl {
    
    var name : String?
    var settingKey : SettingKey?
    var alertText : String?
    
    override init(items: [Any]?) {
        super.init(items: items)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(setting: Setting) {
        let items = setting.segmentedControlSegments
        super.init(items: items)
        self.settingKey = setting.segmentedControlSettingKey
        self.alertText = setting.segmentedControlAlertText
        self.name = setting.label
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


extension SettingsVC: MFMailComposeViewControllerDelegate {
    /// Opens a new mail to send to the developers. In case no account is linked to the iPhone, it opens Gmail app. If Gmail is not installed, it shows an alert with the email address.
    func sendEmail() {
        
        let mailTo = "royalframegame@gmail.com"
        let mailSubject = "Feedback"
        let mailBody = ""
        
        
        let googleUrlString = "googlegmail:///co?subject=\(mailSubject)&to=\(mailTo)&body=\(mailBody)"
        var canSendUsingGmail = false
        if let googleUrl = URL(string: googleUrlString) {
            canSendUsingGmail = UIApplication.shared.canOpenURL(googleUrl)
        }
        
        let canSendUsingMailApp = MFMailComposeViewController.canSendMail()
        
        if canSendUsingMailApp {
            // Send using Mail app
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([mailTo])
            mail.setSubject(mailSubject)
            mail.setMessageBody(mailBody, isHTML: false)

            present(mail, animated: true)
        } else if canSendUsingGmail {
            // Send using gmail
            UIApplication.shared.open(URL(string: googleUrlString)!, options: [:], completionHandler: nil)
        } else {
            let alert = UIAlertController(title: "Send us a mail", message: "Send a mail to \(mailTo) and help us improve!" , preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}



// MARK: - Setting Object
struct Setting {
    var label: String
    var segmentedControlSegments: [String]?
    var segmentedControlSettingKey: SettingKey?
    var segmentedControlAlertText: String?
    var segueName: SettingSegue?
    var infoText: String?
    
    init(
        label: String
        , segmentedControlSegments: [String]? = nil
        , segmentedControlSettingKey: SettingKey? = nil
        , segmentedControlAlertText: String? = nil
        , segueName: SettingSegue? = nil
        , infoText: String? = nil
        ) {
        self.label = label
        self.segmentedControlSegments = segmentedControlSegments
        self.segmentedControlSettingKey = segmentedControlSettingKey
        self.segmentedControlAlertText = segmentedControlAlertText
        self.segueName = segueName
        self.infoText = infoText
    }
}


class InfoButton: UIButton {
    var settingKey: SettingKey?
    var infoText: String?
}
