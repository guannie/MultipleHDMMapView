//
//  CanvasView.swift
//  mkmap
//
//  Created by Lee Kuan Xin on 26.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//
//  A view to render touch feedback

import UIKit


class CanvasView: UIImageView {
    
    // MARK: Properties for drawing
    var firstPoint: CGPoint!
    var pointWidth: CGFloat = 3.0
    var pointType: CGLineCap = .round
    var pointColor: CGColor = UIColor.blue.withAlphaComponent(0.7).cgColor
    var bgcColor: UIColor = UIColor.black.withAlphaComponent(0.3)
    var isDrawing: Bool = false
    var coordinates = [Any]()
    
    // Image Settings
    var pointerImage: UIImage = #imageLiteral(resourceName: "point")
    
    var shouldSetupContraints = true
    let screenSize = UIScreen.main.bounds
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = bgcColor
        self.isUserInteractionEnabled = false
        //setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        if(shouldSetupContraints) {
            shouldSetupContraints = false
        }
        super.updateConstraints()
    }
    
    // MARK: Override touch gesture
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Test for touch gesture
        if let touch = touches.first {
            //allocate firstPoint
            firstPoint = touch.location(in: self)
            // tester code
            //print("Starting \(firstPoint)" )
            coordinates.removeAll()

        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            drawLineFrom(fromPoint: firstPoint, toPoint: currentPoint)
            // tester code
            //print("Moving: last: \(firstPoint) now: \(currentPoint)" )
            // assign the current point as first point
            firstPoint = currentPoint
            coordinates.append(touches.first!)
        }

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
        if !isDrawing {
            let currentPoint = touch.location(in: self)
            drawLineFrom(fromPoint: currentPoint , toPoint: currentPoint)
            //print("Ended")
        }
            firstPoint = nil
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("cancelled")
    }
    
    // MARK: ExtraFunction
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        //print("drawing...")
        UIGraphicsBeginImageContext(self.frame.size)
        let ctx = UIGraphicsGetCurrentContext()
        self.draw(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        ctx?.setLineCap(pointType)
        ctx?.setLineWidth(pointWidth)
        ctx?.setStrokeColor(pointColor)
        ctx?.beginPath()
        ctx?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        ctx?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        ctx?.strokePath()
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        self.alpha = 1.0
        UIGraphicsEndImageContext()
    }
    
    func createPointer(on origin: CGPoint) -> UIImageView{
        let pointer:UIImageView = UIImageView(image: pointerImage)
        pointer.frame = CGRect(x: origin.x-5, y: origin.y-5, width: 10, height: 10)
        return pointer
    }
    
    func clear(){
        self.removeFromSuperview()
        self.image = nil
        self.setNeedsDisplay()
    }

}
