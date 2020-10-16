//
//  faqVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 21/12/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class faqVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let questions : [Question] = [
        Question(question: "Where can I place cards on the board?", answer: "Numbered cards (Ace to 10) can be placed anywhere on the board. Kings can only be placed in the corners, queens can only be place in the middle-top and middle-bottom, and jacks can only be placed in the middle-right and middle-left spots."),
        Question(question: "How to place cards?", answer: "Just tap the wanted spot. If the spot is empty and the card is allowed in the spot, it will move to the spot."),
        Question(question: "How to remove cards?", answer: "Select the cards you want to remove. Selected cards are marked with a light-blue frame. Then press Remove and the cards will be removed if they sum up to the current sum mode."),
        Question(question: "What sets the cards order?", answer: "The cards are dealt randomly. There are 80,658,175,170,943,878,571,660,636,856,403,766,975,289,505,440,883,277,824,000,000,000,000 different combinations for each deck, so chances are that each game has a never before dealt order!"),
        Question(question: "Do you collect personal data?", answer: "No, we do not collect any personal data."),
        Question(question: "How can I contact you?", answer: "You can contact us at royalframegame@gmail.com")
//        Question(question: "What's next?", answer: "We plan to add challenges, custom background anc card styles, fun winning animations and more :)"),

    ]
    
    var openIndexes : [Bool] = [
        false,
        false,
        false
    ]
    
    let questionFontName = "Kefa"
    let answerFontName = "Kefa"
    let questionFontSize: CGFloat = 25.0
    let answerFontSize: CGFloat = 14.0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        
        openIndexes = [Bool](repeating: false, count: questions.count)
//        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        UIView.animate(withDuration: 0.8, animations: {
//            cell.contentView.alpha = 1
//        })
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionIsOpen = openIndexes[indexPath.section]

        if !sectionIsOpen && indexPath.row == 1 {
            return 0
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        var labelText = ""
        var cellColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5)
        var roundedCorners : UIRectCorner = []
        var font: UIFont = UIFont()
        var textAlignment : NSTextAlignment = .left
        
        let question = questions[indexPath.section]
        let questionText = question.question
        let answerText = question.answer
        
        
        let sectionIsOpen = openIndexes[indexPath.section]
        
        if !sectionIsOpen && indexPath.row == 1 {
            cell.heightAnchor.constraint(equalToConstant: 0).isActive = true
            cell.backgroundColor = .clear
            return cell
        }
        
        if indexPath.row == 0 {
            labelText = questionText
            roundedCorners = sectionIsOpen ? [.topLeft, .topRight] : [.topRight, .topLeft, .bottomLeft, .bottomRight]
            font = UIFont(name: questionFontName, size: questionFontSize)!
            textAlignment = .left
        } else if indexPath.row == 1 {
            labelText = answerText
            roundedCorners = [.bottomLeft, .bottomRight]
            font = UIFont(name: answerFontName, size: answerFontSize)!
            cell.contentView.alpha = 0
//            textAlignment = .justified
        }
        
        cellColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5)
        
        let label = UILabel()
        label.text = labelText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 10
        label.font = font
        label.textAlignment = textAlignment
        label.textColor = .white
//        label.sizeToFit()
        cell.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        ])
        
        cell.roundCorners(roundedCorners, radius: 8)
                
        cell.backgroundColor = cellColor
        
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = .clear
        
        UIView.animate(withDuration: 2, animations: { cell.contentView.alpha = 1 })

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            openIndexes[indexPath.section] = !openIndexes[indexPath.section]
            tableView.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return questions.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}

struct Question {
    var question: String
    var answer: String
}

extension UIView {

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}
