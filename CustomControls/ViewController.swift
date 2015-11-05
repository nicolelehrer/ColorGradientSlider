//
//  ViewController.swift
//  CustomControls
//
//  Created by Nicole Lehrer on 11/2/15.
//  Copyright © 2015 Nicole Lehrer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let customSlider = CustomSlider(frame:CGRectZero, componentID:0)
    let customSlider1 = CustomSlider(frame:CGRectZero, componentID:1)
    let customSlider2 = CustomSlider(frame:CGRectZero, componentID:2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(customSlider)
        view.addSubview(customSlider1)
        view.addSubview(customSlider2)

        customSlider.addTarget(self, action: "customSliderValueChanged:", forControlEvents: .ValueChanged)

    }
    
    func customSliderValueChanged(slider: CustomSlider) {
//        print("Range slider value changed: \(slider.slideValue)")
    }

    override func viewDidLayoutSubviews() {
        let margin:CGFloat = 20.0
        let width = view.bounds.width - 2*margin
        customSlider.frame = CGRect(x: margin, y: margin+topLayoutGuide.length, width: width, height: 50.0)
        
        customSlider1.frame = CGRect(x: margin, y: margin+topLayoutGuide.length + 100, width: width, height: 50.0)
        
        customSlider2.frame = CGRect(x: margin, y: margin+topLayoutGuide.length + 200, width: width, height: 50.0)

    }

}

