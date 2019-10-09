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
    
    func setCard(_ card: Card) {
        self.card = card
        imageView.image = UIImage(named: card.imageName)
        self.isEmpty = false
    }
    
    func setEmpty() {
        self.card = nil
        imageView.image = UIImage(named: "joker_black.jpg")
        self.isEmpty = true
    }
    
    func removeCard() {
        
    }
}


enum AllowedRanks {
    case kings
    case jacks
    case queens
    case notRoyal
    
    
}
