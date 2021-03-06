//
//  MHCardViewController.swift
//  DinnerRoll
//
//  Created by Michael Hulet on 7/25/17.
//  Copyright © 2017 Michael Hulet. All rights reserved.
//

import UIKit
import MapKit
import Contacts
import MultiSelectSegmentedControl

class MHCardViewController: UIViewController, SearchFilterProviding, UIGestureRecognizerDelegate{
    var openNow: Bool{
        get{
            return openNowSwitch.isOn
        }
    }
    var prices: IndexSet{
        get{
            return IndexSet(pricingSegments.selectedSegmentIndexes.map({ (index: Int) -> Int in
                return index + 1
            }))
        }
    }
    var categories: [Category]{
        get{
            var types = [Category]()
            for tag in filterView.tagView.tagViews.compactMap({ tag in return tag as? MHCategoryTag }) {
                types.append(tag.category)
            }
            return types
        }
    }
    var filters: [String]{
        get{
            var searches = [String]()
            for tag in filterView.tagView.tagViews where !(tag is MHCategoryTag){
                guard let text = tag.currentTitle else{
                    continue
                }
                searches.append(text)
            }
            return searches
        }
    }

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var filterView: MHFilterView!
    @IBOutlet var openNowSwitch: UISwitch!
    @IBOutlet var pricingSegments: MultiSelectSegmentedControl!
    @IBOutlet weak var optionButtonsView: UIStackView!
    @IBOutlet weak var rollButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var safeAreaSizingViewHeight: NSLayoutConstraint!
    var currentRestaurantSelection: Restaurant? = nil{
        didSet{
            directionsButton.isHidden = currentRestaurantSelection == nil
            rollButton.setTitle(NSLocalizedString("Roll Again", comment: "Prompts the user to ask the app to choose another restaurant after it has already done so once"), for: .normal)
        }
    }
    var closedVisibileHeight: CGFloat{
        get{
            return separatorView.frame.origin.y
        }
    }

    @discardableResult override func resignFirstResponder() -> Bool{
        super.resignFirstResponder()
        return filterView.searchBar.resignFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) -> Void{
        super.viewWillAppear(animated)
        guard let recognizers = view.superview?.gestureRecognizers else{
            return
        }
        for tap in recognizers where tap is UITapGestureRecognizer{
            tap.delegate = self
        }
        for index in 1...(pricingSegments.numberOfSegments > 0 ? pricingSegments.numberOfSegments : 4){
            if index < pricingSegments.numberOfSegments {
                pricingSegments.setTitle(Locale.preferredAgnosticCurrencySymbol * index, forSegmentAt: index - 1)
            }
            else{
                pricingSegments.items.append(Locale.preferredAgnosticCurrencySymbol * index)
            }
        }
    }

    override func viewWillLayoutSubviews() -> Void{
        if #available(iOS 11, *){
            let bottomPadding: CGFloat = 8
            safeAreaSizingViewHeight.constant = (.maximum(parent?.view.safeAreaInsets.bottom ?? bottomPadding, bottomPadding)) - bottomPadding
        }
        super.viewWillLayoutSubviews()
    }

    override func viewDidLoad() -> Void{
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(configureForRestaurantTransition), name: .didBeginRestaurantUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayRestaurantUpdate(from:)), name: .didUpdateRestaurant, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayRestaurantUpdate(from:)), name: .didFailRestaurantUpdate, object: nil)
    }

    @objc func configureForRestaurantTransition() -> Void{
        resignFirstResponder()
        optionButtonsView.isHidden = true
        spinner.startAnimating()
    }

    @objc func displayRestaurantUpdate(from notification: Notification) -> Void{
        spinner.stopAnimating()
        currentRestaurantSelection = notification.object as? Restaurant
        optionButtonsView.isHidden = false
    }

    func gestureRecognizer(_ gesture: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        guard !touch.isIn(view: pricingSegments) else{
            return false
        }
        for tag in filterView.tagView.tagViews{
            if touch.isIn(view: tag){
                return false
            }
        }
        return true
    }

    @IBAction func rollAgain() -> Void{
        NotificationCenter.default.post(name: .shouldRollAgain, object: nil)
    }
    
    @IBAction func getDirectionsToCurrentRestaurant() -> Void{
        guard let restaurant = currentRestaurantSelection else{
            return
        }
        let item = MKMapItem(placemark: MKPlacemark(coordinate: restaurant.coordinate, addressDictionary: [CNPostalAddressStreetKey: restaurant.address as Any, CNPostalAddressCityKey: restaurant.city as Any, CNPostalAddressStateKey: restaurant.state as Any, CNPostalAddressPostalCodeKey: restaurant.postalCode as Any, CNPostalAddressCountryKey: restaurant.country as Any]))
        item.name = restaurant.name
        var launchOptions = [String: Any]()
        if #available(iOS 10, *){
            launchOptions[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDefault
        }
        else{
            launchOptions[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDriving
        }
        MKMapItem.openMaps(with: [item], launchOptions:launchOptions)
    }
}

extension UITouch{
    func isIn(view: UIView) -> Bool{
        return view.bounds.contains(location(in: view))
    }
}
