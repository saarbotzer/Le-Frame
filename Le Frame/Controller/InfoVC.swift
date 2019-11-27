//
//  InfoVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 27/11/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class InfoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
