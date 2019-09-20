//
//  ViewController.m
//  BIDFetcher
//
//  Created by Saadat on 19.09.19.
//  Copyright © 2019 Saadat Baig. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
// props
@property (strong, nonatomic) IBOutlet UITextField *bidTextField;
@property (strong, nonatomic) IBOutlet UIButton *bidGetter;
@property (strong, nonatomic) NSString *bidURL;
@property (strong, nonatomic) NSString *artworkURL;
@property (assign, nonatomic) BOOL validURL;
@end

@implementation ViewController
// inits
@synthesize bidURL;
@synthesize artworkURL;
@synthesize validURL;

// fast inits
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// dismiss keyboard by touching anywhere
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// Button Action
- (IBAction)getImage:(UIButton *)sender {
    // make string
    [self structURL:self.bidTextField.text];
    // start downlaod process
    [self parseJSON:bidURL];
    // check if flag is set
    if (validURL == YES) {
        [self downloadImage:artworkURL];
    }
    else {
        // show error in form of Alert
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"It seems like the BundleID was faulty.\nCheck if you made any typos" preferredStyle:UIAlertControllerStyleAlert];
        // addd a ok button
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"bruh" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        // add the action to the alertController
        [alert addAction:defaultAction];
        // and show it
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// struct the String
-(void)structURL:(NSString *)bundleId {
    // create the string at once & return
    bidURL = [@"https://itunes.apple.com/lookup?bundleId=" stringByAppendingString:bundleId];
}

// get JSON object & extract link
-(void)parseJSON:(NSString *)bidURLString {
    // thy error
    NSError *error;
    // feed data into our dictionary
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:bidURLString]];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    // we need to check for an important bit. if resultCount is 0, the BundleID is invalid and we can quit
    int resultCount = [[jsonDict objectForKey:@"resultCount"] intValue];
    if (resultCount == 1) {
        // walkthrough the JSON object
        // We have resoutlCount & results as top-level entries, results is the array containing 1 dictionary with all the values, so we reference that
        NSArray *resultsArray = [jsonDict valueForKey:@"results"];
        NSDictionary *internalDict = resultsArray[0];
        artworkURL = [internalDict objectForKey:@"artworkUrl512"];
        // set next stage
        validURL = YES;
    } else {
        // set flag to false
        validURL = NO;
    }
}

// download the image if all is well
-(void)downloadImage:(NSString *)gibURL {
    NSLog(@"hello");
    // get the data asynchronously, else UI Thread is blocked
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // get image data, then init a UIImage
        NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:gibURL]];
        // sanity check here
        if (imgData == nil) {
            // log the error
            NSLog(@"Empyt imgData. Potential Connection error or URL corrupt\nCorrupt BID-URL: %@", self.artworkURL);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // create image
            UIImage *img = [UIImage imageNamed:self.bidTextField.text];
            img = [UIImage imageWithData:imgData];
            // save image to photos, no callback
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
        });
    });
    // add success message, we can re-utilize our code here
    UIAlertController *alertSuccess = [UIAlertController alertControllerWithTitle:@"Success" message:@"Successfully saved BundleID-Image to Photos!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultActionSuccess = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [alertSuccess addAction:defaultActionSuccess];
    [self presentViewController:alertSuccess animated:YES completion:nil];
}
// fin.
@end
