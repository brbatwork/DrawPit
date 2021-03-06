//
//  DropItViewController.swift
//  
//
//  Created by Bill Barbour on 6/12/15.
//
//

import UIKit

class DropItViewController: UIViewController, UIDynamicAnimatorDelegate {

    struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let AttachmentPath = "Attach Path"
    }

    var dropsPerRow = 10
    
    let dropItBehavior = DropitDynamicBehavior()
    
    var lastDroppedView: UIView?
    
    var attachment: UIAttachmentBehavior? {
        willSet {
            let path = UIBezierPath()
            gameView.setPath(path, named: PathNames.AttachmentPath)
            animator.removeBehavior(attachment)
        }
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment)
                
                attachment?.action = { [unowned self] in
                    if let attachedView = self.attachment?.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint(self.attachment!.anchorPoint)
                        path.addLineToPoint(attachedView.center)
                        self.gameView.setPath(path, named: PathNames.AttachmentPath)
                    }
                }
            }
        }
    }

    @IBOutlet weak var gameView: BezierPathsView!
    
    @IBAction func drop(sender: UITapGestureRecognizer) {
        drop()
    }
    
    @IBAction func grabDrop(sender: UIPanGestureRecognizer) {
        let gesturePoint = sender.locationInView(gameView)
        
        switch sender.state {
        case .Began:
            if let viewToAttach = lastDroppedView {
                attachment = UIAttachmentBehavior(item: viewToAttach, attachedToAnchor: gesturePoint)
                lastDroppedView = nil
            }
            
        case .Changed:
            attachment?.anchorPoint = gesturePoint
        case .Ended:
            attachment = nil
        default:
            attachment = nil
        }
    }
    
    lazy var animator: UIDynamicAnimator = {
        let lazyCreatedDA = UIDynamicAnimator(referenceView: self.gameView)
        lazyCreatedDA.delegate = self
        return lazyCreatedDA
        }()
    

    
    var dropSize: CGSize {
        let size = gameView.bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    @IBAction func gestureDrop(sender: UITapGestureRecognizer) {
        drop()
    }
    
    func drop() {
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let dropView = UIView(frame: frame)
        lastDroppedView = dropView
        dropView.backgroundColor = UIColor.random
        dropItBehavior.addDrop(dropView)
    }
    
    func removeCompletedRow() {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y:gameView.frame.maxY, width: dropSize.width, height: dropSize.height)
        
        do {
            dropFrame.origin.y -= dropSize.height
            dropFrame.origin.x = 0
            var dropsFound = [UIView]()
            var rowIsComplete = true
        
            for _ in 0 ..< dropsPerRow {
                if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil) {
                    if hitView.superview == gameView {
                        dropsFound.append(hitView)
                    } else {
                        rowIsComplete = false
                    }
                }

                dropFrame.origin.x += dropSize.width
            }

            if rowIsComplete {
                dropsToRemove += dropsFound
            }

        } while dropsToRemove.count == 0 && dropFrame.origin.y > 0

        for drop in dropsToRemove {
            dropItBehavior.removeDrop(drop)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(dropItBehavior)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let barrierSize = dropSize
        let barrierOrigin = CGPoint(x: gameView.bounds.midX - barrierSize.width / 2, y: gameView.bounds.midY - barrierSize.height / 2)
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
        dropItBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
        gameView.setPath(path, named: PathNames.MiddleBarrier)
    }
    
    // MARK UIDynamicAnimator delegate methods
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
}

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

private extension UIColor {
    class var random: UIColor {
        switch arc4random() % 5 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        default: return UIColor.blackColor()
        }
    }
}