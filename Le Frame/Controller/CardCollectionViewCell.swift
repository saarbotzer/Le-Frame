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
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.cornerRadius = 5
    }
    
    /**
    Changes the appearance of the card to be deselected
    */
    func setNotSelected() {
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 0
    }
}


enum AllowedRanks {
    case kings
    case jacks
    case queens
    case notRoyal
}
