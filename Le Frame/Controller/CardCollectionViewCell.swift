//
//  CardCollectionViewCell.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties & Declerations
    @IBOutlet weak var imageView: UIImageView!
    
    var card: Card?
    var isEmpty: Bool = false
    var indexPath: IndexPath?
    var originalTransform: CGAffineTransform?
    
    /**
     Initializes the spot with default values and appearance.
     
     - Parameter card: The card to place at the spot, should always be nil but if not it is placed.
     - Parameter indexPath: The spot's IndexPath in the CollectionView
     */
    func initializeSpot(with card: Card?, at indexPath: IndexPath) {
        self.card = card
        self.indexPath = indexPath
        
        if let card = card {
            imageView.image = UIImage(named: card.imageName)
            self.isEmpty = false
        } else {
            imageView.image = UIImage(named: spotImageName)
            self.isEmpty = true
        }
        
        self.originalTransform = self.transform
        
        setUI()
        addShadow()
    }
    
    func setUI() {
        self.layer.cornerRadius = 4
    }
    
    /**
     Sets the card for the spot and changes the photo to match the card.
     
     - Parameter card: The card to set. If nil then the card is removed
     */
    func setCard(_ card: Card?) {
        if let card = card {
        
            self.card = card
            self.isEmpty = false

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cardAnimationDuration) {
                self.imageView.image = UIImage(named: card.imageName)
            }
        } else {
            self.card = nil
            imageView.image = UIImage(named: spotImageName)
            self.isEmpty = true
        }
    }
    
    /**
     Removes the card from the spot
     */
    func removeCard() {
        setCard(nil)
    }
    
    /**
     Changes the appearance of the card to be selected
     */
    func setSelected() {
        // TODO: Use constants (border, transform, animation, color)
        let borderWidth: CGFloat = 2.0
        let transformBy: CGFloat = 1.06
        let scaledTransform = originalTransform!.scaledBy(x: transformBy, y: transformBy)

        UIView.animate(withDuration: 0.2) {
            
            self.layer.borderColor = UIColor(red: 0.9995, green: 0.9883, blue: 0.4726, alpha: 1).cgColor
            self.layer.borderWidth = borderWidth
            
            self.transform = scaledTransform
            
            self.layer.shadowRadius = 5
        }
        
    }
    
    /**
    Changes the appearance of the card to be deselected
    */
    func setNotSelected() {
        // TODO: Use constants (border, transform, animation)

        // TODO: Make transformBy be relative to enlargement
//        let scaledTransform = originalTransform!.scaledBy(x: transformBy, y: transformBy)
        
        UIView.animate(withDuration: 0.3) {

//            self.frame = self.frame.insetBy(dx: borderWidth, dy: borderWidth)
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 0
            
//            self.layer.frame = self.originalFrame!
            self.transform = self.originalTransform!
            self.layer.shadowRadius = 1
        }
        
    }
    
    func addShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1

        self.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}


enum AllowedRanks {
    case kings
    case jacks
    case queens
    case notRoyal
}
