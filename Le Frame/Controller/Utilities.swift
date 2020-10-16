//
//  Utilities.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit



public let spotImageName = "card-spot.png"

/// The time that takes for a card to move from the new card spot to it's designated spot.
public let cardAnimationDuration : Double = 0.2


//public let nextCardSpot



public var gameFinished : Bool = false
//public var gameRemovalWhenFull : Bool = false

struct Utilities {
    static func getCenterSpots() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for i in 1...2 {
            for j in 1...2 {
                indexPaths.append(IndexPath(row: i, section: j))
            }
        }
        return indexPaths
    }
    
    
    // TODO: Document
    static func getSpots(forRank rank: CardRank, overlapping: Bool = false) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        var spotsList = [(Int, Int)]()
        switch rank {
        case .jack:
            spotsList = [(0, 1), (0, 2), (3, 1), (3, 2)]
        case .queen:
            spotsList = [(1, 0), (2, 0), (1, 3), (2, 3)]
        case .king:
            spotsList = [(0, 0), (0, 3), (3, 0), (3, 3)]
        default:
            if overlapping {
                spotsList = [
                    (0, 0), (1, 0), (2, 0), (3, 0),
                    (0, 1), (1, 1), (2, 1), (3, 1),
                    (0, 2), (1, 2), (2, 2), (3, 2),
                    (0, 3), (1, 3), (2, 3), (3, 3)
                ]
            } else {
                spotsList = [(1, 1), (1, 2), (2, 1), (2, 2)]
            }
        }
        
        indexPaths = spotsList.map({ (indexes) -> IndexPath in
            return IndexPath(row: indexes.0, section: indexes.1)
        })
        return indexPaths
        
    }
    
    static func getAllowedRanksByPosition(indexPath: IndexPath) -> DesignatedRanks {
        let row = indexPath.row
        let column = indexPath.section
        
        switch (row, column) {
        // Corners
        case (0, 0), (0, 3), (3, 0), (3, 3):
            return .kings
        // Sides
        case (1, 0), (2, 0), (1, 3), (2, 3):
            return .queens
        // Floor and ceiling
        case (0, 1), (0, 2), (3, 1), (3, 2):
            return .jacks
        // Center
        default:
            return .notRoyal
        }
    }
    

    
    static func formatSeconds(seconds: Int) -> String {
        // TODO: Add days, weeks, months
        
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        
        var timeString = ""
        
        if hours > 0 {
            timeString = String(format: "%02i:%02i:%02i hrs", hours, minutes, seconds)
        } else if minutes > 0 {
            timeString = String(format: "%02i:%02i mins", minutes, seconds)
        } else {
            timeString = String(format: "%02i secs", seconds)
        }
        
        return timeString
    }
    
    public static func log(_ items: Any...) {
        let stringToPrint = items.map { (item) -> String in
            return "\(item)"
        }.joined(separator: " ")
        
        print(stringToPrint)
    }
}


extension String {

  var length: Int {
    return count
  }

  subscript (i: Int) -> String {
    return self[i ..< i + 1]
  }

  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }

  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }

  subscript (r: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                        upper: min(length, max(0, r.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }

}



class Toast {
    static func show(message: String, controller: UIViewController) {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 25;
        toastContainer.clipsToBounds  =  true
        toastContainer.layer.zPosition = 15

        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font.withSize(12.0)
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0

        toastContainer.addSubview(toastLabel)
        controller.view.addSubview(toastContainer)
        controller.view.bringSubviewToFront(toastContainer)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false

        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
        toastContainer.addConstraints([a1, a2, a3, a4])

        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 65)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -65)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1, constant: -75)
        controller.view.addConstraints([c1, c2, c3])

        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}


extension Array where Element: Hashable {
    // TODO: Document
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}


extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}



extension UIView {
    func addShadow(with radius: CGFloat) {
        
        let shadowWorksProperly = false
        
        if !shadowWorksProperly {
            return
        }

        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = radius

        self.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}


struct GameMove: CustomStringConvertible {
    var cards: [Card]
    var indexPaths: [IndexPath]
    var moveType: MoveType
    
    public var description: String {
        var locationStr = ""
        var actionStr = ""
        var cardsStrings: [String] = [String]()
        
        if self.moveType == .place {
            actionStr = "Placed"
            locationStr = "at"
        } else if self.moveType == .remove {
            actionStr = "Removed"
            locationStr = "from"
        }
        for (card, indexPath) in zip(cards, indexPaths) {
            cardsStrings.append("\(card) \(locationStr) \(indexPath)")
        }
        
        return "\(actionStr) \(cardsStrings.joined(separator: ", "))"
    }
}

// MARK: Alert Functions
extension Utilities {
    static func showAlert(payload: AlertPayload, parentViewController: UIViewController) {
        var customAlertController: RestartAlertController!;
        if (payload.buttons.count == 2) {
            customAlertController = instantiateViewController(storyboardName: "Main", viewControllerIdentifier: "RestartAlert") as! RestartAlertController;
        }
        else {
            // Action not supported
            return;
        }
        customAlertController?.payload = payload
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertController.setValue(customAlertController, forKey: "contentViewController")

//        var heightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: parentViewController.view.frame.height * 0.30)

//        alertController.view.addConstraint(heightConstraint)
        
//        alertController.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
//        alertController.view.widthAnchor.constraint(equalToConstant: 300).isActive = true
//        alertController.view.bounds = CGRect(x: 0, y: 0, width: 500, height: 500)
//        alertController.view.layer.cornerRadius = 50
        parentViewController.present(alertController, animated: true, completion: nil)
    }
 
    
    static func instantiateViewController(storyboardName: String, viewControllerIdentifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main);
        return storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier);
    }
}

extension UIColor {
    /// #FCD600
    static let frameGold: UIColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
    
    static let frameDarkGold: UIColor = UIColor(red: 0.78, green: 0.64, blue: 0, alpha: 1)
    static let frameBackgroundOverlay: UIColor = UIColor(red: 0.65, green: 0.8, blue: 0.65, alpha: 0.65)
}
