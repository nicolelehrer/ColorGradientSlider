//
//  CustomSlider.swift
//  CustomControls
//
//  Created by Nicole Lehrer on 11/2/15.
//  Copyright © 2015 Nicole Lehrer. All rights reserved.
//

import UIKit
import QuartzCore

class CustomSlider: UIControl {
    var minimumValue = 0.0
    var maximumValue = 1.0
    let trackLayer = CAGradientLayer()
    let thumbLayer = CustomThumbLayer()
    var previousLocation = CGPoint()
    

    
    var thumbHeight:CGFloat{
        return CGFloat(bounds.height)
    }

    var thumbWidth:CGFloat{
        return thumbHeight/2
    }
    
    

    let mainColorComponents:[CGFloat] = [0.7, 0.2, 0.0, 1.0]
    
    var lowerValue:Double = 0

    
    var startColor:CGColor{
        return UIColor(red: 0, green: mainColorComponents[1], blue: mainColorComponents[2], alpha: 1).CGColor
    }
    var endColor:CGColor{
        return UIColor(red: 1, green: mainColorComponents[1], blue: mainColorComponents[2], alpha: 1).CGColor
    }
    
    

    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        thumbLayer.backgroundColor = UIColor(red: mainColorComponents[0], green: mainColorComponents[1], blue: mainColorComponents[2], alpha: 1).CGColor
        lowerValue = Double(mainColorComponents[0])
        
        trackLayer.startPoint = CGPointMake(0.0, 0.5)
        trackLayer.endPoint = CGPointMake(1.0, 0.5)
        trackLayer.locations = [0.0,1.0]
        trackLayer.colors = [startColor, endColor]
        layer.addSublayer(trackLayer)
        

        updateLayerFrames()
        layer.addSublayer(thumbLayer)

        thumbLayer.customSlider = self
      }
    
    
    func calcComponentDelta(start: UnsafePointer<CGFloat>, end: UnsafePointer<CGFloat>, index:Int)->CGFloat{
        let diff:CGFloat = start[index] - end[index]
        if diff > 0 {
            let factor:CGFloat = 1.0/abs(diff)
            return start[index] - CGFloat(lowerValue)/factor
        }else if diff < 0{
            let factor:CGFloat = 1.0/abs(diff)
            return start[index] + CGFloat(lowerValue)/factor
        }
        return start[index]
    }
    
    func convert(length: Int, data: UnsafePointer<CGFloat>) -> [CGFloat] {
        let buffer = UnsafeBufferPointer(start: data, count: length)
        return Array(buffer)
    }
    
    var thumbColor:CGColor{
        
        let startComponents = convert(5, data: CGColorGetComponents(startColor))
        let endComponents = convert(5, data: CGColorGetComponents(endColor))
        
        print("start is \(startComponents)")
        print("end is \(endComponents)")

//        print(unsafeStartComponents[0])
//        print(unsafeStartComponents[8])
//        print(unsafeStartComponents[16])
        
        let r = calcComponentDelta(startComponents, end:endComponents, index:0)
        let g = calcComponentDelta(startComponents, end:endComponents, index:1)
        let b = calcComponentDelta(startComponents, end:endComponents, index:2)

       
        
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        return color.CGColor

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayerFrames(){
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height/4)
        trackLayer.cornerRadius = trackLayer.frame.height/2
        
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))

        thumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: 0.0,
            width: thumbWidth, height: thumbHeight)
        thumbLayer.cornerRadius = thumbWidth/8
        thumbLayer.setNeedsDisplay()
        
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    override var frame: CGRect{
        didSet {
            updateLayerFrames()
        }
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        if thumbLayer.frame.contains(previousLocation){
            thumbLayer.highlighted = true
        }
        
        return thumbLayer.highlighted
    }
    
    func boundValue(value:Double, toLowerValue lowerValue:Double, upperValue:Double)->Double{
        return min(max(value, lowerValue), upperValue)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        let deltaLocation = Double(location.x-previousLocation.x)
        let deltaValue = (maximumValue-minimumValue)*deltaLocation/Double(bounds.width-thumbWidth)
        
        previousLocation = location
        
        if thumbLayer.highlighted{
            lowerValue += deltaValue
            lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: maximumValue)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateLayerFrames()
        CATransaction.commit()
        
        sendActionsForControlEvents(.ValueChanged)
        thumbLayer.backgroundColor = thumbColor

        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        thumbLayer.highlighted = false
    }
}
