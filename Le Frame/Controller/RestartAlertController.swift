//
//  RestartAlertController.swift
//  Le Frame
//
//  Created by Saar Botzer on 07/12/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

struct AlertButton {
    var title: String!
    var action: (() -> Swift.Void)? = nil
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
        self.view.layer.cornerRadius = 10
        self.view.bounds = CGRect(x: self.view.bounds.minX, y: self.view.bounds.minY, width: 350, height: 250)
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
