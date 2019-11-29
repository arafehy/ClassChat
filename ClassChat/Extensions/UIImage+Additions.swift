//
//  UIImage+Additions.swift
//  ClassChat
//
//  Created by CMPE137 on 11/18/19.
//  Copyright © 2019 CMPE137. All rights reserved.
//

import UIKit

extension UIImage {
  
  /**
   Variable to set an image to a safe upload size
   */
  var scaledToSafeUploadSize: UIImage? {
    let maxImageSideLength: CGFloat = 480
    
    let largerSide: CGFloat = max(size.width, size.height)
    let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
    let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)
    
    return image(scaledTo: newImageSize)
  }
  
  /**
   Function for drawing an image
   - Parameter size: The size of the image
   - Returns: The image to draw
   */
  func image(scaledTo size: CGSize) -> UIImage? {
    defer {
      UIGraphicsEndImageContext()
    }
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0)
    draw(in: CGRect(origin: .zero, size: size))

    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
}
