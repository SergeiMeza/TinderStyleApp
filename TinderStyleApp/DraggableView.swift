//
//  DraggableView.swift
//  TinderStyleApp
//
//  Created by kiiita on 2014/09/01.
//  Copyright (c) 2014年 kiiita. All rights reserved.
//

import Foundation
let ACTION_MARGIN  = 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
let SCALE_STRENGTH  = 4 //%%% how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX = 93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX = 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH = 320 //%%% strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE  = M_PI/8 //%%% Higher = stronger rotation angle

class DraggableViewDelegate :NSObject{
    func cardSwipeLeft(card: UIView) {}
    func cardSwipeRight(card: UIView) {}
}

class DraggableView: UIView {
    
    weak var delegate: AnyObject?
    var information: UILabel = UILabel()
    var overlayView: OverlayView?
    var panGestureRecognizer: UIPanGestureRecognizer?
    var originalPoint: CGPoint = CGPoint()
    
    var xFromCenter: CGFloat = CGFloat()
    var yFromCenter: CGFloat = CGFloat()
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        information = UILabel(frame:CGRectMake(0, 50, self.frame.size.width, 100))
        information.text = "no info given"
        information.textAlignment = NSTextAlignment.Center
        information.textColor = UIColor.blackColor()
        
        self.backgroundColor = UIColor.whiteColor()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("beingDragged"))
        self.addGestureRecognizer(panGestureRecognizer!)
        self.addSubview(information)
        
        overlayView = OverlayView(frame: CGRectMake(self.frame.size.width/2-100, 0, 100, 100))
        overlayView!.alpha = 0
        self.addSubview(overlayView!)
        
    }
    
    func setupView() {
        self.layer.cornerRadius = 4
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSizeMake(1, 1)
    }
    
    func beingDragged(gestureRecognizer: UIPanGestureRecognizer) {
        var xFromCenter = gestureRecognizer.translationInView(self).x
        var yFromCenter = gestureRecognizer.translationInView(self).y
        
        switch (gestureRecognizer.state) {
        case UIGestureRecognizerState.Began:
            self.originalPoint = self.center;
            break;
        case UIGestureRecognizerState.Changed:
        var rotationStrength: CGFloat = min(xFromCenter / CGFloat(ROTATION_STRENGTH), CGFloat(ROTATION_MAX))
        var rotationAngel: CGFloat = CGFloat(ROTATION_ANGLE) * rotationStrength
        var scale: CGFloat = max(1 - CGFloat(fabsf(Float(rotationStrength))) / CGFloat(SCALE_STRENGTH), CGFloat(SCALE_MAX))
        self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter)
        var transform: CGAffineTransform = CGAffineTransformMakeRotation(rotationAngel)
        var scaleTransform: CGAffineTransform = CGAffineTransformScale(transform, scale, scale)
            self.transform = scaleTransform
            self.updateOverlay(xFromCenter)
            break
            
        case UIGestureRecognizerState.Ended:
            self.afterSwipeAction()
            break
        case UIGestureRecognizerState.Possible:
            break
        case UIGestureRecognizerState.Cancelled:
            break
        case UIGestureRecognizerState.Failed:
            break
        }
    }
    
    func updateOverlay(distance: CGFloat) {
        if distance > 0 {
            overlayView!.mode = GGOverlayViewMode.Right
        } else {
            overlayView!.mode = GGOverlayViewMode.Left
        }
        
        overlayView!.alpha = min(CGFloat(fabsf(Float(distance))/100), 0.4)
    }
    
    func afterSwipeAction() {
        if xFromCenter > CGFloat(ACTION_MARGIN) {
            self.rightAction()
        } else if xFromCenter > CGFloat(-ACTION_MARGIN) {
            self.leftAction()
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.center = self.originalPoint
                self.transform = CGAffineTransformMakeRotation(0)
                self.overlayView!.alpha = 0
            })
        }
    
    }
    
    func rightAction() {
        var finishPoint: CGPoint = CGPointMake(500, 2*yFromCenter + self.originalPoint.y)
        UIView.animateWithDuration(0.3, animations: {
            self.center = finishPoint
            }, completion: { (complete: Bool) in
                self.removeFromSuperview()
        })
        delegate?.cardSwipedRight(self)
        NSLog("YES")
    }
    
    func leftAction() {
        var finishPoint: CGPoint = CGPointMake(-500, 2*yFromCenter + self.originalPoint.y)
        UIView.animateWithDuration(0.3, animations: {
            self.center = finishPoint
            }, completion: { (complete: Bool) in
                self.removeFromSuperview()
        })
        delegate?.cardSwipeLeft(self)
        NSLog("NO")
    }
    
    func rightClickAction() {
        var finishPoint: CGPoint = CGPointMake(600, self.center.y)
        UIView.animateWithDuration(0.3, animations: {
            self.center = finishPoint
            self.transform = CGAffineTransformMakeRotation(1)
            }, completion: { (complete: Bool) in
                self.removeFromSuperview()
        })
        delegate?.cardSwipedRight(self)
        NSLog("YES")
    }
    func leftClickAction() {
        var finishPoint: CGPoint = CGPointMake(-600, self.center.y)
        UIView.animateWithDuration(0.3, animations: {
            self.center = finishPoint
            self.transform = CGAffineTransformMakeRotation(-1)
            }, completion: { (complete: Bool) in
                self.removeFromSuperview()
        })
        delegate?.cardSwipedRight(self)
        NSLog("NO")
    }
    
}