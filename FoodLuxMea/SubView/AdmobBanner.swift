//
//  AdmobBanner.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/26.
//

import GoogleMobileAds
import SwiftUI
import UIKit


/// Controller for google admob
struct GADBannerViewController: UIViewControllerRepresentable {
func makeUIViewController(context: Context) -> UIViewController {
    let view = GADBannerView(adSize: kGADAdSizeBanner)
    let viewController = UIViewController()
    view.adUnitID = PrivateData.bannerID
    // ID for testing 
    //view.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    view.rootViewController = viewController
    viewController.view.addSubview(view)
    viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)
    view.load(GADRequest())
    return viewController
}
 
func updateUIViewController(
_ uiViewController: UIViewController,
context: Context) {
    
    }
}
