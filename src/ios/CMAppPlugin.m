#import "CMAppPlugin.h"

@implementation CMAppPlugin

@synthesize callbackID, locationManager;

// - (void)disableIdleTimeout:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
- (void)disableIdleTimeout:(CDVInvokedUrlCommand*)command {

    // The first argument in the arguments parameter is the callbackID.
    // We use this to send data back to the successCallback or failureCallback
    // through PluginResult.
    // self.callbackID = [arguments pop];
    self.callbackID = command.callbackId;

    UIApplication* app = [UIApplication sharedApplication];

    if(![app isIdleTimerDisabled]) {
        [app setIdleTimerDisabled:true];
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    // [self writeJavascript: [pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackID];
}

// - (void)enableIdleTimeout:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
- (void)enableIdleTimeout:(CDVInvokedUrlCommand*)command {
    // The first argument in the arguments parameter is the callbackID.
    // We use this to send data back to the successCallback or failureCallback
    // through PluginResult.
    // self.callbackID = [arguments pop];
    self.callbackID = command.callbackId;

    UIApplication* app = [UIApplication sharedApplication];

    if([app isIdleTimerDisabled]) {
        [app setIdleTimerDisabled:false];
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    // [self writeJavascript: [pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackID];
}

- (void)getCloudDirectory:(CDVInvokedUrlCommand*)command {
    self.callbackID = command.callbackId;

    NSURL* containerUrl = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:@"iCloud.net.disy.cadenza.mobile.app"] URLByAppendingPathComponent:@"Documents"];
    if (containerUrl && ![[NSFileManager defaultManager] fileExistsAtPath:[containerUrl path] isDirectory:NULL]) {
        NSError* error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:containerUrl withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error creating directory: %@", error.localizedDescription);
        }
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[containerUrl path]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackID];
}

- (void)startLocationManager:(CDVInvokedUrlCommand*)command {
    self.callbackID = command.callbackId;

    [[self locationManager] startUpdatingLocation];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackID];
}

- (void)stopLocationManager:(CDVInvokedUrlCommand*)command {
    self.callbackID = command.callbackId;

    if (locationManager == nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackID];
        return;
    }

    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackID];
}

- (CLLocationManager*)locationManager {
    if (locationManager != nil) {
        return locationManager;
    }

    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];

    return locationManager;
}

- (void)convertFileToBase64:(CDVInvokedUrlCommand*)command {
    NSString *callbackId = command.callbackId;
    self.callbackID = callbackId;

    NSString *path = [command.arguments firstObject];
    if (path == nil || [path length] == 0) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@""];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        return;
    }

    if ([path hasPrefix:@"file://"]) {
        path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    } else if ([path hasPrefix:@"http://localhost/_app_file_"]) {
        path = [path stringByReplacingOccurrencesOfString:@"http://localhost/_app_file_" withString:@""];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];

        if (data == nil || error) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@""];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
            return;
        }

        NSString *base64String = [data base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:base64String];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    });
}


@end
