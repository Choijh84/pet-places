//
//  StoreGoogleMapTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 12..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import GoogleMaps

class StoreGoogleMapTableViewCell: UITableViewCell, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
    }
    
    /**
     Prepares for reusing the cell, removing all annotations
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        mapView.clear()
    }

    /**
     Set the separator to be full width as frame changes
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets.zero
    }
    
    /**
     Adds the store's location to the map and zooms to that location
     
     - parameter storeObject: store object to use
     */
    func zoomMapToStoreLocation(_ store: Store) {
        
        let lat = store.location?.latitude as! Double
        let long = store.location?.longitude as! Double
        let storeLocation = CLLocationCoordinate2DMake(lat, long)
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude:long, zoom:13)
        mapView?.animate(to: camera)
        
        let marker = GMSMarker(position: storeLocation)
        marker.title = store.name
        marker.icon = UIImage(named: "pin")
        marker.map = mapView        
    }
}
