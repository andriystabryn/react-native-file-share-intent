//
//  ShareFileIntentModule.m
//  Share Intent
//
//  Created by Ajith A B on 16/08/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNFileShareIntent.h"
#import "RCTRootView.h"
#import "OperationRetrieval.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "RCTLog.h"
#import "FileHelper.h"


@implementation RNFileShareIntent
static NSItemProvider* ShareFileIntentModule_itemProvider;
static NSExtensionContext* extContext;

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(getFilePath,
                 getFilePathResolve:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeFileURL options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePDF]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePDF options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeBMP]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeBMP options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeGIF]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeGIF options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeICO]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeICO options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMP3]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeMP3 options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePNG]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePNG options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeJPEG]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeJPEG options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMPEG]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeMPEG options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMPEG4]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeMPEG4 options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeText options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudio]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeAudio options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else if ([ShareFileIntentModule_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeVideo]) {
        [ShareFileIntentModule_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeVideo options:nil completionHandler:^(NSURL *url, NSError *error) {
            resolve(@[url.absoluteString]);
        }];
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@"com.levuro.engage" code:100 userInfo: @{NSLocalizedDescriptionKey: @"Invalid file type"}];
        reject(@"invalid_filetype", @"Invalid file type", error);
    }
}

RCT_EXPORT_METHOD(openURL:(NSString *)url) {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *urlToOpen = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [application openURL:urlToOpen options:@{} completionHandler: nil];
}


RCT_EXPORT_METHOD(close)
{
    [ extContext completeRequestReturningItems: @[] completionHandler: nil ];
}

RCT_EXPORT_METHOD(getFiles:(RCTResponseSenderBlock)callback)
{
    NSArray *types = @[
                       (NSString *)kUTTypeImage,
                       (NSString *)kUTTypeMovie
                       ];

    [self getItems:types withCallback:callback];
}

-(void) getItems:(NSArray *)types withCallback:(RCTResponseSenderBlock)callback {
    NSArray *inputItems = extContext.inputItems;
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    for (int i = 0; i < [inputItems count]; i++) {
        NSExtensionItem *item = (NSExtensionItem *) inputItems[i];
        
        if (item.attachments != nil) {
            for (int k = 0; k < [types count]; k++) {
                NSString *type = types[k];
                for (int j = 0; j < [item.attachments count]; j++) {
                    NSItemProvider *attachment = item.attachments[j];
                    
                    if ([attachment hasItemConformingToTypeIdentifier:type]) {
                        OperationRetrieval *operation = [[OperationRetrieval alloc] initWithItemProvider:attachment type:type completion:^(NSDictionary *fileData) {
                            [urls addObject:fileData];
                        }];
                        
                        [queue addOperation:operation];
                    }
                }
            }
            
        }
    }
    [queue addOperationWithBlock:^{
        callback(@[[urls copy]]);
    }];
}

RCT_EXPORT_METHOD(clearSharedFolder) {
    [FileHelper clearSharedFolder];
}

+(void) setShareFileIntentModule_itemProvider: (NSItemProvider*) itemProvider
{
    ShareFileIntentModule_itemProvider = itemProvider;
}

+(void) setContext: (NSExtensionContext*) context
{
    extContext = context;
}
@end

