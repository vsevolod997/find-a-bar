//
//  CompasVIew.swift
//  Find a bar
//
//  Created by Всеволод Андрющенко on 23.11.2019.
//  Copyright © 2019 Всеволод Андрющенко. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let background = CAGradientLayer()
        background.frame = self.bounds
        background.colors = [UIColor.clear.cgColor, UIColor.systemGray.cgColor]
        background.startPoint = CGPoint(x: 0.57, y: 0.75)
        background.endPoint = CGPoint(x: 0.55, y: 1)
        self.layer.addSublayer(background)
    }
}
