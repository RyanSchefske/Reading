//
//  UIView+Ads.swift
//  Reader
//
//  Created by Ryan Schefske on 11/2/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import GoogleMobileAds
import UIKit

extension UIView: GADBannerViewDelegate {
    func addBannerViewToView(_ bannerView: GADBannerView, _ view: UIView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
