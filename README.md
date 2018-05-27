
# SwiftyPhotos

[![Cocoapods](https://img.shields.io/cocoapods/v/SwiftyPhotos.svg)](https://cocoapods.org/pods/SwiftyPhotos)
[![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)](https://github.com/icetime17/SwiftyPhotos)
[![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-9.3-blue.svg)](https://developer.apple.com/xcode)
[![MIT](https://img.shields.io/badge/License-MIT-red.svg)](https://opensource.org/licenses/MIT)

Useful tool for ***PhotoKit framework*** to boost your productivity.


## Requirements:

Xcode 8 (or later) with Swift 3. This library is made for iOS 10.0 or later.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate SwiftyPhotos into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
pod 'SwiftyPhotos'
end
```

Then, run the following command:

```bash
$ pod install
```

### Manually

Add the ***Sources*** folder to your Xcode project to use all extensions, or a specific extension.

## Usage

### Authorization Status

```
SwiftyPhotos.shared.reloadAll { (isPhotoAuthrized) in
    if isPhotoAuthrized {
        if let allPhotosAlbum = SwiftyPhotos.shared.allPhotoAlbums.first {
            self.photoAlbum = allPhotosAlbum
        }

        DispatchQueue.main.async {
            self.setupUI()
        }
    } else {
        print("please allow photo authorization status")
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: "Fail to visit iPhone photo album", message: nil, preferredStyle: .alert)
            let goSettings = UIAlertAction(title: "Go to Settings", style: .default, handler: { (alertAction) in
                print("go to settings")
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertVC.addAction(goSettings)
            alertVC.addAction(cancel)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}
```

### Album

***PhotoAlbumModel*** contains what you need for a album.

Check if album is existing or create album with name.

```
if let _ = SwiftyPhotos.shared.photoAlbumWithName("SwiftyPhotos") {
} else {
    _ = SwiftyPhotos.shared.createAlbum("SwiftyPhotos")
}
```

Create a PhotoAssetsView, and use PhotoAlbumsViewDelegate to handle the photo selection action.

```
let view = PhotoAssetsView(frame: frame, photoAlbum: self.photoAlbum, cellCountOfLine: 4, cellOffset: 2.0)
```

```
protocol PhotoAlbumsViewDelegate: class {
    func PhotoAlbumsViewDidSelectPhotoAlbum(_ photoAlbum: PhotoAlbumModel)
}
```

### Photo

***PhotoAssetModel*** contains what you need for a photo asset.

Request thumbnail for a photo.

```
public var photoAsset: PhotoAssetModel! {
    didSet {
        self.imageRequestID = self.photoAsset.requestThumbnail(resultHandler: { (image, info) in
            DispatchQueue.main.async {
                if let info = info {
                    if let requestID = info[PHImageResultRequestIDKey] as? NSNumber {
                        if requestID.int32Value == self.imageRequestID {
                            self.thumbnail.image = image
                        }
                    }
                }
            }
        })
    }
}
```

Request a photo from iCloud.

```
if self.photoAsset.isInCloud {
    print("photo in icloud")
    self.photoAsset.requestAvailableSizeImageInCloud { [weak self] (image, info) in
        if let image = image {
            self?.imageView.image = image
        }
    }
    self.photoAsset.requestMaxSizeImageInCloud(resultHandler: { [weak self] (image, info) in
        if let image = image {
            self?.imageView.image = image
        }
    }) { [weak self] (progress, error, stop, info) in
        self?.progressOfDownloadingInCloud = progress
        print("downloading progress of icloud photo: \(String(progress))")
    }
} else {
    self.photoAsset.requestMaxSizeImage { [weak self] (image, info) in
        if let image = image {
            self?.imageView.image = image
        }
    }
}
```

## Contact

If you find an issue, just open a ticket. Pull requests are warmly welcome as well.


## License

SwiftyPhotos is released under the MIT license. See LICENSE.md for details.
