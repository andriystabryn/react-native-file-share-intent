//
//  FileHelper.h
//  RNFileShareIntent
//
//  Created by Valentyn Halkin on 8/19/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHelper : NSObject

+ (NSString *)MIMETypeFromPath:(NSString *)filePath;

+ (NSString *)fileNameFromPath:(NSString *)filePath;

+ (NSDictionary *)getFileData:(NSURL *)url;

+ (void)clearSharedFolder;

@end
