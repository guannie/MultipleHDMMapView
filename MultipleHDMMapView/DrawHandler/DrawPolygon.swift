//
//  DrawPolygon.swift
//  mkmap
//
//  Created by Lee Kuan Xin on 02.10.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import HDMMapCore

class DrawPolygon: UIView {

    // MARK: Varibles
    var dragArea: UIView!
    var dragAreaBounds: CGRect = CGRect.zero
    var isDrawing: Bool!
    var firstPoint: CGPoint = CGPoint.zero
    var mapView: HDMMapView!
    var canvasView = CanvasView(frame: CGRect.zero)
    
    // Accumulate coordinates
    var coordinates = [Any]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    
    func initialize() {
        isDrawing = false
        dragAreaBounds = CGRect(x: 0, y: 0, width: 0, height: 0)
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = false
        backgroundColor = UIColor.clear
        isOpaque = false
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    // Set mapViewInstance from calling class
    func setCurrentMap(mapView :HDMMapView) {
        self.mapView = mapView
    }
}
