//
//  NewSettingsVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 21/12/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class NewSettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    /// A dict that contains all of the settings. The key is the section name.
    let settingsSections: [String : [Setting]] =
        [
            "Game": [
                Setting(label: "Removal sum", segmentedControlSegments: ["10", "11"], segmentedControlPropertyName: "removeSum", segmentedControlAlertText: "Yes", segueName: nil),
                Setting(label: "Remove when full board", segmentedControlSegments: ["Yes", "No"], segmentedControlPropertyName: "removeWhenFullBoard", segmentedControlAlertText: "Yes", segueName: nil),
                Setting(label: "Show hints?", segmentedControlSegments: ["Yes", "No"], segmentedControlPropertyName: "showHints", segmentedControlAlertText: "No", segueName: nil),
                Setting(label: "Statistics", segmentedControlSegments: nil, segmentedControlPropertyName: nil, segmentedControlAlertText: nil, segueName: "goToStatistics")
            ],
            "Help": [
                Setting(label: "Tutorial", segmentedControlSegments: nil, segmentedControlPropertyName: nil, segmentedControlAlertText: nil, segueName: "goToTutorial"),
                Setting(label: "FAQ", segmentedControlSegments: nil, segmentedControlPropertyName: nil, segmentedControlAlertText: nil, segueName: "goToFAQ")
            ],
            "About": [
                Setting(label: "About us", segmentedControlSegments: nil, segmentedControlPropertyName: nil, segmentedControlAlertText: nil, segueName: "goToAboutUs"),
                Setting(label: "Privacy Policy", segmentedControlSegments: nil, segmentedControlPropertyName: nil, segmentedControlAlertText: nil, segueName: "goToPrivacyPolicy"),
                Setting(label: "Rate us!", segmentedControlSegments: nil, segmentedControlPropertyName: nil, segmentedControlAlertText: nil, segueName: "rateUs"),
                Setting(label: "Contact us", segmentedControlSegments: nil, segmentedControlPropertyName: nil, segmentedControlAlertText: nil, segueName: "goToContactUs")
            ]
    ]
    
    /// All of the section names in the wanted order.
    let sectionNames = ["Game", "Help", "About"]
    
    let sectionFontName = "Kefa"
    let settingFontName = "Kefa"
    let sectionFontSize: CGFloat = 30.0
    let settingFontSize: CGFloat = 14.0
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        updateUI()
    }

    func updateUI() {
        navigationController?.navigationBar.tintColor = UIColor.white
        let barAppearance = UINavigationBar.appearance()
        barAppearance.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        barAppearance.shadowImage = UIImage()
        barAppearance.isTranslucent = true
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.sectionHeaderHeight = 70
        
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
            performSegue(withIdentifier: segueName, sender: nil)
        }
    }
    
    
    // MARK: - Create Views
    
    /**
     Creates a UISegmentedControl for a setting row
     
     - Parameter setting: The Setting objects which contains the data to created the segmented control
     - Returns: The segmented control with the properties defined in setting, nil if the row doesn't have a segmented control
     */
    func createSegmentedControl(for setting: Setting) -> UISegmentedControl? {
        let goldColor = UIColor(red: 1, green: 215.0/255.0, blue: 0, alpha: 1)
        let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let selectedColor = goldColor
        let textColor = UIColor.white
        let selectedTextColor = UIColor.black
        let borderColor = UIColor.white
        let borderWidth: CGFloat = 0
        let font = UIFont(name: settingFontName, size: settingFontSize)
        
        if let items = setting.segmentedControlSegments {
            let segmentedControl = UISegmentedControl(items: items)
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: font], for: .normal)
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedTextColor, NSAttributedString.Key.font: font], for: .selected)

            if #available(iOS 13.0, *) {
                segmentedControl.layer.borderColor = borderColor.cgColor
                segmentedControl.layer.borderWidth = borderWidth
                segmentedControl.layer.backgroundColor = backgroundColor.cgColor
                segmentedControl.selectedSegmentTintColor = selectedColor
            } else {
                segmentedControl.tintColor = selectedColor
            }
            // TODO: Determine which item is selected by default settings
            // TODO: Add action to change the default setting (by setting.segmentedControlPropertyName), also add action (segmentedControlAlertText)
            return segmentedControl
        }
        return nil
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
        
        if setting.segueName != nil {
            let rightArrowImage = UIImage(named: "right-arrow.png")?.withRenderingMode(.alwaysTemplate) ?? UIImage(named: "right-arrow.png")
            let rightArrowImageView = UIImageView(image: rightArrowImage)
            rightArrowImageView.tintColor = .white

            rightArrowImageView.translatesAutoresizingMaskIntoConstraints = false

            cell.addSubview(rightArrowImageView)
            NSLayoutConstraint.activate([
            rightArrowImageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
            rightArrowImageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            rightArrowImageView.heightAnchor.constraint(equalToConstant: 15),
            rightArrowImageView.widthAnchor.constraint(equalToConstant: 15),
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
    }
}

// MARK: - Setting Object
struct Setting {
    var label: String
    var segmentedControlSegments: [String]?
    var segmentedControlPropertyName: String?
    var segmentedControlAlertText: String?
    var segueName: String?
}
