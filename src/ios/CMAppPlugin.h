#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

@interface CMAppPlugin : CDVPlugin {

    NSString* callbackID;
    CLLocationManager *locationManager;
}

@property (nonatomic, copy) NSString* callbackID;
@property (nonatomic, copy) CLLocationManager* locationManager;

-(void)disableIdleTimeout:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
-(void)enableIdleTimeout:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
-(void)getCloudDirectory:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
-(void)startLocationManager:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
-(void)stopLocationManager:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
