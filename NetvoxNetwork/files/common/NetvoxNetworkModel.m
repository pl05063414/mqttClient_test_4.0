//
//  NetvoxNetworkModel.m
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/7/4.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import "NetvoxNetworkModel.h"

@implementation NetvoxNetworkModel

-(NSMutableArray *)fileNameArray{
    if(_fileNameArray == nil)
    {
        _fileNameArray = [NSMutableArray new];
    }
    return _fileNameArray;
}

-(NSMutableArray *)formDataArray{
    if(_formDataArray == nil)
    {
        _formDataArray = [NSMutableArray new];
    }
    return _formDataArray;
}

-(NSMutableArray *)mimeTypeArray{
    if(_mimeTypeArray == nil)
    {
        _mimeTypeArray = [NSMutableArray new];
    }
    return _mimeTypeArray;
}

@end
