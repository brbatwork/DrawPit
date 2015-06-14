//
//  DropitDynamicBehavior.swift
//  DropIt
//
//  Created by Bill Barbour on 6/12/15.
//  Copyright (c) 2015 SograSoftware LLC. All rights reserved.
//

import UIKit

class DropitDynamicBehavior: UIDynamicBehavior {
    let gravity = UIGravityBehavior()
    
    lazy var dropBehavior: UIDynamicItemBehavior = {
       let lazyCreatedDB = UIDynamicItemBehavior()
        lazyCreatedDB.allowsRotation = false
        lazyCreatedDB.elasticity = 0.75
        return lazyCreatedDB
    }()
    
    lazy var collider: UICollisionBehavior = {
        let lazyCreatedCollider = UICollisionBehavior()
        lazyCreatedCollider.translatesReferenceBoundsIntoBoundary = true
        return lazyCreatedCollider
        }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(dropBehavior)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addDrop(drop: UIView) {
        dynamicAnimator?.referenceView?.addSubview(drop)
        gravity.addItem(drop)
        collider.addItem(drop)
        dropBehavior.addItem(drop)
    }
    
    func removeDrop(drop: UIView) {
        gravity.removeItem(drop)
        collider.removeItem(drop)
        dropBehavior.removeItem(drop)
        drop.removeFromSuperview()
    }
}
