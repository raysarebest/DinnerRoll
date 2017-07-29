//
//  MHCoordinatingViewController.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/25/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import CoreLocation
import QuadratTouch
import QuartzCore

protocol SearchAreaProviding{
    var searchCenter: CLLocationCoordinate2D? { get }
    var searchRadius: CLLocationDistance? { get }
}

class MHCoordinatingViewController: MHMainViewController{

    //MARK: - Subviews

    @IBOutlet weak var statusBarBackground: UIVisualEffectView!
    @IBOutlet weak var cardContainerView: MHCardView!

    //MARK: - Child View Controllers

    var searchAreaProvider: SearchAreaProviding{
        get{
            return childViewControllers.first(where: { (controller: UIViewController) -> Bool in
                let test = controller as? SearchAreaProviding
                return test != nil
            }) as! SearchAreaProviding
        }
    }
    weak var mapController: MHMapViewController!{
        get{
            return child(type: MHMapViewController.self)
        }
    }
    private func child<Controller: UIViewController>(type: Controller.Type) -> Controller{
        return childViewControllers.first{(controller: UIViewController) -> Bool in
            return controller.isKind(of: type)
        } as! Controller
    }

    //MARK: - View Controller Lifecycle

    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        cardContainerView.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height - 100), size: view.frame.size)
        //Idk why you can't set a drop shadow as an Interface Builder runtime attribute
        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowRadius = 3
        cardContainerView.layer.shadowOpacity = 1
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        statusBarBackground.frame = UIApplication.shared.statusBarFrame
    }
}