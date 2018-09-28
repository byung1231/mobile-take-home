//
//  LayoutConstraints.swift
//  GuestlogixTest
//
//  Created by Byung Yoo on 2018-09-28.
//  Copyright © 2018 Theta Labs Inc. All rights reserved.
//

import Foundation
import UIKit

// contains the layout constraints part only

extension ViewController{
    
    // adding layouts some of the constraints that are better done programatically
    override func viewDidLayoutSubviews() {
        
        var layoutConstraints = [NSLayoutConstraint]()
        var screenHeight = view.bounds.size.height
        let widthFactor : CGFloat = 0.9 //width of mapView with respect to the view
        
        
        // layout spacings relative to height of the screen
        
        // top constraint for txtOrigin relative to the screen height
        let txtOriginTopConstraint = NSLayoutConstraint(item: txtOrigin, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: screenHeight * 0.06)
        
        layoutConstraints.append(txtOriginTopConstraint)
        
        
        // center Y constraint for lblOrigin relative to txtOrigin
        let lblOriginCenterYConstraint = NSLayoutConstraint(item: lblOrigin, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: txtOrigin, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        layoutConstraints.append(lblOriginCenterYConstraint)
        
        // top constraint for txtDestination relative to the screen height
        let txtDestinationTopConstraint = NSLayoutConstraint(item: txtDestination, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: screenHeight * 0.15)
        layoutConstraints.append(txtDestinationTopConstraint)
        
        // center Y constraint for lblDestination relative to txtDestination
        let lblDestinationCenterYConstraint = NSLayoutConstraint(item: lblDestination, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: txtDestination, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        layoutConstraints.append(lblDestinationCenterYConstraint)
        
        // top constraint for btnGo relative to the screen height
        let btnGoTopConstraint = NSLayoutConstraint(item: btnGo, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: screenHeight * 0.23)
        layoutConstraints.append(btnGoTopConstraint)
        
        // top constraint for lblRouteHeight relative to the screen height
        let lblRouteTitleTopConstraint = NSLayoutConstraint(item: lblRouteTitle, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: screenHeight * 0.32)
        layoutConstraints.append(lblRouteTitleTopConstraint)
        
        // top constraint for lblRoute relative to the screen height
        let lblRouteTopConstraint = NSLayoutConstraint(item: lblRoute, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: screenHeight * 0.39)
        layoutConstraints.append(lblRouteTopConstraint)
        
        
        // --------------------- constraints for the mapView ---------------------
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let mapViewCenterXConstraint = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        
        layoutConstraints.append(mapViewCenterXConstraint)
        
        
        let mapViewWidthConstraint = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.width, multiplier: widthFactor, constant: 0)
        
        layoutConstraints.append(mapViewWidthConstraint)
        
        
        let mapViewHeightConstraint = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 0.5, constant: 0)
        layoutConstraints.append(mapViewHeightConstraint)
        
        
        // to keep the bottom margin of the mapview the same as side margins
        let mapViewBottomConstraint = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom,  multiplier: 1, constant: -(view.bounds.size.width * (1 - widthFactor) / 2))
        layoutConstraints.append(mapViewBottomConstraint)
        
        // --------------------- end of constraints for mapView ---------------------
        
        
        
        // adjusting the labels / textfields
        
        // basing on lblDestination for safety as it is the longest string
        // (and because the width constraints are set based on this label, all others will be guaranteed not to go out of the screen)
        
        lblDestination.adjustsFontSizeToFitWidth = true
        lblDestination.font = UIFont.systemFont(ofSize: (lblDestination.frame.size.height * 0.65))
        
        lblOrigin.font = lblDestination.font
        btnGo.titleLabel?.font  = lblDestination.font
        lblRouteTitle.font = lblDestination.font
        lblRoute.font = lblDestination.font
        txtOrigin.font = lblDestination.font
        txtDestination.font = lblDestination.font
        
        // disabling auto corrections for the inputs as the IATAs are often mistaken for other words and auto corrected
        txtOrigin.autocorrectionType = UITextAutocorrectionType.no
        txtDestination.autocorrectionType = UITextAutocorrectionType.no
        
        
        // just to ensure the route label does not go over the screen width
        // as it could be longer then lblDestination
        lblRoute.adjustsFontSizeToFitWidth = true
        
        
        // aligining trailing lblOrigin to lblDestination again since the font size may have changed from the above
        let lblOriginTrailingConstraint = NSLayoutConstraint(item: lblOrigin, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: lblDestination, attribute: NSLayoutAttribute.trailing,  multiplier: 1, constant: 0)
        
        layoutConstraints.append(lblOriginTrailingConstraint)
        
        view.addConstraints(layoutConstraints)
        
        
        
    }
    
}
