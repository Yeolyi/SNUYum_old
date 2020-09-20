//
//  NaverMapView.swift
//  FoodLuxMea
//
//  Created by Seong Yeol Yi on 2020/08/24.
//

import SwiftUI
import NMapsMap
import CoreLocation

var locationManager = CLLocationManager()

/// Map view element; shows cafe location using Naver map API.
struct NaverMapProvider: UIViewRepresentable {
  ///Camera&marker position
  let coord: NMGLatLng
  ///Camera zoom
  let zoomValue: Double = 16
  
  init(cafeName: String) {
    if let cafeCoord = coordList[cafeName] {
      self.coord = .init(lat: cafeCoord.lat, lng: cafeCoord.lng)
    } else {
      assertionFailure("NaverMap/init: \(cafeName)의 좌표값이 없습니다")
      self.coord = .init(lat: 37, lng: 132)
    }
  }
  
  func makeUIView(context: UIViewRepresentableContext<NaverMapProvider>) -> NMFNaverMapView {
    let mapView: NMFNaverMapView = .init()
    locationManager.requestWhenInUseAuthorization()
    
    mapView.showScaleBar = false
    mapView.showLocationButton = true
    mapView.showZoomControls = true
    mapView.showCompass = true
    
    let marker = NMFMarker()
    marker.position = coord
    marker.mapView = mapView.mapView
    
    let cameraPosition = NMFCameraPosition(coord, zoom: zoomValue)
    let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
    mapView.mapView.moveCamera(cameraUpdate)
    
    return mapView
  }
  
  func updateUIView(_ uiView: NMFNaverMapView, context: UIViewRepresentableContext<NaverMapProvider>) {
    
  }
}
