//
//  CGColorExtension.swift
//  CustomControls
//
//  Created by Nicole Lehrer on 11/5/15.
//  Copyright © 2015 Nicole Lehrer. All rights reserved.
//

import UIKit

extension CGColor{
    
    func getComponents()->[CGFloat]{
        let unsafeComponents = CGColorGetComponents(self)
        let buffer = UnsafeBufferPointer(start: unsafeComponents, count: 5) //assumes in rgb space = 4 + 1 for additional param
        return Array(buffer)
    }

}
