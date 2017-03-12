//
//  ISAlbumPickerController.swift
//  ISImagePicker
//
//  Created by invictus on 2016/11/21.
//  Copyright © 2016年 invictus. All rights reserved.
//

import UIKit

class ISAlbumPickerController:UIViewController,UITableViewDelegate,UITableViewDataSource
{
    var albums = [ISAlbumModel]()
    let tableView = UITableView()
    var imagePickerDidEnd:((_ images:[UIImage],_ assets:[ISAssetModel],_ isSelectOrignalImage:Bool)->())?
    var imagePickerDidCancel:(()->())?
    
    override func viewDidLoad() {
        print("Album")
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.loadAllAlbum()
        self.navigationItem.title = String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey:"Photos")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey:"取消"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelAct))
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tableView]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tableView":tableView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tableView":tableView]))
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    func cancelAct(_ sender:UIButton) -> Void{
        self.dismiss(animated: true, completion:nil )
    }
    func loadAllAlbum(){
            if ISAssetManager.shareInstance.authorized {
                 tableView.isHidden = false
                ISAssetManager.shareInstance.getAlbums(true, isPickerImage: true) { (albums:[ISAlbumModel]) in
                    if albums.count>0{
                        self.albums = albums;
                        var counter = 0
                        for tempAlbum in albums{
                            if tempAlbum.name == "相机胶卷" || tempAlbum.name == "Photos"
                            {
                                (self.albums[0],self.albums[counter]) = (self.albums[counter],self.albums[0])
                                break
                            }
                            counter = counter + 1
                        }
                        
                        let photoPicker:ISPotoPickerController = ISPotoPickerController(album:self.albums[0])
                        photoPicker.imagePickerDidEnd = self.imagePickerDidEnd
                        photoPicker.imagePickerDidCancel = self.imagePickerDidCancel
                        self.navigationController?.pushViewController(photoPicker, animated: false)
                    }
                }
                
            }else {
                tableView.isHidden = true
                let settingLabel = UILabel()
                self.view.addSubview(settingLabel)
                
                settingLabel.translatesAutoresizingMaskIntoConstraints = false
                
                var appName = Bundle.main.infoDictionary?["CFBundleDisplayName"]
                if (appName == nil){
                   appName = Bundle.main.infoDictionary?["CFBundleName"]
                }
                settingLabel.text = String(format:String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey: "Allow %@ to access your album in \"Settings -> Privacy -> Photos\""),appName as! CVarArg)
                settingLabel.numberOfLines = 0
                settingLabel.textAlignment = NSTextAlignment.center
//                settingLabel.trailingAnchor
                
                let settingBtn = UIButton()
                settingBtn.translatesAutoresizingMaskIntoConstraints = false
                settingBtn.setTitle( String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey: "Setting"), for: UIControlState.normal)
                settingBtn.setTitleColor(UIColor.blue, for: UIControlState.normal)
                settingBtn.addTarget(self, action: #selector(settingBtnAct), for: UIControlEvents.touchUpInside)
                self.view.addSubview(settingBtn)
                
                
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[settingLabel]-10-[settingBtn]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["settingLabel":settingLabel,"settingBtn":settingBtn]))
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[settingLabel]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["settingLabel":settingLabel]))
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[settingBtn]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["settingBtn":settingBtn]))
        }
    }
    
    func settingBtnAct(_ sender:UIButton) -> Void{
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        } else {
            // Fallback on earlier versions
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
        if let cell = cell {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            for view:UIView in (cell.contentView.subviews){
                view.removeFromSuperview()
            }
            let album = albums[indexPath.row]
            ISAssetManager.shareInstance.getAlbumImage(album,expectWidth:IS_IMG_PICK_CONFIG.expectImageWidth,completion: { (img:UIImage?) in
                if let img = img{
                    let imageView = UIImageView(image: img)
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    cell.contentView.addSubview(imageView)
                    let title = UILabel()
                    title.translatesAutoresizingMaskIntoConstraints = false
                    cell.contentView.addSubview(title)
                    let count = UILabel()
                    count.textColor = UIColor.darkGray
                    count.translatesAutoresizingMaskIntoConstraints = false
                    cell.contentView.addSubview(count)
                    
                    cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[imageView(==80)]-10-[title]-10-[count]", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView":imageView,"title":title,"count":count]))
                    cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[imageView]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView":imageView]))
                    cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[title]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["title":title]))
                    cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[count]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["count":count]))
                    title.text = album.name
                    imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    count.text = "(\(album.count))"
                }
                
            })
        }
        return cell!;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photoPicker = ISPotoPickerController(album:albums[indexPath.row])
        photoPicker.imagePickerDidEnd = self.imagePickerDidEnd
        photoPicker.imagePickerDidCancel = self.imagePickerDidCancel
        self.navigationController?.pushViewController(photoPicker, animated: true)
    }
    deinit {
        albums.removeAll()
    }
    
}
