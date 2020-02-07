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
    var isEmpty: Bool = true
    var isSpotSelected: Bool = false // Can't change name to 'isSelected' or 'selected' because it's a UICollectionViewCell's property
    var isSuggested: Bool = false
    var indexPath: IndexPath?
    var originalTransform: CGAffineTransform?
        
    // Shadow
    let defaultShadowRadius: CGFloat = 1
    let defaultShadowOffset: CGSize = CGSize(width: -1, height: 1)
        
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
        
    }
    
    /**
     Sets the initial UI of the spot
     */
    func setUI() {
        self.layer.cornerRadius = 4
        addShadow()
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
    
    private func getWiggleAnimation() -> CAKeyframeAnimation {
        
        let duration = 0.12
        let repeatCount: Float = 3
        
        let wiggleAnimation  = CAKeyframeAnimation(keyPath:"transform")
        wiggleAnimation.values  = [NSValue(caTransform3D: CATransform3DMakeRotation(0.04, 10, 0.0, 1.0)),NSValue(caTransform3D: CATransform3DMakeRotation(-0.04 , 0, 0, 1))]
        wiggleAnimation.autoreverses = true
        wiggleAnimation.duration  = duration
        wiggleAnimation.repeatCount = repeatCount
        
        return wiggleAnimation
    }
    
    
    /// Changes the UI of the card spot according to the wanted event.
    /// Events are selecting a card for removal, hinting a card and suggesting a card as an option for placing/pairing
    /// - Parameters:
    ///   - type: The wanted event to mark the card accordingly
    ///   - on: Whether to mark the card or change it back to the original look
    func mark(as type: CardMarkEvent, on: Bool) {
        
        let wiggleAnimation = getWiggleAnimation()
        let liftedTransformBy: CGFloat = 1.06
        let liftAnimationDuration: TimeInterval = 0.1
        
        // Default Values
        let defaultBorderColor: CGColor = UIColor.clear.cgColor
        let defaultTransform: CGAffineTransform = originalTransform!
        let defaultBorderWidth: CGFloat = 0
        
        // Selected Values
        /// Cyan
        let selectedBorderColor: CGColor = UIColor(red: 0.00, green: 0.76, blue: 0.75, alpha: 0.7).cgColor
        let selectedBorderWidth: CGFloat = 4
        let selectedShadowRadius: CGFloat = 4
        let selectedTransform: CGAffineTransform = defaultTransform.scaledBy(x: liftedTransformBy, y: liftedTransformBy)
        
        // Hinted Values
        /// Yellow
        let hintedBorderColor: CGColor = UIColor(red: 0.9995, green: 0.9883, blue: 0.4726, alpha: 0.7).cgColor
        let hintedBorderWidth: CGFloat = 4
        
        // Options Values
        /// Green-ish
        let suggestedBorderColor: CGColor = UIColor(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 0.7).cgColor
        let suggestedBorderWidth: CGFloat = 4
        
        
        var borderColor: CGColor = defaultBorderColor
        var borderWidth: CGFloat = defaultBorderWidth
        var transform: CGAffineTransform = defaultTransform
        var shadowRadius: CGFloat = defaultShadowRadius
        var returnToNormal: Bool = false
        var opacity: Float = 1
        
        switch type {
        case .selected:
            borderColor = on ? selectedBorderColor : defaultBorderColor
            borderWidth = on ? selectedBorderWidth : defaultBorderWidth
            shadowRadius = on ? selectedShadowRadius : defaultShadowRadius
            transform = on ? selectedTransform : defaultTransform
            isSpotSelected = on
        case .hint:
            if isSpotSelected {
                borderColor = selectedBorderColor
            } else if isSuggested {
                borderColor = suggestedBorderColor
            } else {
                borderColor = hintedBorderColor
            }
            borderWidth = hintedBorderWidth
            returnToNormal = true
//        case .disabledForRemoving, .disabledForPlacing:
//            if isSpotSelected {
//                borderColor = on ? suggestedBorderColor : selectedBorderColor
//                borderWidth = on ? suggestedBorderWidth : selectedBorderWidth
////                transform = on ? defaultTransform : selectedTransform
//                opacity = on ? 0.5 : 1
//            } else {
////                borderColor = on ? suggestedBorderColor : defaultBorderColor
////                borderWidth = on ? suggestedBorderWidth : defaultBorderWidth
////                transform = defaultTransform
//            }
//
//            opacity = on ? 0.5 : 1
//            isSuggested = on
            
        case .disabledForPlacing, .disabledForRemoving:
            opacity = on ? 0.5 : 1
            borderColor = isSpotSelected ? selectedBorderColor : defaultBorderColor
            borderWidth = isSpotSelected ? selectedBorderWidth : defaultBorderWidth
            transform = isSpotSelected ? selectedTransform : defaultTransform
        }
        
        
        UIView.animate(withDuration: liftAnimationDuration) {
            self.layer.borderColor = borderColor
            self.layer.borderWidth = borderWidth
            self.transform = transform
            self.layer.shadowRadius = shadowRadius
            self.layer.opacity = opacity
        }
        
        if type == .hint {
            self.layer.add(wiggleAnimation, forKey: "transform")
        }
        
        
        let deadline = DispatchTime.now() + liftAnimationDuration + Double(wiggleAnimation.duration) * Double(wiggleAnimation.repeatCount)
        
        if returnToNormal {
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                UIView.animate(withDuration: liftAnimationDuration) {
                    if self.isSpotSelected {
                        self.mark(as: .selected, on: self.isSpotSelected)
                    } else if self.isSuggested {
                        self.mark(as: .disabledForRemoving, on: self.isSuggested)
                    } else {
                        self.mark(as: .selected, on: false)
                    }
                }
            }
        }
    }
    
    /**
     Adds a default shadow to the spot
     */
    func addShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = defaultShadowOffset
        self.layer.shadowRadius = defaultShadowRadius

        self.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}


enum CardMarkEvent {
    /// When the spot is hinted
    case hint
    
    /// When the spot is selected for removal
    case selected
    
    /// When the spot is suggested as an option to pair with the selected card
    case disabledForRemoving
    
    /// When the spot is empty and suitable to place the next card in
    case disabledForPlacing
}


