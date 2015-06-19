//
//  BezierPathsView.swift
//  DropIt
//
//  Created by Bill Barbour on 6/19/15.
//  Copyright (c) 2015 SograSoftware LLC. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {

    private var bezierPaths = [String: UIBezierPath]()
    
    func setPath(path: UIBezierPath, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }

}
