//
// TravelLocationsViewController.swift
//  Virtual Tourist
//
//  Created by Courtney Torres on 8/24/20.
//  Copyright © 2020 Courtney Torres. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class TravelLocationsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController : DataController!
    
    var fetchResultsController : NSFetchedResultsController<Pin>!
    
    var pins : [Pin]!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addPinPoint))
        mapView.addGestureRecognizer(tapGesture)
        setupFetchResultsController()
        configureMapWithPins()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultsController = nil
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMap()
    }
    
    fileprivate func setupMap() {
        if let location = UserDefaults.standard.dictionary(forKey: "Location"){
            mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location["Latitude"]! as! CLLocationDegrees, longitude: location["Longitude"]! as! CLLocationDegrees), span: MKCoordinateSpan(latitudeDelta: location["Latitude Delta"]! as! CLLocationDegrees, longitudeDelta: location["Longitude Delta"] as! CLLocationDegrees)), animated: true)
        }
    }
    
    fileprivate func setupFetchResultsController() {
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin")
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch  {
            fatalError("The fetch could not be performed \(error.localizedDescription)")
        }
    }
    
    fileprivate func configureMapWithPins() {
        pins = fetchResultsController.fetchedObjects!
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    
    @objc func addPinPoint(gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let center = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        mapView.addAnnotation(annotation)
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        do {
            try dataController.viewContext.save()
        } catch  {
            print(error)
        }
    }
    
}

extension TravelLocationsViewController : MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let location = ["Latitude":mapView.region.center.latitude, "Longitude": mapView.region.center.longitude,"Latitude Delta" : mapView.region.span.latitudeDelta, "Longitude Delta": mapView.region.span.longitudeDelta]
        UserDefaults.standard.set(location, forKey: "Location")
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumVC") as! PhotoAlbumViewController
        vc.dataController = dataController
        for pin in pins {
            if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude{
                vc.pin = pin
                mapView.deselectAnnotation(view.annotation, animated: true)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
        navigationController?.isNavigationBarHidden = false
        
    }
}

extension TravelLocationsViewController : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            pins = controller.fetchedObjects as? [Pin]
        default:
            break
        }
    }
}



