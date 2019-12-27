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

class NewSettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Properties
    /// A dict that contains all of the settings. The key is the section name.
    let settingsSections: [String : [Setting]] =
        [
            "GAME": [
                Setting(label: "Removal sum", segmentedControlSegments: ["10", "11"], segmentedControlSettingKey: .sumMode, segmentedControlAlertText: "Yes", segueName: nil),
//                Setting(label: "Remove when full board", segmentedControlSegments: ["YES", "NO"], segmentedControlSettingKey: .removeWhenFull, segmentedControlAlertText: "Yes", segueName: nil),
                Setting(label: "Hints", segmentedControlSegments: ["ON", "OFF"], segmentedControlSettingKey: .showHints, segmentedControlAlertText: "No", segueName: nil),
                Setting(label: "Sounds", segmentedControlSegments: ["ON", "OFF"], segmentedControlSettingKey: .soundsOn, segmentedControlAlertText: "No", segueName: nil),
                Setting(label: "Statistics", segmentedControlSegments: nil, segmentedControlSettingKey: nil, segmentedControlAlertText: nil, segueName: "goToStatistics")
            ],
            "HELP": [
                Setting(label: "Tutorial", segmentedControlSegments: nil, segmentedControlSettingKey: nil, segmentedControlAlertText: nil, segueName: "goToTutorial"),
                Setting(label: "FAQ", segmentedControlSegments: nil, segmentedControlSettingKey: nil, segmentedControlAlertText: nil, segueName: "goToFAQ")
            ],
            "ABOUT": [
                Setting(label: "About us", segmentedControlSegments: nil, segmentedControlSettingKey: nil, segmentedControlAlertText: nil, segueName: "goToAboutUs"),
                Setting(label: "Privacy Policy", segmentedControlSegments: nil, segmentedControlSettingKey: nil, segmentedControlAlertText: nil, segueName: "PrivacyPolicy"),
                Setting(label: "Rate us!", segmentedControlSegments: nil, segmentedControlSettingKey: nil, segmentedControlAlertText: nil, segueName: "rateUs"),
                Setting(label: "Contact us", segmentedControlSegments: nil, segmentedControlSettingKey: nil, segmentedControlAlertText: nil, segueName: "goToContactUs")
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
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionName = sectionNames[indexPath.section]
        
        if let segueName = settingsSections[sectionName]?[indexPath.row].segueName {
            if segueName == "rateUs" {
                if #available(iOS 10.3,*){
                    SKStoreReviewController.requestReview()
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            } else if segueName == "PrivacyPolicy" {
                guard let url = URL(string: "http://www.freeprivacypolicy.com/privacy/view/2a29fd7a265d51d96bf75c8f422b751c") else { return }
                UIApplication.shared.open(url)
                tableView.deselectRow(at: indexPath, animated: true)
            } else if segueName == "goToContactUs" {
                sendEmail()
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                performSegue(withIdentifier: segueName, sender: nil)
            }
        }
    }
    
    
    // MARK: - Create Views
    
    /**
     Creates a UISegmentedControl for a setting row
     
     - Parameter setting: The Setting objects which contains the data to created the segmented control
     - Returns: The segmented control with the properties defined in setting, nil if the row doesn't have a segmented control
     */
    func createSegmentedControl(for setting: Setting) -> CustomSegmentedControl? {
        let goldColor = UIColor(red: 1, green: 215.0/255.0, blue: 0, alpha: 1)
        let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let selectedColor = goldColor
        let textColor = UIColor.white
        let selectedTextColor = UIColor.black
        let borderColor = UIColor.white
        let borderWidth: CGFloat = 0
        let font = UIFont(name: settingFontName, size: settingFontSize)
        
        if let items = setting.segmentedControlSegments {
            let segmentedControl = CustomSegmentedControl(setting: setting)
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
            // TODO: Determine which item is selected by default settings
//            let currentValue = defaults.object(forKey: setting.segmentedControlPropertyName!)
                        
            segmentedControl.selectedSegmentIndex = updateDefaultSettings(for: setting.segmentedControlSettingKey)
            
            // TODO: Add action to change the default setting (by setting.segmentedControlPropertyName), also add alert (segmentedControlAlertText)
            
            segmentedControl.addTarget(self, action: #selector(segmentControlValueChanged(sender:)), for: .valueChanged)
            
            
            return segmentedControl
        }
        return nil
    }
    
    @objc
    func segmentControlValueChanged(sender: CustomSegmentedControl) {
//        print(sender.settingKey)
        
        if let settingKey = sender.settingKey {
            let keyRawValue = settingKey.getRawValue()
            switch settingKey {
            case .sumMode:
                let newSumMode = sender.selectedSegmentIndex == 0 ? 10 : 11
                defaults.set(newSumMode, forKey: keyRawValue)
                // TODO: Show alert
                if gameSumMode.getRawValue() != newSumMode {
                    alertChange(for: sender.name!, currentValue: gameSumMode)
                }
            case .removeWhenFull:
                let newRemoveWhenFull = sender.selectedSegmentIndex == 0
                defaults.set(newRemoveWhenFull, forKey: keyRawValue)
                // TODO: Show alert
            case .showHints:
                let newShowHints = sender.selectedSegmentIndex == 0
                defaults.set(newShowHints, forKey: keyRawValue)
            case .soundsOn:
                let newSoundsOn = sender.selectedSegmentIndex == 0
                defaults.set(newSoundsOn, forKey: keyRawValue)
            }
        }
    }
    
    func alertChange(for settingName: String, currentValue: Any) {
        let title = settingName
        let message = "This setting for the current game has already been set on \(currentValue). This change will be active in the next game"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Got it", style: .default, handler: nil)

        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)

    }
    
    /**
     Updates the defaults settings and returns the selected index for the segmented control.
     
     */
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
            case .showHints, .removeWhenFull:
                if keyExists {
                    let showHints = defaults.bool(forKey: keyRawValue)
                    selectedSegmentIndex = showHints ? 0 : 1
                } else {
                    defaults.set(true, forKey: keyRawValue)
                }
            case .soundsOn:
                if keyExists {
                    let soundsOn = defaults.bool(forKey: keyRawValue)
                    selectedSegmentIndex = soundsOn ? 0 : 1
                } else {
                    defaults.set(true, forKey: keyRawValue)
                }
            }
        }
        
        return selectedSegmentIndex
    }
    
    
    
    /**
     Creates a header for the section
     
     - Parameter text: The text of the label
     - Returns: A UILabel with the wanted properties
     */
    func createHeaderLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: sectionFontName, size: sectionFontSize)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    /**
     Create a UITableViewCell for a Setting row
     
     - Parameter setting: The Setting objects which contains the data to created the row cell
     - Returns: The table view cell of the setting
     */
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

        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        ])
        
        let selectedBackgroundView = UIView(frame: cell.frame)

        if let segmentedControl = createSegmentedControl(for: setting) {
            cell.addSubview(segmentedControl)
            NSLayoutConstraint.activate([
                segmentedControl.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                segmentedControl.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                segmentedControl.heightAnchor.constraint(equalToConstant: 24),
                segmentedControl.widthAnchor.constraint(equalToConstant: 100),
            ])
            
            selectedBackgroundView.backgroundColor = .clear
        } else {
            // If there is a segmented control, the cell can't be selected
            selectedBackgroundView.backgroundColor = selectedCellColor
        }
        
        if setting.segueName != nil  && setting.segueName != "rateUs"  && setting.segueName != "goToContactUs" {
            let gotoImage = UIImage(named: gotoIcon)?.withRenderingMode(.alwaysTemplate) ?? UIImage(named: gotoIcon)
            let gotoImageView = UIImageView(image: gotoImage)
            gotoImageView.tintColor = .white
//            rightArrowImageView.tintColor = UIColor(red: 1, green: 215.0/255.0, blue: 0, alpha: 1)

            gotoImageView.translatesAutoresizingMaskIntoConstraints = false

            cell.addSubview(gotoImageView)
            NSLayoutConstraint.activate([
                gotoImageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                gotoImageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                gotoImageView.heightAnchor.constraint(equalToConstant: 15),
                gotoImageView.widthAnchor.constraint(equalToConstant: 15),
            ])
        }
        
        cell.selectedBackgroundView = selectedBackgroundView

        cell.backgroundColor = cellColor
        
        return cell
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

class CustomSegmentedControl : UISegmentedControl {
    
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

extension NewSettingsVC: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["royalframegame@gmail.com"])
//            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
//            mail.title = "Feedback"
            mail.setSubject("Feedback")

            present(mail, animated: true)
        } else {
            // show failure alert
            print("mail failure")
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
    var segueName: String?
}

enum SettingKey: String {
    case sumMode = "SumMode"
    case showHints = "ShowHints"
    case removeWhenFull = "RemoveWhenFull"
    case soundsOn = "SoundsOn"
    
    func getRawValue() -> String {
        return self.rawValue
    }
}
