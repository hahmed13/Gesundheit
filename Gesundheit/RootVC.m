//
//  TAViewController.m
//  Gesundheit
//
//  Created by Jhaybie on 10/23/13.
//  Copyright (c) 2013 Jhaybie. All rights reserved.
//

#import "FavoriteLocationsVC.h"
#import "RootVC.h"
#import "UIImage+animatedGIF.h"

@interface RootVC ()

@property (weak, nonatomic) IBOutlet UIButton    *searchButtonToggler;
@property (weak, nonatomic) IBOutlet UILabel     *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel     *currentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel     *predominantTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dandelionGifImage;
@property (weak, nonatomic) IBOutlet UITextView  *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *allergenLevelButton;

- (IBAction)onTouchSearch:(id)sender;

@end


@implementation RootVC
@synthesize
            cityLabel,
            currentDateLabel,
            dandelionGifImage,
            descriptionTextView,
            predominantTypeLabel,
            allergenLevelButton,
            searchButtonToggler;


BOOL              isShown;
CLGeocoder        *geocoder;
CLLocationManager *locationManager;
int               weekDayValue;
NSArray           *week;
NSMutableArray    *weeklyForecast;
NSString          *city,
                  *state,
                  *zip,
                  *predominantType;
UIColor           *darkGreenColor,
                  *greenColor,
                  *yellowColor,
                  *orangeColor,
                  *redColor;





//Ask Don or Max about replacing this deprecated method

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    CLLocation *currentLocation = newLocation;
    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray* placemarks, NSError* error) {
                       if (error == nil && placemarks.count > 0) {
                           CLPlacemark *placemark = [placemarks lastObject];
                           zip = [NSString stringWithFormat:@"%@", placemark.postalCode];
                           [self fetchPollenDataFromZip:zip];
                       }
     }];
}


- (void)getCurrentLocationZip {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)fetchPollenDataFromZip:(NSString *)zipCode {
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://direct.weatherbug.com/DataService/GetPollen.ashx?zip=%@", zip]]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSDictionary *initialDump = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:0
                                                                                             error:&connectionError];
                               NSArray *arrayDump = [initialDump objectForKey:@"dayList"];
                               city = [initialDump objectForKey:@"city"];
                               state = [initialDump objectForKey:@"state"];
                               predominantType = [initialDump objectForKey:@"predominantType"];
                               weeklyForecast = [[NSMutableArray alloc] init];
                               for (int i = 0; i < arrayDump.count; i++) {
                                   Forecast *tempForecast = [[Forecast alloc] init];
                                   tempForecast.city = city;
                                   tempForecast.state = state;
                                   tempForecast.zip = zipCode;
                                   tempForecast.desc = [arrayDump[i] objectForKey:@"desc"];
                                   tempForecast.level = [[arrayDump[i] objectForKey:@"level"] floatValue];
                                   tempForecast.predominantType = predominantType;
                                   [weeklyForecast addObject:tempForecast];
                               }
                               [self showResults];
                           }];
}

- (void)showResults {
    if (weeklyForecast.count > 0) {
        Forecast *tempForecast = [weeklyForecast firstObject];
        [allergenLevelButton setTitle:[NSString stringWithFormat:@"%0.1f", tempForecast.level] forState:UIControlStateNormal];
        cityLabel.text = tempForecast.city;
        descriptionTextView.text = tempForecast.desc;
        predominantTypeLabel.text = tempForecast.predominantType;
    }
    [locationManager stopUpdatingLocation];
    [self allergenLevelChangeFontColor];
}

- (void)allergenLevelChangeFontColor {
//    float level = allergenLevelButton.text.floatValue;
    float level = allergenLevelButton.currentTitle.floatValue;
    UIColor *textColor;
    if (level >= 0 && level < 2.5)
        textColor = darkGreenColor;
    else if (level >= 2.5 && level < 4.9)
        textColor = greenColor;
    else if (level >= 4.9 && level < 7.3)
        textColor = yellowColor;
    else if (level >= 7.3 && level < 9.6)
        textColor = orangeColor;
    else
        textColor = redColor;
    [allergenLevelButton setTitleColor:textColor forState:UIControlStateNormal];
    descriptionTextView.textColor = textColor;
}

- (void)labelFonts {
    UIFont *jandaAppleFont = [UIFont fontWithName:@"JandaAppleCobbler"
                                             size:55];
    UIFont *airplaneFont = [UIFont fontWithName:@"Airplanes in the Night Sky"
                                           size:17];

    cityLabel.font = airplaneFont;
}

- (void)showGifImage {
    dandelionGifImage.image = [UIImage imageNamed:@"skyBackRoundwithClouds.png"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"forecastSegue"]) {
        WeeklyForecastVC *wfvc = segue.destinationViewController;
        wfvc.weeklyForecast = weeklyForecast;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    geocoder = [[CLGeocoder alloc] init];
    [self showGifImage];
    isShown = NO;
    locationManager = [[CLLocationManager alloc] init];
    [self getCurrentLocationZip];
    darkGreenColor = [UIColor colorWithRed:34.0f/255.0f
                                     green:139.0f/255.0f
                                      blue:34.0f/255.0f
                                     alpha:1];
    greenColor = [UIColor colorWithRed:124.0f/255.0f
                                 green:252.0f/255.0f
                                  blue:0.0f/255.0f
                                 alpha:1];
    yellowColor = [UIColor colorWithRed:255.0f/255.0f
                                  green:215.0f/255.0f
                                   blue:0.0f/255.0f
                                  alpha:1.0];
    orangeColor = [UIColor colorWithRed:255.0f/255.0f
                                  green:140.0f/255.0f
                                   blue:0.0f/255.0f
                                  alpha:1.0];
    redColor = [UIColor colorWithRed:255.0f/255.0f
                               green:0.0f/255.0f
                                blue:0.0f/255.0f
                               alpha:1.0];
}

- (IBAction)allergenLevelNumberWasTouched:(id)sender {

}

- (IBAction)onTouchSearch:(id)sender {
        FavoriteLocationsVC *flvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZipCodeController"];
        [self presentViewController:flvc
                           animated:YES
                         completion:nil];
}

@end
