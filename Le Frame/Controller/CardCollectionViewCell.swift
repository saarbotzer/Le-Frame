//
//  CardCollectionViewCell.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var card: Card?
    var isEmpty: Bool = false
    var indexPath: IndexPath?
    
    func initializeSpot(with card: Card?, at indexPath: IndexPath) {
        self.card = card
        self.indexPath = indexPath
        
        if let card = card {
            imageView.image = UIImage(named: card.imageName)
            self.isEmpty = false
        } else {
            imageView.image = UIImage(named: "green_card.png")
            self.isEmpty = true
        }
    }
    
    func setCard(_ card: Card) {
        self.card = card
        imageView.image = UIImage(named: card.imageName)
        self.isEmpty = false
    }
    
    func setEmpty() {
        self.card = nil
        imageView.image = UIImage(named: "green_card.png")
        self.isEmpty = true
    }
    
    func removeCard() {
        setEmpty()
    }
    
    func setSelected() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.red.cgColor
    }
    
    func setNotSelected() {
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
    }
}


enum AllowedRanks {
    case kings
    case jacks
    case queens
    case notRoyal
}
