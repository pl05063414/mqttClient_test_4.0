//
//  DictionAction.swift
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 2019/4/22.
//  Copyright © 2019 netvox-ios6. All rights reserved.
//

import UIKit

@objcMembers open class DictionAction: NSObject {

    /*
    override init() {
        super.init()
        
        let info = [["devid":"00137A000001D12903","posy":"547.0","posx":"594.0"],["devid":"00137A000001D12903","posy":"547.0","posx":"594.0"]]
        NetvoxNetwork.setLocationDeviceWithappid("57af1e82c18d4c28bc813a5500074e1e", andInfo: info) { (result) in
            print(result as Any)
        }
    }*/
    
    init(_ a:Int,_ b :String) {
        super.init()
    }
    
    func requestApp() -> () {
//        let permission = "{\"devices\":{\"all\":\"1\"},\"functions\":{\"all\":\"1\"}}"
//        let dic = changeJson(permission)
//        NetvoxNetwork.shareHouseFromCloud(withHouseIeee: "00137A0000010136", andInitiator: "18965183154", andPermission: dic! as? [AnyHashable : Any]) { (result) in
//            print("%@", dic)
//        }
        let info = [["devid":"00137A000001D12903","posy":"547.0","posx":"594.0"]]
        NetvoxNetwork.setLocationDeviceWithappid("57af1e82c18d4c28bc813a5500074e1e", andInfo: info) { (result) in
            print(result as Any)
        }
    }
    
    
    func changeJson(_ permission:String) -> NSDictionary? {
        let jsonData = permission.data(using: String.Encoding.utf8)
        do {
            let json:Any = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments)
            let jsonDic = json as? NSDictionary
            if jsonDic != nil{
                return jsonDic
            }
            return nil
        } catch let error as Error? {
            print(error)
            return nil
        }
    }
    
}
