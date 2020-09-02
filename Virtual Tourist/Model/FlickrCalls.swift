//
//  FlickrCalls.swift
//  Virtual Tourist
//
//  Created by Courtney Torres on 8/28/20.
//  Copyright © 2020 Courtney Torres. All rights reserved.
//

import Foundation
import UIKit

class FlickrCalls {
    
    static let apiKey = "6cf5ec42f6c09056c3850365c1f84279"
    enum Endpoints {
        case photoDictionary(Double, Double)
        case retrievePhotos(Int,String, String, String)
        
        var stringValue : String{
            switch self {
            case .photoDictionary(let latitude, let longitude):
                return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(latitude)&lon=\(longitude)&format=json"
            case .retrievePhotos(let farmId,let serverId, let id, let secret):
                return "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
                    
            }
        }
        var url : URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest(url:URL,completion: @escaping (Data?, Error?) -> Void){
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request){ (data, response, error) in
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
    }
    
    
    class func getPhotoDictionary(latitude: Double, longitude: Double, completion: @escaping(PhotoDictionaryResponse?, Error?)->Void) {
        taskForGETRequest(url: Endpoints.photoDictionary(latitude, longitude).url) {
            data, error in
            if data != nil {
                let decoder = JSONDecoder()
                do {
                    let range = (14..<data!.count-1)
                    let newData = data!.subdata(in: range)
                    let response = try decoder.decode(PhotoDictionaryResponse.self, from: newData)
                    
                    completion(response, nil)
                } catch  {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func getPhotos(farmId : Int,  serverId: String, id: String, secret: String, completion: @escaping (UIImage?, Error?)->Void) {
        taskForGETRequest(url: Endpoints.retrievePhotos(farmId, serverId, id, secret).url) {
            data, error in
            guard let image = UIImage(data: data!) else {
                completion(nil, error)
                return
            }
            completion(image, nil)
        }
    }
    
    
}
