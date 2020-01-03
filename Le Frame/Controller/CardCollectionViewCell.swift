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
    var isSpotSelected: Bool = false
    var indexPath: IndexPath?
    var originalTransform: CGAffineTransform?
    
    // MARK: Design Constants
    // Lift animation
    let borderWidth: CGFloat = 4.0
    let transformBy: CGFloat = 1.06
    let liftAnimationDuration: TimeInterval = 0.1
    let cornerRadius: CGFloat = 4
    
    // Shadow
    let defaultShadowRadius: CGFloat = 1
    let liftedShadowRadius: CGFloat = 4
    let shadowOffset: CGSize = CGSize(width: -1, height: 1)
    
    let selectedColor = UIColor(red: 0.00, green: 0.76, blue: 0.75, alpha: 0.7)
    let hintedColor = UIColor(red: 0.9995, green: 0.9883, blue: 0.4726, alpha: 0.7)
    
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
        self.layer.cornerRadius = cornerRadius
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
    
    /**
     Changes the appearance of the card to be selected
     */
    func setSelected(selected: Bool) {
        isSpotSelected = selected
        if selected {
            let scaledTransform = originalTransform!.scaledBy(x: transformBy, y: transformBy)

            UIView.animate(withDuration: liftAnimationDuration) {
                
                self.layer.borderColor = self.selectedColor.cgColor
                self.layer.borderWidth = self.borderWidth
                
                self.transform = scaledTransform
                
                self.layer.shadowRadius = self.liftedShadowRadius
            }
        } else {
            UIView.animate(withDuration: liftAnimationDuration) {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0
                
                self.transform = self.originalTransform!
                self.layer.shadowRadius = self.defaultShadowRadius
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
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = defaultShadowRadius

        self.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    
    /**
     */
    func setHinted(on: Bool) {
        let wiggleDuration = 0.12
        let repeatCount : Float = 3.0
        if on {
            let transformAnim  = CAKeyframeAnimation(keyPath:"transform")
            transformAnim.values  = [NSValue(caTransform3D: CATransform3DMakeRotation(0.04, 10, 0.0, 1.0)),NSValue(caTransform3D: CATransform3DMakeRotation(-0.04 , 0, 0, 1))]
            transformAnim.autoreverses = true
            transformAnim.duration  = wiggleDuration
            transformAnim.repeatCount = repeatCount
            
            if !isSpotSelected {
                UIView.animate(withDuration: liftAnimationDuration) {
                    
                    self.layer.borderColor = self.hintedColor.cgColor
                    self.layer.borderWidth = self.borderWidth
                    
                }
            }
            self.layer.add(transformAnim, forKey: "transform")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + liftAnimationDuration + wiggleDuration * Double(repeatCount)) {
                UIView.animate(withDuration: self.liftAnimationDuration) {
                    self.setSelected(selected: self.isSpotSelected)
                }
            }
        }
    }
}



