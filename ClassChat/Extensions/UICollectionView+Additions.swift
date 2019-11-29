//
//  UICollectionView+Additions.swift
//  ClassChat
//
//  Created by CMPE137 on 11/18/19.
//  Copyright © 2019 CMPE137. All rights reserved.
//

import UIKit

extension UIScrollView {
  
  /**
   Variable for checking if the Chat view is at the bottom
   */
  var isAtBottom: Bool {
    return contentOffset.y >= verticalOffsetForBottom
  }
  
  /**
   Variable to set the distance from the bottom of the scroll view
   */
  var verticalOffsetForBottom: CGFloat {
    let scrollViewHeight = bounds.height
    let scrollContentSizeHeight = contentSize.height
    let bottomInset = contentInset.bottom
    let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
    return scrollViewBottomOffset
  }
  
}
