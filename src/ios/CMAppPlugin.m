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

@end
