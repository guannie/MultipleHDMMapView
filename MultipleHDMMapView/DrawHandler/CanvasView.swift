//
//  CanvasView.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 21.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit

class CanvasView: UIView {

    weak var delegate:NotifyTouchEvents?
    var lastPoint = CGPoint.zero
    var isDrawing = false
    let brushWidth:CGFloat = 3.0
    let opacity :CGFloat = 1.0

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if let touch = touches.first {
            
            self.delegate?.touchBegan(touch: touch)
            lastPoint = touch.location(in: self)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first  {
            
            self.delegate?.touchMoved(touch: touch)
            let currentPoint = touch.location(in: self)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first  {
            
            self.delegate?.touchEnded(touch: touch)
            
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()
        self.draw(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        
        context?.setLineCap(.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setBlendMode(.normal)
        context?.strokePath()
        
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
