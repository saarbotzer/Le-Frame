//
//  roundButton.swift
//  Le Frame
//
//  Created by Saar Botzer on 25/11/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

@IBDesignable
class roundButton: UIButton {
//    @IBInspectable var titleText: String? {
//        didSet {
//            self.setTitle(titleText, for: .normal)
//            self.setTitleColor(UIColor.white,for: .normal)
//        }
//    }

    override init(frame: CGRect){
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    func setup() {
//        self.clipsToBounds = true
        
        let width = self.frame.size.width
        
        self.layer.cornerRadius = width / 2
        self.frame.size.height = width
        self.titleEdgeInsets = UIEdgeInsets(top: width + 20, left: 0, bottom: 0, right: 0)
        
        
        let imageWidth = self.currentImage?.size.width ?? 0
                
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: width / 2 - imageWidth / 2, bottom: 0, right: 0)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.center = CGPoint(x: 160, y: 284)
        label.textAlignment = .center
        label.text = "I'm a test label"

        self.addSubview(label)
//        self.setImage(UIImage(named: "hint_icon.png"), for: .normal)
    }
}
