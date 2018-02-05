//
//  FIRStorageCache.swift
//  ABC Events
//
//  Created by Ant on 28/12/2016.
//  Copyright © 2016 Apptitude. All rights reserved.
//

import Foundation
import FirebaseStorage
import RxSwift


public class FirebaseStorageCache {
    
    fileprivate let cache: Cache
    
    init(cache: Cache) {
        self.cache = cache
    }
    
    public func get(storageReference: StorageReference, completion: @escaping (_ object: Data?) -> Void) -> Observable<Data?> {
        
        return Observable.create { observer in
            let filePath = self.filePath(storageReference: storageReference)
            
            self.cache.get(key: filePath, completion: { object in
                if let object = object {
                    // Cache hit
                    DispatchQueue.main.async(execute: {
                        observer.onNext(object)
                    })
                    return
                }
                // Cache miss: download file
                storageReference.downloadURL(completion: { (url, error) in
                    guard error == nil else {
                        observer.onError(error!)
                        print(error!.localizedDescription)
                        DispatchQueue.main.async(execute: {
                            observer.onNext(nil)
                        })
                        return
                    }
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        guard let httpURLResponse = response as? HTTPURLResponse,
                            httpURLResponse.statusCode == 200,
                            let data = data, error == nil else {
                                print(error?.localizedDescription ?? "Error status code \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                                DispatchQueue.main.async(execute: {
                                    observer.onNext(nil)
                                })
                                return
                        }
                        // Store result in cache
                        self.cache.add(key: filePath, data: data, completion: {
                            DispatchQueue.main.async(execute: {
                                observer.onNext(data)
                            })
                        })
                    }).resume()
                })
            })
            return Disposables.create()
        }
    }
    
    public func remove(storageReference: StorageReference) {
        cache.remove(key: filePath(storageReference: storageReference), completion: nil)
    }
    
    private func filePath(storageReference: StorageReference) -> String {
        return "\(storageReference.bucket)/\(storageReference.fullPath)"
    }
}

extension FirebaseStorageCache {
    
    static public var main: FirebaseStorageCache = FirebaseStorageCache(cache: DiskCache(name: "firstoragecache"))
    
    var cachePath: String {
        if let diskCache = cache as? DiskCache {
            return diskCache.cachePath
        }
        return ""
    }
    
    public func prune() {
        if let diskCache = cache as? DiskCache {
            diskCache.prune()
        }
    }

}
