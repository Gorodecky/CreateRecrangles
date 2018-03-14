//
//  ViewController.swift
//  CreateRectangles
//
//  Created by Vitaliy on 09.03.2018.
//  Copyright © 2018 Vitaliy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    let overlay = UIView()
    var lastPoint: CGPoint? = nil
    
    var arrayViews: [UIView]? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arrayViews = []
        
//        overlay.layer.borderColor = UIColor.black.cgColor
//        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        overlay.isHidden = true
//        self.view.addSubview(overlay)
        // Do any additional setup after loading the view, typically from a nib.
    }

   
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
//            self.createView()
//            lastPoint = touch.location(in: self.view)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(touches.location(in:view))
//        if let touch = touches.first {
//            let currentPoint = touch.location(in: view)
//            reDrawSelectionArea(fromPoint: lastPoint!, toPoint: currentPoint)
//        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reDrawSelectionArea(fromPoint: CGPoint, toPoint: CGPoint) {
        //overlay.isHidden = false
        
        //Calculate rect from the original point and last known point
        let view = self.createView()
        self.view.addSubview(view)
        
        let rect = CGRect(x: min(fromPoint.x, toPoint.x),
                       y: min(fromPoint.y, toPoint.y),
                       width: fabs(fromPoint.x - toPoint.x),
                       height: fabs(fromPoint.y - toPoint.y))
        
       view.frame = rect
    }
    
    func createView() -> UIView{
        let view = UIView()
        let color = self.getRandomColor()
        view.layer.borderColor = color.cgColor
        view.backgroundColor = color
        view.isHidden = false
        return view
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }


}

