//
//  AboutUsVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 21/12/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class AboutUsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var creditsTableView: UITableView!
    
    let credits : [Credit] = [
        Credit(owner: "f4ngy", urlString: "https://freesound.org/people/f4ngy/sounds/240776/", rawName: "Card Flip", name: "Cards sounds"),
        Credit(owner: "Mike Koenig", urlString: "http://soundbible.com/1003-Ta-Da.html", rawName: "Ta Da Sound", name: "Winning sound"),
        Credit(owner: "TaranP", urlString: "https://freesound.org/people/TaranP/sounds/362204/", rawName: "horn_fail_wahwah_3.wav", name: "Losing sound"),
        Credit(owner: "icons8", urlString: "https://icons8.com/", rawName: "Gear, idea, refresh", name: "Tab bar icons"),
        Credit(owner: "Freepik", urlString: "https://www.flaticon.com/free-icon/rubbish-bin_64022?term=trash&page=1&position=1", rawName: "rubbish-bin.png", name: "Remove icon"),
        Credit(owner: "Dave Gandy", urlString: "https://www.flaticon.com/free-icon/correct-symbol_25404?term=check%20mark&page=1&position=3", rawName: "correct-symbol", name: "Done removing icon"),
        Credit(owner: "Roundicons", urlString: "https://www.flaticon.com/free-icon/right-arrow_271228", rawName: "right-arrow", name: "Settings right arrow"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creditsTableView.dataSource = self
        creditsTableView.delegate = self
        
        creditsTableView.backgroundColor = .clear
        creditsTableView.sectionHeaderHeight = 70

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credits.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let sectionLabel = createHeaderLabel(text: "Credits")
        
        headerView.addSubview(sectionLabel)
        
        NSLayoutConstraint.activate([
            sectionLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            sectionLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return headerView
    }

    
    /**
     Creates a header for the section
     
     - Parameter text: The text of the label
     - Returns: A UILabel with the wanted properties
     */
    func createHeaderLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "kefa", size: 30)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createCell(for: credits[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: credits[indexPath.row].urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func createCell(for credit: Credit) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let font = UIFont(name: "Kefa", size: 15)
    
        let itemLabel = UILabel()
        itemLabel.text = credit.name
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.font = font
        itemLabel.textColor = .white
        cell.addSubview(itemLabel)
        
        let ownerLabel = UILabel()
        ownerLabel.text = "by \(credit.owner)"
        ownerLabel.translatesAutoresizingMaskIntoConstraints = false
        ownerLabel.font = font
        ownerLabel.textColor = .white
        cell.addSubview(ownerLabel)
        
        NSLayoutConstraint.activate([
            itemLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            itemLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            ownerLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -20),
            ownerLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            itemLabel.trailingAnchor.constraint(greaterThanOrEqualTo: ownerLabel.leadingAnchor, constant: 20)
        ])
        
//        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        cell.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        let cellColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5)
        
        cell.backgroundColor = cellColor
        
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = .clear
        
        return cell
    }
    
}

struct Credit {
    var owner: String
    var urlString: String
    var rawName: String
    var name: String
    var url: URL?
    
    
}
