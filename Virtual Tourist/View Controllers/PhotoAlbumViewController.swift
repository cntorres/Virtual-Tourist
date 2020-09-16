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

class PhotoAlbumViewController: UIViewController {

    var dataController : DataController!
    
    var pin : Pin!
    
    var photoInfo : [PhotoInfo] = []
    var photos : [UIImage] = []
    
    var fetchedResultsController : NSFetchedResultsController<Photo>!
        
    @IBOutlet weak var noImagesLabel: UILabel!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    
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
        if photos.count == 0 {
            FlickrCalls.getPhotoDictionary(latitude: (annotation.coordinate.latitude), longitude: (annotation.coordinate.longitude)) {
                response,error in
                if let response = response {
                    self.photoInfo = response.photos.photo
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    self.addPhotos()
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
        fetchedImages()
    }
    
    func fetchedImages() {
        for photo in fetchedResultsController.fetchedObjects!{
            photos.append(UIImage(data: photo.photo!)!)
        }
        displayCollectionView()
    }
    
    @IBAction func getNewCollection(_ sender: Any) {
        for photo in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(photo)
            do{
                try dataController.viewContext.save()
            } catch {
                print(error)
            }
        }
        photos = []
        collectionView.reloadData()
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
        FlickrCalls.getPhotoDictionary(latitude: (annotation.coordinate.latitude), longitude: (annotation.coordinate.longitude)) {
            response,error in
            if let response = response {
                self.photoInfo = response.photos.photo
                self.addPhotos()
            }
        }
    }
    
    func displayCollectionView(){
        if photos != nil || photos.count != 0 {
            collectionView.reloadData()
            newCollectionButton.isEnabled = true
        }else {
            #warning("Fix showing no Image label")
//            collectionView.isHidden = true
//            noImagesLabel.isHidden = false
        }
    }
    func addPhotos(){
        DispatchQueue.global(qos: .userInitiated).async {
            let group = DispatchGroup()
            for photo in self.photoInfo {
                group.enter()
                FlickrCalls.getPhotos(farmId: photo.farm, serverId: photo.server, id: photo.id, secret: photo.secret){
                     image, error in
                    if let image = image?.pngData() {
                        let photo = Photo(context: self.dataController.viewContext)
                        photo.photo = image
                        photo.pin = self.pin
                        do {
                            try self.dataController.viewContext.save()
                        } catch {
                            print(error)
                        }
                    }
                    group.leave()
                }
            }
            group.wait()
            DispatchQueue.main.async {
                self.displayCollectionView()
            }
        }
    }
}

extension PhotoAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionView", for: indexPath) as! PhotoCollectionViewCell
        if photos.count == 0 {
            cell.photo.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.196139283)
            cell.photo.image = UIImage()
        } else {
            cell.photo.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.photo.image = photos[indexPath.row]
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photos.count == 0 {
            return photoInfo.count
        }
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photos.remove(at: indexPath.row)
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        collectionView.reloadData()
    }
    
}

extension PhotoAlbumViewController : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            photos.append(UIImage(data: (anObject as AnyObject).photo!)!)
        default:
            break
        }
    }
}
