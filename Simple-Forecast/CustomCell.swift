//
//  CustomCell.swift
//  Simple-Forecast
//
//  Created by Alehandro on 2.06.22.
//

import Foundation
import UIKit

class CustomCell: UICollectionViewCell {
    override func prepareForReuse() {
            super.prepareForReuse()
            self.checkLabel.isHidden = true
        }
}
