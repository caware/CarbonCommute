//
//  CO2LocationRecorder.m
//  CO2Commute
//
//  Created by Chris Elsmore on 20/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CO2LocationRecorder.h"

@implementation CO2LocationRecorder

@synthesize loggedLocations = _loggedLocations;


int const GPSINTERVAL = 5;
int const MINGPSACCURACY = 100;
///////////
#pragma mark - Init

- (id) init 
{
  self = [super init];
  if (self) {
    _loggedLocations = [[NSMutableArray alloc] init];
    _activelyMeasuringLocation = NO;
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
  self = [self init];
  if (self) {
    NSMutableArray *loadedLoggedLocations = [coder decodeObjectForKey:@"loggedLocations"];
    if (loadedLoggedLocations != Nil) 
      _loggedLocations = loadedLoggedLocations;
    NSLog(@"Instantiated recorder with %i commutes.",[_loggedLocations count]);
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:_loggedLocations forKey:@"loggedLocations"];
}


///////////
#pragma mark - Core methods

- (void) notifyOfNewLocation:(CLLocation *)newLocation
{
  if (_activelyMeasuringLocation) {
      NSLog(@"loc");
      if (newLocation.horizontalAccuracy < MINGPSACCURACY) { //Ignore all locations with 100m accuracy or worse
          CLLocation *oldLocation = [self getCurrentCommuteLastLocation];
          if (!oldLocation) { //if first new location, add it whatever.
              [self addLocationToCurrentCommute:newLocation];
              //NSLog(@"+ location!");
          }
          else {
              // if new Location comes >5 seconds after previous, treat as new point.
              // if less than 5, compare to accuracy of previous point and replace if better.
              //NSTimeInterval interval = 5;
              if ([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp] > GPSINTERVAL){
                  [self addLocationToCurrentCommute:newLocation];
                  //NSLog(@"+ location!");
              }
              else if (newLocation.horizontalAccuracy < oldLocation.horizontalAccuracy){
                  [self currentCommuteReplaceLastLocation:newLocation];
                  //NSLog(@"+, Got better Accuracy");
              }
          }
          //NSLog(@"GOTLOC w/ %f accuracy:",location.horizontalAccuracy);
          //[_loggedLocations addObject:location];
      }
  }
}

- (void) startRecording
{
    [self createNewCommute];
    _activelyMeasuringLocation = YES;
}

- (void) stopRecording
{
    _activelyMeasuringLocation = NO;
    [self endCurrentCommute];
    
}

///////////
#pragma mark - Commute Management

- (void) createNewCommute
{
    //add first element in the commute array, an NSdict containing commute info, space for stats etc
    NSMutableArray *commute = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *commuteStats = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"In Progress"], @"status",
                                  [[NSNumber alloc] initWithDouble:0.0], @"mean speed",
                                  [[NSNumber alloc] initWithDouble:0.0], @"modal speed",
                                  [[NSNumber alloc] initWithDouble:0.0], @"median speed",
                                  [[NSNumber alloc] initWithDouble:0.0], @"max speed",
                                  [[NSNumber alloc] initWithDouble:0.0], @"min speed",
                                  [[NSDate alloc] init], @"start",
                                  [[NSDate alloc] init], @"end",
                                  [[NSNumber alloc] initWithInt:0], @"locations",
                                  nil];
    [commute addObject:commuteStats];
    [_loggedLocations addObject:commute];
}

- (void) addLocationToCurrentCommute:(CLLocation *)newLocation
{
    //NSMutableArray *commute = [NSMutableArray arrayWithArray:[_loggedLocations lastObject]];
    NSMutableArray *commute = [_loggedLocations lastObject];
    NSLog(@"Add Loc: commute length: %i",[commute count]);
    [commute addObject:newLocation];
    NSLog(@"Add loc: commute now at length: %i",[commute count]);
    //[_loggedLocations removeLastObject];
    //[_loggedLocations addObject:commute];
    NSLog(@"saved");
}

- (void) endCurrentCommute
{
    NSMutableArray *commute = [_loggedLocations lastObject];
    //NSMutableDictionary *commuteStats = [NSMutableDictionary dictionaryWithDictionary:[commute objectAtIndex:0]];
    NSMutableDictionary *commuteStats = commute[0];
    [commuteStats setObject:[[NSDate alloc] init] forKey:@"end"];
    [commuteStats setObject:[[NSNumber alloc] initWithInt:[commute count]-1] forKey:@"locations"];
    [commuteStats setObject:@"OK" forKey:@"status"];
    //[commute replaceObjectAtIndex:0 withObject:commuteStats];
    //[_loggedLocations removeLastObject];
    //[_loggedLocations addObject:commute];
    // calculate stats based on commute data like mean median and modal speed, etc and store in first element info dict
}

///////////
#pragma mark - Commute Location Interfaces
- (NSDictionary *) getCurrentCommuteStats{
    NSArray *commute = [_loggedLocations lastObject];
    NSLog(@"commute length: %i",[commute count]);
    if ([commute count] > 1) return commute[0];
    return nil;
}

- (void) currentCommuteReplaceLastLocation:(CLLocation *)newLocation
{
    NSMutableArray *commute = [_loggedLocations lastObject];
    int len = [commute count];
    if (len > 2){
        [commute replaceObjectAtIndex:len - 1 withObject:newLocation];
    }
}

- (CLLocation *) getCurrentCommuteLastLocation
{
    NSArray *commute = [_loggedLocations lastObject];
    if ([commute count] == 1) return nil;
    else return [commute lastObject];
}

- (NSArray *) getCurrentCommuteLocations
{
    NSArray *commute = [_loggedLocations lastObject];
    int len = [commute count];
    if (len == 1) return nil;
    return [commute subarrayWithRange:NSMakeRange(1, len-1)];
}

- (void) removeCurrentCommuteLastLocation
{
    NSMutableArray *commute = [_loggedLocations lastObject];
    int len = [commute count];
    if (len > 1){
        [commute removeObjectsInRange:NSMakeRange(1, len-1)];
    }
}

- (void) clearCurrentCommuteLocations
{
    NSMutableArray *commute = [_loggedLocations lastObject];
    if ([commute count] > 1) [commute removeAllObjects];
}

- (BOOL) currentCommuteHasLocations
{
    NSArray *commute = [_loggedLocations lastObject];
    BOOL loc = NO;
    if ([commute count] > 1) {
        loc = YES;
    }
    return loc;
}

- (int) countCommutes
{
    return [_loggedLocations count];
}

- (int) countCurrentCommuteLocations
{
    NSArray *commute = [_loggedLocations lastObject];
    return [commute count] - 1;
}

- (NSArray *) getCommutes
{
    return _loggedLocations;
}

- (int) countAllLocations
{
    int total = 0;
    for (id object in _loggedLocations) {
        total += ([object count] - 1);
    }
    return total;
}

@end
