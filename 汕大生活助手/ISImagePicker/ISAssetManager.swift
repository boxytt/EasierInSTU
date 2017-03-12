//
//  ISImageManager.swift
//  ISImagePicker
//
//  Created by invictus on 2016/11/21.
//  Copyright © 2016年 invictus. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ISAlbumModel{
    var name:String = ""
    var count:Int = 0
    var assets:[ISAssetModel] = []
    var selectAssets:[ISAssetModel] = []
    var selectCount:Int = 0
    
    init(name:String,count:Int,assets:[ISAssetModel],selectAssets:[ISAssetModel],selectCount:Int) {
        self.name = name
        self.count = count
        self.assets = assets
        self.selectAssets = selectAssets
        self.selectCount = selectCount
    }
}

class ISAssetModel:Equatable{
    var asset:PHAsset
    var isSeleted:Bool
    var mediaType:PHAssetMediaType
    var image:UIImage?
    
    init(asset:PHAsset,isSeleted:Bool,mediaType:PHAssetMediaType) {
        self.asset = asset
        self.isSeleted = isSeleted
        self.mediaType = mediaType
    }
    public static func ==(lhs: ISAssetModel, rhs: ISAssetModel) -> Bool{
        return lhs.asset == rhs.asset
    }
}

class ISAssetManager{
    static var shareInstance = ISAssetManager()
    var authorized:Bool{
        get{
            return PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized
        }
    }
    
    fileprivate init(){
        
    }
    
    func getAlbums(_ isPickVideo:Bool ,isPickerImage:Bool , completion:([ISAlbumModel])->()){
        var albums=[ISAlbumModel]()
        let fetchOptions = PHFetchOptions()
//        if(isPickVideo){
//            fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", argumentArray: [PHAssetMediaType.image])
//        }
//        if (isPickerImage) {
//              fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", argumentArray: [PHAssetMediaType.video])
//        }
//        fetchOptions.predicate = NSPredicate(format: "mediaType == %ld", argumentArray: [PHAssetMediaType.image.rawValue,PHAssetMediaType.video.rawValue])
//        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let photoAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumMyPhotoStream, options: fetchOptions)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumSyncedAlbum, options: fetchOptions)
        let topLevelCollections = PHAssetCollection.fetchTopLevelUserCollections(with: nil)

        let assetOptions = PHFetchOptions()
        photoAlbums.enumerateObjects({ (collection, index, stop) in
            let fetchResult = PHAsset.fetchAssets(in: collection, options: assetOptions)
            if (fetchResult.count>0){
                albums.append(self.modelWithFetchResult(fetchResult,name:collection.localizedTitle!,isPickVideo:isPickVideo,isPickerImage:isPickerImage))
            }
        })
        
        smartAlbums.enumerateObjects({ (collection, index, stop) in
            let fetchResult = PHAsset.fetchAssets(in: collection, options: assetOptions)
            if (fetchResult.count>0){
                albums .append(self.modelWithFetchResult(fetchResult,name:collection.localizedTitle! ,isPickVideo:isPickVideo,isPickerImage:isPickerImage))
            }
        })
        topLevelCollections.enumerateObjects({ (collection, index, stop) in
            let fetchResult = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: assetOptions)
            if(fetchResult.count>0)
            {
                albums .append(self.modelWithFetchResult(fetchResult,name:collection.localizedTitle!,isPickVideo:isPickVideo,isPickerImage:isPickerImage))
            }
        })
        albums.sorted { (alb1:ISAlbumModel, alb2:ISAlbumModel) -> Bool in
            return alb1.assets.count>alb2.assets.count
        }
        completion(albums)
    }
    
    func modelWithFetchResult(_ result:PHFetchResult<PHAsset>,name:String,isPickVideo:Bool,isPickerImage:Bool) -> ISAlbumModel {
        var assets = [ISAssetModel]()
        let selectAssets = [ISAssetModel]()
        result.enumerateObjects({( asset:PHAsset, index:Int, stop:UnsafeMutablePointer<ObjCBool>) in
            let assetModel = ISAssetModel(asset: asset, isSeleted:false, mediaType: asset.mediaType)
            assets.append(assetModel)
            })
        let  album = ISAlbumModel(name:name,count:assets.count,assets:assets,selectAssets:selectAssets,selectCount:0)
        return album
        
    }
    
    func getAlbumImage(_ album:ISAlbumModel,expectWidth:CGFloat,completion:@escaping ((UIImage?)->())){
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.fast
        if let asset = album.assets.last?.asset{
            let ratio = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
            let height = expectWidth / ratio
            PHImageManager.default().requestImage(for:asset , targetSize:CGSize(width:expectWidth,height:height), contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: ({(img:UIImage?, _:[AnyHashable : Any]?) in completion(img!)
            }))
 
        }else {
            completion(nil)
        }
    }
    func getAssetImgage(asset:ISAssetModel,expectWidth:CGFloat,completion:@escaping ((UIImage)->())){
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.fast
        let asset = asset.asset
        var size:CGSize
        let ratio = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        let height = expectWidth / ratio
        size = CGSize(width:expectWidth,height:height)
        PHImageManager.default().requestImage(for:asset , targetSize:size, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: ({(img:UIImage?, _:[AnyHashable : Any]?) in completion(img!)
        }))
    }
    func  getAssetOrignalImages(assets:[ISAssetModel],completion:@escaping ((_:[UIImage])->())) -> Void {
        var ret = [UIImage]()
        var counter = 0
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.fast
        for asset in assets {
            let asset = asset.asset
            PHImageManager.default().requestImage(for:asset , targetSize:PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: ({(img:UIImage?, _:[AnyHashable : Any]?) in
                if let img = img{
                    ret.append(img)
                }
                counter = counter+1
                if counter>=assets.count{
                    completion(ret)
                }
                
            }))
        }
    }
    func getAssetImageOriginalSize(assets:[ISAssetModel],completion:@escaping ((String)->())) -> Void {
        var ret = ""
        guard assets.count>0 else {
            completion(ret)
            return
        }
        var bytes=0.0
 
        var count = 0
        for asset in assets{
            PHImageManager.default().requestImageData(for: asset.asset, options: nil, resultHandler: { (data:Data?, _:String?, _:UIImageOrientation,_:[AnyHashable : Any]?) in
                bytes+=Double((data?.count)!)
                count = count + 1
                if(count >= assets.count){
                    if (bytes >= (1024 * 1024)) {
                        ret = String(format: "%.2fM", bytes/1024/1024.0)
                    } else if (bytes >= 1024) {
                        ret = String(format: "%.2fk", bytes/1024.0)
                    } else {
                        ret = "\(bytes)db";
                    }
                    completion("(\(ret))")
                }
            })
        }
      
    }
    
}
