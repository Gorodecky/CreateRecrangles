//
//  DrawView.swift
//  CreateRectangles
//
//  Created by Vitaliy on 11.03.2018.
//  Copyright © 2018 Vitaliy. All rights reserved.
//

import UIKit

enum TouchesStyle {
    case createView, moveView
}

class DrawView: UIView {
    //MARK: - Property
    
    var currentColor = UIColor.randomColor()
    var currentView: UIView? = nil
    var touchesStyle: TouchesStyle = .createView
    //MARK: Private property
    
    private var firstTouchLocation = CGPoint.zero
    private var lastTouchLocation = CGPoint.zero
    private var redrawRect = CGRect.zero
    var touchOffset: CGPoint = CGPoint.zero
    
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let point = touch.location(in: self)
            
            if let firstView = self.hitTest(point, with: event) {
                
                if !firstView.isEqual(self) {
                    
                    self.touchesStyle = .moveView
                    
                    self.currentView = firstView
                    
                    self.currentView?.isMultipleTouchEnabled = true
                    
//                    let gesture = UITapGestureRecognizer.init(target: self.currentView, action: #selector(doubleTapGestureRecognizer))
//                    gesture.numberOfTouchesRequired = 2
                    
                    self.bringSubview(toFront: self.currentView!)
                    
                    let touchPoint = touch.location(in: self.currentView)
                    self.touchOffset = CGPoint(x: (self.currentView?.bounds.midX)! - touchPoint.x,
                                               y: (self.currentView?.bounds.midY)! - touchPoint.y)
                    
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        //self.currentView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                        self.currentView?.alpha = 0.3
                    })
                    
                } else {
                    
                    self.touchesStyle = .createView
                    
                    self.currentColor = UIColor.randomColor()
                    
                    self.firstTouchLocation = touch.location(in: self)
                    self.lastTouchLocation = self.firstTouchLocation
                    
                    let view = UIView()
                    view.layer.backgroundColor = UIColor.randomColor().cgColor
                    view.frame = self.currentRect()
                    self.currentView = view
                    
                    self.addSubview(view)
                    
                    let gestureRotate = UIRotationGestureRecognizer.init(target: self, action: #selector(rotationGestureRecognizer(gesture:)))
                    
                    let gesturePinch = UIPinchGestureRecognizer.init(target: self,
                                                                     action: #selector(pinchGesture(gesture:)))
                    let gestureLongPress = UILongPressGestureRecognizer(target: self,
                                                                        action: #selector(longPressGestureRecognize(gesture:)))
                    view.addGestureRecognizer(gestureLongPress)
                    view.addGestureRecognizer(gestureRotate)
                    view.addGestureRecognizer(gesturePinch)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            //let view = self.currentView
            
            let point = touch.location(in: self)
            
            if let firstView = self.hitTest(point, with: event) {
                
                switch touchesStyle {
                    
                case .createView:
                    
                    self.reDrawSelectionArea(fromPoint: self.firstTouchLocation, toPoint: touch.location(in: self))
                    
                    break
                    
                case .moveView:
                    
                    if let moveView = self.currentView {
                        
                        let point = touch.location(in: self)
                        let correctionPoint = CGPoint(x: point.x + self.touchOffset.x,
                                                      y: point.y + self.touchOffset.y)
                        moveView.center = correctionPoint
                    }
                    
                    break
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            self.animationEnd()
            self.currentView = nil
            self.touchesStyle = .createView
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2.0)
        context?.setStrokeColor(currentColor.cgColor)
        context?.setFillColor(currentColor.cgColor)
        context?.addRect(currentRect())
        context?.drawPath(using: .fillStroke)
    }
    
    func currentRect() -> CGRect {
        return CGRect(x: firstTouchLocation.x,
                      y: firstTouchLocation.y,
                      width: lastTouchLocation.x - firstTouchLocation.x,
                      height: lastTouchLocation.y - firstTouchLocation.y)
    }
    
    func reDrawSelectionArea(fromPoint: CGPoint, toPoint: CGPoint) {
        
        //Calculate rect from the original point and last known point
        let view = self.currentView
        
        var width = fabs(fromPoint.x - toPoint.x)
        var height = fabs(fromPoint.x - toPoint.y)
        //
        //        if width < 100 || height < 100 {
        //            width = 100
        //            height = 100
        //        }
        //
        let rect = CGRect(x: min(fromPoint.x, toPoint.x),
                          y: min(fromPoint.y, toPoint.y),
                          width: width,
                          height: height)
        
        view?.frame = rect
    }
    //MARK: - UIGestureRecognizer func
    
    //    @objc func doubleTapGestureRecognizer(gesture: UITapGestureRecognizer) {
    //        print("tap")
    //    }
    
    @objc func longPressGestureRecognize(gesture: UILongPressGestureRecognizer) {
        
        if let view = gesture.view {
            
            self.currentView = view
            
            switch gesture.state {
                
            case .began:
                self.currentView?.layer.backgroundColor = UIColor.randomColor().cgColor
            case .ended:
                self.animationEnd()
            default: break
                
            }
        }
    }
    
    @objc func rotationGestureRecognizer(gesture: UIRotationGestureRecognizer) {
        print("rotation")
        
        if let view = gesture.view {
            
            self.currentView = view
            
            switch gesture.state {
                
            case .changed:
                
                let transform = self.currentView?.transform.rotated(by: gesture.rotation)
                gesture.rotation = 0
                
                self.currentView?.transform = transform!
                
            case .ended:
                self.animationEnd()
            default: break
                
            }
        }
    }
    
    @objc func pinchGesture(gesture: UIPinchGestureRecognizer) {
        print("pinch")
        
        if let view = gesture.view {
            
            switch gesture.state {
                
            case .changed:
                
                self.currentView = view
                let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
                                          y: gesture.location(in: view).y - view.bounds.midY)
                let transform = self.currentView?.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: gesture.scale, y: gesture.scale)
                    .translatedBy(x:  -pinchCenter.x, y: -pinchCenter.y)
                gesture.scale = 1
                
                self.currentView?.transform = transform!
                
            case .ended:
                self.animationEnd()
                
            default: break
                
            }
            
        }
    }
    
    fileprivate func animationEnd() {
        UIView.animate(withDuration: 0.3, animations: {
            
            self.currentView?.alpha = 1.0
        })
    }
    
}
extension UIColor {
    class func randomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
}
