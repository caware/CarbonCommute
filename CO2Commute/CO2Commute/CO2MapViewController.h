//
//  CO2MapViewController.h
//  CO2Commute
//
//  Created by Chris Elsmore on 30/07/2012.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define METERS_PER_MILE 1609.334

@interface CO2MapViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate> {
  @private
  BOOL _viewDidZoom;
  UILongPressGestureRecognizer *_lpgr;
  UIActionSheet *sheet;
}
@property (weak, nonatomic) IBOutlet MKMapView *map;

@end
