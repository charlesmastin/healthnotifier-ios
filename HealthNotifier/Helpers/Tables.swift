//
//  Tables.swift
//
//  Created by Charles Mastin on 12/12/16.
//

import Foundation
import UIKit

class Tables {
    static func decorateProfilePhoto(_ cell: UITableViewCell, photoUrl: String, imageSize: Int=44, placeholder: UIImage? = nil) -> UITableViewCell {
        let placeholder = UIImage(named: "selfie_image")
        
        cell.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        cell.imageView?.kf.setImage(
            with: URL(string: photoUrl),
            placeholder: placeholder,
            options: [.requestModifier(LSQAPI.sharedInstance.kfModifier)]
        )
        
        let innerFrame = CGRect(x: 0, y: 0, width: imageSize - 2, height: imageSize - 2)
        let maskLayer = CAShapeLayer()
        let circlePath = UIBezierPath(roundedRect: innerFrame, cornerRadius: innerFrame.width)
        maskLayer.path = circlePath.cgPath
        maskLayer.fillColor = LSQ.appearance.color.blue.cgColor
        
        let strokeLayer = CAShapeLayer()
        strokeLayer.path = circlePath.cgPath
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.strokeColor = LSQ.appearance.color.white.cgColor
        strokeLayer.lineWidth = 2
        
        // add the layer
        cell.imageView?.layer.addSublayer(maskLayer)
        cell.imageView?.layer.mask = maskLayer
        cell.imageView?.layer.addSublayer(strokeLayer)
        return cell
    }
}
