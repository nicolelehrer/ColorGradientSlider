//
//  CustomSlider.swift
//  CustomControls
//
//  Created by Nicole Lehrer on 11/2/15.
//  Copyright © 2015 Nicole Lehrer. All rights reserved.
//

//custom control base from ray wenderlich demo on using CA
//added color gradient and updated thumb color
//could this be done by simply modifying track layer of uikit slider hmm

import UIKit
import QuartzCore

protocol CustomSliderDelegate{
    func update(fromComponent:Int, color:CGColor)
}

class CustomSlider: UIControl {
    var minimumValue = 0.0
    var maximumValue = 1.0
    let trackLayer = CAGradientLayer()
    let thumbLayer = CustomThumbLayer()
    var previousLocation = CGPoint()
    var sliderValue:Double = 0
    var componentID:Int
    var delegate:CustomSliderDelegate?

    var mainColorComponents:[CGFloat] = [0.7, 0.2, 0.0, 1.0]{
        didSet{
            print("main color was set")
            trackLayer.colors = [startColor, endColor]
            thumbLayer.backgroundColor = UIColor(red: mainColorComponents[0], green: mainColorComponents[1], blue: mainColorComponents[2], alpha: 1.0).CGColor

        }
    }

    
    
    var thumbHeight:CGFloat{
        return CGFloat(bounds.height)
    }

    var thumbWidth:CGFloat{
        return thumbHeight/2
    }
    var startColor:CGColor{
        var modifiedComponents = mainColorComponents
        modifiedComponents.replaceRange(componentID...componentID, with: [CGFloat(0)])
        return UIColor(red: modifiedComponents[0], green: modifiedComponents[1], blue: modifiedComponents[2], alpha: 1).CGColor
    }
    var endColor:CGColor{
        var modifiedComponents = mainColorComponents
        modifiedComponents.replaceRange(componentID...componentID, with: [CGFloat(1)])
        return UIColor(red: modifiedComponents[0], green: modifiedComponents[1], blue: modifiedComponents[2], alpha: 1).CGColor
    }
    
  
    init(frame: CGRect, componentID:Int, delegate:CustomSliderDelegate?) {
        self.componentID = componentID
        self.delegate = delegate
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.delegate = nil
        self.componentID = 0
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    convenience init() {
        self.init(frame: CGRectZero, componentID:0, delegate:nil)
        self.initialize()
    }
    
    func initialize() {
        thumbLayer.backgroundColor = UIColor(red: mainColorComponents[0], green: mainColorComponents[1], blue: mainColorComponents[2], alpha: 1).CGColor
        sliderValue = Double(mainColorComponents[componentID])
        trackLayer.startPoint = CGPointMake(0.0, 0.5)
        trackLayer.endPoint = CGPointMake(1.0, 0.5)
        trackLayer.locations = [0.0,1.0]
        trackLayer.colors = [startColor, endColor]
        layer.addSublayer(trackLayer)
        updateLayerFrames()
        layer.addSublayer(thumbLayer)
        thumbLayer.customSlider = self
        NSLog("common init")
    }
    
    func calcComponentDelta(start: UnsafePointer<CGFloat>, end: UnsafePointer<CGFloat>, index:Int)->CGFloat{
        let diff:CGFloat = start[index] - end[index]
        if diff > 0 {
            let factor:CGFloat = 1.0/abs(diff)
            return start[index] - CGFloat(sliderValue)/factor
        }else if diff < 0{
            let factor:CGFloat = 1.0/abs(diff)
            return start[index] + CGFloat(sliderValue)/factor
        }
        return start[index]
    }

    
    var thumbColor:CGColor{

        let start = startColor.getComponents()
        let end =  endColor.getComponents()
        
        let r = calcComponentDelta(start, end:end, index:0)
        let g = calcComponentDelta(start, end:end, index:1)
        let b = calcComponentDelta(start, end:end, index:2)
        
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        return color.CGColor
    }
    
    
    
    
    func updateLayerFrames(){
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height/4)
        trackLayer.cornerRadius = trackLayer.frame.height/2
        
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(sliderValue))

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
    
    func boundValue(value:Double, tosliderValue sliderValue:Double, upperValue:Double)->Double{
        return min(max(value, sliderValue), upperValue)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        let deltaLocation = Double(location.x-previousLocation.x)
        let deltaValue = (maximumValue-minimumValue)*deltaLocation/Double(bounds.width-thumbWidth)
        
        previousLocation = location
        
        if thumbLayer.highlighted{
            sliderValue += deltaValue
            sliderValue = boundValue(sliderValue, tosliderValue: minimumValue, upperValue: maximumValue)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateLayerFrames()
        CATransaction.commit()
        
        sendActionsForControlEvents(.ValueChanged)
        thumbLayer.backgroundColor = thumbColor
        delegate?.update(componentID, color:thumbColor)
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        thumbLayer.highlighted = false
    }
}
