//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Courtney Torres on 8/28/20.
//  Copyright © 2020 Courtney Torres. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {

    var dataController : DataController!
    
    var pin : Pin!
    
    var photoInfo : [PhotoInfo] = []
    var photos : [UIImage] = []
    
    var fetchedResultsController : NSFetchedResultsController<Photo>!
        
    @IBOutlet weak var noImagesLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        FlickrCalls.getPhotoDictionary(latitude: (annotation.coordinate.latitude), longitude: (annotation.coordinate.longitude)) {
            response,error in
            if let response = response {
                self.photoInfo = response.photos.photo
                self.collectionView.reloadData()
                if self.photos.count == 0 {
                    self.noImagesLabel.isHidden = false
                    self.collectionView.isHidden = true
                    
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        collectionView.reloadData()
    }
    
    
    func addPhotos(){
        for photo in photoInfo {
            FlickrCalls.getPhotos(farmId: photo.farm, serverId: photo.server, id: photo.id, secret: photo.secret){
                 image, error in
                 if let image = image {
                    self.photos.append(image)
                 }
                let photo = Photo(context: self.dataController.viewContext)
                photo.photo = image?.pngData()
                do {
                    try self.dataController.viewContext.save()
                } catch {
                    print(error)
                }
                
             }
        }

    }
    

}
extension PhotoAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionView", for: indexPath) as! PhotoCollectionViewCell
//        cell.photo.image = photos[indexPath.row]
        FlickrCalls.getPhotos(farmId: photoInfo[indexPath.row].farm, serverId: photoInfo[indexPath.row].server, id: photoInfo[indexPath.row].id, secret: photoInfo[indexPath.row].secret){
             image, error in
             if let image = image {
                cell.photo.image = image
             }
            let photo = Photo(context: self.dataController.viewContext)
            photo.photo = image?.pngData()
            do {
                try self.dataController.viewContext.save()
            } catch {
                print(error)
            }

        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
}
