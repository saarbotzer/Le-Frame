//
//  RestartAlertController.swift
//  Le Frame
//
//  Created by Saar Botzer on 07/12/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit


// TODO: Rename to dialogue?

struct AlertButton {
    var title: String!
    var action: (() -> Void)? = nil
    var titleColor: UIColor?
    var backgroundColor: UIColor?
}

struct AlertPayload {
    var title: String!
    var titleColor: UIColor?
    var message: String!
    var messageColor: UIColor?
    var buttons: [AlertButton]!
    var backgroundColor: UIColor?
}

enum AlertType {
    case gameOver, gameWon, restart, info, settingChange, onboarding
    
    /*
     gameOver:
        - Game Over                         title
        - Lose reason                       label
        - Additional (cards left, time)     label
        - New Game                          button
        - Dismiss (OK)                      button
     gameWon:
        - You Won!                          title
        - Time                              label
        - Record and additional             label
        - New game                          button
        - Dismiss (OK)                      button
     restart:
        - Are you sure?                     title
        - Description                       label
        - New game                          button
        - Dismiss (OK)                      button
     info:
        - Headline                          title
        - Explaination                      label
        - Additional                        view?
        - Dismiss (OK)                      button
     settingChange:
        - Setting name                      title
        - Explaination                      label
        - New game                          button
        - Dismiss (Got it)                  button
     onboarding1:
        - Welcome                           title
        - Logo                              image
        - Objective                         label
        - Tour explaination                 label
        - Continue to tour                  button
        - Skip tour                         button
     onboarding2:
        - That's all                        title
        - Logo                              image
        - Tips and questions                label
        - Enjoy                             label
        - Start playing                     button
        - Redo tour                         button
     */
}

class RestartAlertController: UIViewController {

    var payload: AlertPayload!
        
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = payload.title
        messageLabel.text = payload.message
        
        if (payload.buttons.count == 2) {
            createButton(uiButton: confirmButton, alertButton: payload.buttons[0]);
            createButton(uiButton: dismissButton, alertButton: payload.buttons[1]);
        }
        
        if (payload.backgroundColor != nil) {
            view.backgroundColor = payload.backgroundColor;
        }
        
        updateUI()
    }
    
    func updateUI() {
        self.view.layer.cornerRadius = 30
//        self.view.bounds = CGRect(x: self.view.bounds.minX, y: self.view.bounds.minY, width: 500, height: 250)
    }
    
    func createButton(uiButton: UIButton, alertButton: AlertButton) {
        uiButton.setTitle(alertButton.title, for: .normal)
        
        if (alertButton.titleColor != nil) {
            uiButton.setTitleColor(alertButton.titleColor, for: .normal);
        }
        if (alertButton.backgroundColor != nil) {
            uiButton.backgroundColor = alertButton.backgroundColor;
        }
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        parent?.dismiss(animated: false, completion: nil)
        payload.buttons[0].action?()
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        parent?.dismiss(animated: false, completion: nil)
        payload.buttons[1].action?()
    }
    
}

/*
extension UIAlertController {
    open override func updateViewConstraints() {
        let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.view.subviews[0], attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120.0)
        let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.view.subviews[0], attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120.0)

        for constraint in self.view.subviews[0].constraints {
          if constraint.firstAttribute == .width && constraint.constant == 270{
            NSLayoutConstraint.deactivate([constraint])
            break
          }
        }

        self.view.subviews[0].addConstraint(widthConstraint)
        self.view.subviews[0].addConstraint(heightConstraint)

        super.updateViewConstraints()
    }
}
*/
