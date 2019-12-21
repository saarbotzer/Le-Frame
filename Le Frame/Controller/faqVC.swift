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
        Question(question: "How to play?", answer: "Just like that")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                
        let headerView = UIView()
        
        let question = questions[section]
        let questionText = question.question

        let questionLabel = UILabel()
        questionLabel.text = questionText
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(questionLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            questionLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = headerView.frame
        rectShape.position = headerView.center
        rectShape.path = UIBezierPath(roundedRect: headerView.bounds, byRoundingCorners: [.bottomLeft , .bottomRight , .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath

        headerView.layer.mask = rectShape
        
        let cellColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5)
        
        headerView.backgroundColor = cellColor
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var labelText = ""
        var cellColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5)
        var roundedCorners : UIRectCorner = [.bottomLeft, .bottomRight]
        
        
        let question = questions[indexPath.section]
        let questionText = question.question
        let answerText = question.answer
        
        if indexPath.row == 0 {
            labelText = questionText
            cellColor = UIColor(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.8)
            roundedCorners.insert(.topRight)
        } else if indexPath.row == 1 {
            labelText = answerText
            cellColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5)
            roundedCorners.insert(.topLeft)
        }
        
        
        let label = UILabel()
        label.text = labelText
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        ])
        
        cell.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = cell.frame
        rectShape.position = cell.center
        rectShape.path = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: roundedCorners, cornerRadii: CGSize(width: 20, height: 20)).cgPath

        cell.layer.mask = rectShape
                
        cell.backgroundColor = cellColor
        
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = .clear
        
        return cell

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
