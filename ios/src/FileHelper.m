//
//  FileHelper.m
//  RNFileShareIntent
//
//  Created by Valentyn Halkin on 8/19/19.
//  Copyright © 2019 Facebook. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import "FileHelper.h"
#import <UIKit/UIKit.h>


@implementation FileHelper

+ (NSString *)MIMETypeFromPath:(NSString *)filePath
{
    NSString *extension = [filePath pathExtension];
    NSString *exportedUTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)exportedUTI, kUTTagClassMIMEType);

    return mimeType;
}
+ (NSString *)fileNameFromPath:(NSString *)filePath
{
    return [filePath lastPathComponent];
}

+ (NSDictionary *)getFileData:(NSURL *)url
{
    NSString *newUrl = [FileHelper saveImageToAppGroupFolder:url];
    
    NSError* error;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:newUrl error:&error];

    NSDictionary *fileData = @{
                               @"mime": [FileHelper MIMETypeFromPath:newUrl],
                               @"name": [FileHelper fileNameFromPath: [url absoluteString]],
                               @"path": newUrl,
                               @"size": [NSNumber numberWithLongLong:[fileAttributes fileSize]]
                               };
    
    return fileData;
}

+ ( NSString * ) saveImageToAppGroupFolder: ( NSURL * ) image
{
    NSString *fileName = [[FileHelper fileNameFromPath: [image absoluteString]] stringByReplacingOccurrencesOfString:@"%20" withString:@"_"];

    NSString *filePath = [[FileHelper getSharedFolderPath] stringByAppendingPathComponent: fileName ];
    NSError *error = nil;
    NSString *fileExt = [[[image absoluteString] pathExtension] lowercaseString];
    if ([fileExt isEqual: @"heic"]) {
        NSString *jpgPathToFile = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension: @"jpg"];

        UIImage *uiimage = [UIImage imageWithData:[NSData dataWithContentsOfURL:image]];
        
        if(![UIImageJPEGRepresentation(uiimage, 1.0) writeToFile:jpgPathToFile atomically:YES]) {
            NSLog(@"Could not convert HEIC at path %@ to path %@. error %@", image.path , jpgPathToFile, error);
        } else {
            NSLog(@"COVERTED SUCCESSFULLY");
        }
        
        filePath = jpgPathToFile;
    } else {
        if(![[NSFileManager defaultManager] copyItemAtPath:image.path toPath:filePath error:&error]) {
            NSLog(@"Could not copy report at path %@ to path %@. error %@", image.path , filePath, error);
        } else {
            NSLog(@"COPIED SUCCESSFULLY");
        }
    }
    
    return filePath;
}

+ ( NSString * ) getSharedFolderPath
{
    NSString *APP_SHARE_GROUP = @"group.com.levuro.engage";
    NSURL *containerURL = [ [ NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier: APP_SHARE_GROUP ];
    NSString *documentsPath = containerURL.path;
    
    return documentsPath;
}

+ (void) clearSharedFolder
{
    NSString *path = [FileHelper getSharedFolderPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator* en = [fm enumeratorAtPath:path];
    NSError* err = nil;
    BOOL res = false;

    NSString* file;
    while (file = [en nextObject]) {
        res = [fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            NSLog(@"oops: %@", err);
        }
    }
}

@end
