# FirebaseStorageCache
FIRStorage for iOS with caching and offline capabilities

[![Version](https://img.shields.io/cocoapods/v/FirebaseStorageCache.svg?style=flat)](http://cocoapods.org/pods/FirebaseStorageCache)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://raw.githubusercontent.com/onevcat/Kingfisher/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/FirebaseStorageCache.svg?style=flat)](http://cocoapods.org/pods/FirebaseStorageCache)
[![license](https://camo.githubusercontent.com/988c4fe7435163e2c97239a8c6482771451ffa26/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f53776966742d342e302532422d6f72616e67652e737667)](https://camo.githubusercontent.com/988c4fe7435163e2c97239a8c6482771451ffa26/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f53776966742d342e302532422d6f72616e67652e737667)

## Demo

Clone/download [FirebaseOfflineAppDemo](https://github.com/antonyharfield/FirebaseOfflineAppDemo) and run `pod install` before pressing play in Xcode. The demo contains 3 examples: no caching, NSCache and FirebaseStorageCache.

## Requirements

This project assumes that you have already [setup Firebase for iOS](https://firebase.google.com/docs/ios/setup).

## Installation

FirebaseStorageCache is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FirebaseStorageCache'
```

## Usage

### Use the default shared cache

```swift
let ref: StorageReference = ...
FirebaseStorageCache.main.get(storageReference: ref) { data in
  // do something with your file
}
```

### Create custom storage caches

```swift
let oneWeekDiskCache = DiskCache(name: "customCache", cacheDuration: 60 * 60 * 24 * 7)
let firStorageCache = FirebaseStorageCache(cache: oneWeekDiskCache)
firStorageCache.get(storageReference: ref) { data in
  // do something with your file
}
```

### Extension for loading images (in UIImageView)

```swift
imageView.setImage(storageReference: ref)
```

### Extension for loading web pages (in UIWebView and WKWebView)

Simple:

```swift
webView.loadHTML(storageReference: ref)
```

With post processing on the HTML:

```swift
let styleHTML: (Data) -> Data = { data in
            let pre = "<style>body {margin: 16px}</style>"
            var preData = pre.data(using: .utf8) ?? Data()
            preData.append(data)
            return preData
        }
webView.loadHTML(storageReference: ref, postProcess: styleHTML)
```

### Cleaning/pruning the cache

In the `didFinishLaunchingWithOptions` of your AppDelegate, you should call the `prune()` 
method of your disk caches to remove any old files:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FirebaseStorageCache.main.prune()
        return true
    }
```

## Author

Antony Harfield, antonyharfield@gmail.com

## License

FirebaseStorageCache is available under the MIT license. See the LICENSE file for more info.
