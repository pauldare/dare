//
//  NewDareViewController.m
//  Dare
//
//  Created by Nadia Yudina on 6/30/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "NewDareViewController.h"
#import "CameraManager.h"
#import "UIColor+DareColors.h"
#import "CameraManager.h"
#import "FriendListIcon.h"
#import "SelectDareCell.h"
#import "ParseClient.h"
#import <FontAwesomeKit/FontAwesomeKit.h>


@interface NewDareViewController () <UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CameraManager *cameraManager;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *flipButton;

@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollection;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (weak, nonatomic) IBOutlet UICollectionView *textCollection;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *messages;
//@property (strong, nonatomic) NSArray *friends;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) UIView *dareTextImageOverlay;
@property (strong, nonatomic) UILabel *takeAPhotoOverlay;




@end

@implementation NewDareViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.images = @[[UIImage imageNamed:@"angry.jpeg"], [UIImage imageNamed:@"tricolor.jpeg"], [UIImage imageNamed:@"kitten.jpeg"], [UIImage imageNamed:@"cat.jpeg"]];
    self.messages = @[@"I DARE YOU\nto pet a cat", @"I DARE YOU\nto eat icecream", @"I DARE YOU\nto have fun"];
    
    _imageView.backgroundColor = [UIColor whiteColor];
    _cameraView.backgroundColor = [UIColor whiteColor];
    self.imageView.hidden = YES;
    
    [self.view bringSubviewToFront:self.cameraButton];
    [self.view bringSubviewToFront:self.flipButton];
    [self.view bringSubviewToFront:self.albumButton];
    [_cameraButton setTintColor:[UIColor DareBlue]];
    [_flipButton setTintColor:[UIColor DareBlue]];
    [_albumButton setTintColor:[UIColor DareBlue]];
    
    FAKFontAwesome *cameraIcon = [FAKFontAwesome cameraIconWithSize:60];
    [cameraIcon addAttribute:NSForegroundColorAttributeName value:[UIColor DareBlue]];
    UIImage *cameraImage = [cameraIcon imageWithSize:CGSizeMake(60, 60)];
    [_cameraButton setTitle:@"" forState:UIControlStateNormal];
    [_cameraButton setImage:cameraImage forState:UIControlStateNormal];
    
    FAKFontAwesome *flipCameraIcon = [FAKFontAwesome refreshIconWithSize:60];
    [flipCameraIcon addAttribute:NSForegroundColorAttributeName value:[UIColor DareBlue]];
    UIImage *flipImage = [flipCameraIcon imageWithSize:CGSizeMake(60, 60)];
    [_flipButton setTitle:@"" forState:UIControlStateNormal];
    [_flipButton setImage:flipImage forState:UIControlStateNormal];
    
    FAKFontAwesome *existingPhotoIcon = [FAKFontAwesome photoIconWithSize:60];
    [existingPhotoIcon addAttribute:NSForegroundColorAttributeName value:[UIColor DareBlue]];
    UIImage *existingPhotoImage = [existingPhotoIcon imageWithSize:CGSizeMake(60, 60)];
    [_albumButton setTitle:@"" forState:UIControlStateNormal];
    [_albumButton setImage:existingPhotoImage forState:UIControlStateNormal];
    
    FAKFontAwesome *rightLabel = [FAKFontAwesome forwardIconWithSize:40];
    [rightLabel addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *rightLabelImage = [rightLabel imageWithSize:CGSizeMake(40, 40)];
    [_forwardButton setTitle:@"" forState:UIControlStateNormal];
    [_forwardButton setTintColor:[UIColor whiteColor]];
    [_forwardButton setImage:rightLabelImage forState:UIControlStateNormal];
    
    FAKFontAwesome *leftLabel = [FAKFontAwesome backwardIconWithSize:40];
    [leftLabel addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftLabelImage = [leftLabel imageWithSize:CGSizeMake(40, 40)];
    [_backButton setTitle:@"" forState:UIControlStateNormal];
    [_backButton setTintColor:[UIColor whiteColor]];
    [_backButton setImage:leftLabelImage forState:UIControlStateNormal];
    
    
    [self setupCamera];
    [self setupFriendsCollection];
    [self setupTextCollection];
    
    
    [self setupImageOverlay];
    
    
    
    //    [ParseClient getUser:[PFUser currentUser] completion:^(User *loggedUser) {
    //        self.friends = [[NSMutableArray alloc]initWithObjects:[PFUser currentUser], nil];
    //        [self.friends addObjectsFromArray:loggedUser.friends];
    //        NSLog(@"%@", self.friends);
    //        [self beginThread:^(PFObject *messageThread) {
    //            NSLog(@"thread begun");
    //            [ParseClient addMessageToThread:messageThread
    //                                   withText:@"give flowers"
    //                                    picture:[UIImage imageNamed:@"flower.jpeg"]
    //                                 completion:^{
    //                                     NSLog(@"fetched");
    //                                 }];
    //        }];
    //    } failure:nil];
    
    

    UINib *dareNib = [UINib nibWithNibName:@"SelectDareCell" bundle:nil];
    [self.textCollection registerNib:dareNib forCellWithReuseIdentifier:@"SelectDareCell"];
    UINib *friendNib = [UINib nibWithNibName:@"FriendListIcon" bundle:nil];
    [self.friendsCollection registerNib:friendNib forCellWithReuseIdentifier:@"FriendCell"];
    
    [self.view bringSubviewToFront:self.forwardButton];
    [self.view bringSubviewToFront:self.backButton];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _takeAPhotoOverlay = [[UILabel alloc]initWithFrame:_textCollection.frame];
    _takeAPhotoOverlay.backgroundColor = [UIColor DareBlue];
    _takeAPhotoOverlay.textColor = [UIColor whiteColor];
    _takeAPhotoOverlay.text = @"Take a photo or choose one";
    _takeAPhotoOverlay.font = [UIFont boldSystemFontOfSize:20];
    _takeAPhotoOverlay.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_takeAPhotoOverlay];
    [self.view bringSubviewToFront:_takeAPhotoOverlay];
    _textCollection.hidden = YES;
    _backButton.hidden = YES;
    _forwardButton.hidden = YES;
}

-

-(void)setupImageOverlay
{
    _dareTextImageOverlay = [[UIView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height, _imageView.frame.size.width, 80)];
    _dareTextImageOverlay.backgroundColor = [UIColor DareCellOverlay];
    [self.view addSubview:_dareTextImageOverlay];
    //[self performSelector:@selector(moveOverlayIntoView) withObject:self afterDelay:3.0];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_dareTextImageOverlay addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *tapOnImageOverlay = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cropImageToOverlay)];
    tapOnImageOverlay.numberOfTapsRequired = 1;
    [_dareTextImageOverlay addGestureRecognizer:tapOnImageOverlay];


}

-(void)moveOverlayIntoView
{
    [UIView animateWithDuration:0.3 animations:^{
        
        [_dareTextImageOverlay setFrame:CGRectMake(0, _cameraView.frame.origin.y, _cameraView.frame.size.width, 112)];
    }];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Promote the touched view
    [self.view bringSubviewToFront:_dareTextImageOverlay];
    
    // Remember original location
    _lastLocation = _dareTextImageOverlay.center;
}

- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
   // [self cropImageToOverlay];

    CGPoint translation = [uigr translationInView:_dareTextImageOverlay.superview];
    
    if (_dareTextImageOverlay.frame.origin.y <= _cameraView.frame.origin.y  && translation.y < 0) {
       
        [UIView animateWithDuration:0.3 animations:^{
            _dareTextImageOverlay.frame = CGRectMake(0, _cameraView.frame.origin.y, _dareTextImageOverlay.frame.size.width, _dareTextImageOverlay.frame.size.height);
        }];
    }else if (CGRectGetMaxY(_dareTextImageOverlay.frame) >= CGRectGetMaxY(_cameraView.frame) && translation.y > 0){
        
        [UIView animateWithDuration:0.3 animations:^{
            _dareTextImageOverlay.frame = CGRectMake(0, _cameraView.frame.origin.y + (_cameraView.frame.size.height - _dareTextImageOverlay.frame.size.height), _dareTextImageOverlay.frame.size.width, _dareTextImageOverlay.frame.size.height);
        }];
    }else{
    _dareTextImageOverlay.center = CGPointMake(_imageView.center.x,
                                               _lastLocation.y + translation.y);
    }
}

- (UIImage *)cropImageToOverlay
{
    _dareTextImageOverlay.hidden = YES;
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *fullScreenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = CGImageCreateWithImageInRect([fullScreenshot CGImage], _dareTextImageOverlay.frame);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    _dareTextImageOverlay.hidden = NO;
    UIImageWriteToSavedPhotosAlbum(cropped, nil, nil, nil);
    return cropped;
}
- (IBAction)forwardButtonPressed:(id)sender
{
    
}

- (IBAction)backButtonPressed:(id)sender
{
}


- (void)setupCamera
{
    self.cameraManager = [[CameraManager alloc]init];
    self.cameraManager.captureSessionIsActive = YES;
    [self.cameraManager initializeCameraForImageView:self.imageView
                                             isFront:YES view:self.cameraView
                                             failure:^{[self selectPictureFromLibrary];}];
}

- (void)beginThread: (void(^)(PFObject *messageThread))completion
{
    [ParseClient createMessage:@"pet a dog" picture:[UIImage imageNamed:@"kitten.jpeg"] completion:^(PFObject *message) {
        [ParseClient startMessageThreadForUsers:self.friends
                                    withMessage:message
                                      withTitle:message[@"text"]
                                 backroundImage:[UIImage imageNamed:@"kitten.jpeg"]
                                     completion:^(PFObject *messageThread) {
                                         completion(messageThread);
                                     }];
    }];
}


- (void)setupFriendsCollection
{
    self.friendsCollection.backgroundColor = [UIColor DareBlue];
    //self.friendsCollection.bounces = NO;
    self.friendsCollection.delegate = self;
    self.friendsCollection.dataSource = self;
    self.friendsCollection.showsHorizontalScrollIndicator = NO;
}

- (void)setupTextCollection
{
    self.textCollection.backgroundColor = [UIColor DareBlue];
    self.textCollection.bounces = NO;
    self.textCollection.pagingEnabled = YES;
    self.textCollection.showsHorizontalScrollIndicator = NO;
    self.textCollection.delegate = self;
    self.textCollection.dataSource = self;
}


- (IBAction)cameraButtonPressed:(id)sender
{
    [self.cameraManager snapStillImageForImageView:self.imageView
                                           isFront:YES
                                              view:self.cameraView
                                        completion:^(UIImage *image) {
                                            NSLog(@"image snapped");
                                            
                                        } failure:^{
                                            [self selectPictureFromLibrary];
                                        }];
    
    _takeAPhotoOverlay.text = @"Tap here to use this image";
}


- (void)selectPictureFromLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}



#pragma collection view delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.friendsCollection) {
        return [self.images count];
    } else {
        return [self.messages count] + 1;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.friendsCollection) {
        CGFloat oneThirdOfDisplay = self.friendsCollection.frame.size.width/3;
        return CGSizeMake(oneThirdOfDisplay, collectionView.frame.size.height);
        
    } else {
        return CGSizeMake(self.textCollection.frame.size.width, self.textCollection.frame.size.width);
    }
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return -1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return -1.0;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView == self.friendsCollection) {
        FriendListIcon *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
        ((FriendListIcon*)cell).friendImage.image = self.images[indexPath.row];
        return cell;
    } else {
        SelectDareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectDareCell" forIndexPath:indexPath];
        ((SelectDareCell *)cell).messageLabel.textColor = [UIColor whiteColor];
        ((SelectDareCell *)cell).messageLabel.font = [UIFont boldSystemFontOfSize:20];
       
        if (indexPath.row == 0) {
            ((SelectDareCell *)cell).messageLabel.text = @"I DARE YOU TO...\ncreate your own";
        }else{
        ((SelectDareCell *)cell).messageLabel.text = self.messages[indexPath.row - 1];
        }
        return cell;
    }
}





@end
