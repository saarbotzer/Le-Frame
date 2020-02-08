//
//  ContactUsVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 02/01/2020.
//  Copyright © 2020 Saar Botzer. All rights reserved.
//

import UIKit

class ContactUsVC: UIViewController, UITextViewDelegate, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addTapGesture()
        setupUI()

        presentationController?.delegate = self
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    func setupUI() {
        setupTextView()
        setupSendButton()
    }
    
    func setupTextView() {
        messageTextView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5)
        messageTextView.roundCorners([.allCorners], radius: 10)
    }
    
    func setupSendButton() {
        sendButton.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.5)
        sendButton.roundCorners([.allCorners], radius: 10)
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        print(messageTextView.text ?? "")
    }
    
    
    func addTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("bbb")
        messageTextView.backgroundColor = .cyan
    }
//
//    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
//        print("ccc")
//    }
//
//    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
//        print("aaa")
////        return false
//        return true
//    }

//    func showAlertBeforeDismisal() {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//
//        let restartAction = UIAlertAction(title: confirmText, style: .default) { (action) in
//            self.stopTimer()
//            self.restartAfter = true
//            self.addStats()
//            self.startNewGame()
//        }
//        let okAction = UIAlertAction(title: dismissText, style: .cancel, handler: nil)
//
//        alert.addAction(okAction)
//        alert.addAction(restartAction)
//
//        present(alert, animated: true, completion: nil)
//    }
}
