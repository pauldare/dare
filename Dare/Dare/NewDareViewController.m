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
#import "CanelDareCell.h"
#import "ParseClient.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "MainScreenViewController.h"
#import "Friend+Methods.h"
#import "DareDataStore.h"
#import "Friend+Methods.h"
#import "MessageThread+Methods.h"
#import "Message+Methods.h"



@interface NewDareViewController () <UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CameraManager *cameraManager;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *flipButton;

@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollection;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (weak, nonatomic) IBOutlet UICollectionView *textCollection;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSArray *messages;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) UIView *dareTextImageOverlay;
@property (strong, nonatomic) UILabel *bottomOverlay;
@property (strong, nonatomic) UITextField *dareText;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureOnImageOverlay;
@property (strong, nonatomic) UITapGestureRecognizer *tapContinueToSetBackgroundPhoto;
@property (strong, nonatomic) UITapGestureRecognizer *tapToSetBackgroundImage;
@property (strong, nonatomic) UITapGestureRecognizer *tapGetGoing;
@property (strong, nonatomic) NSString *dareString;
@property (strong, nonatomic) UIImage *dareBackgroundImage;
@property (strong, nonatomic) UIImage *dareImage;
@property (strong, nonatomic) DareDataStore *dataStore;
@property (strong, nonatomic) NSArray *parseFriends;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;




@end

@implementation NewDareViewController


- (void)viewDidLoad
{
    self.images = [[NSMutableArray alloc]init];
    [super viewDidLoad];
    self.dataStore = [DareDataStore sharedDataStore];
    
    self.coverView.backgroundColor = [UIColor DareCellOverlay];
    [self.view sendSubviewToBack:self.coverView];
    
    [self fetchFriends:^{
        for (Friend *friend in self.friends) {
            [self.images addObject:[UIImage imageWithData:friend.image]];
        }
        [self.friendsCollection reloadData];
    }];
        
//    self.images = @[[UIImage imageNamed:@"angry.jpeg"], [UIImage imageNamed:@"tricolor.jpeg"], [UIImage imageNamed:@"kitten.jpeg"], [UIImage imageNamed:@"cat.jpeg"]];
    
    self.messages = @[@"I DARE YOU\nto pet a cat", @"I DARE YOU\nto eat icecream", @"I DARE YOU\nto have fun"];
    
    //_imageView.frame = _cameraView.frame;
    _imageView.backgroundColor = [UIColor whiteColor];
    _cameraView.backgroundColor = [UIColor whiteColor];
    self.imageView.hidden = YES;
    //_imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _cameraButton.hidden = YES;
        _flipButton.hidden = YES;
    }
    
    [_albumButton addTarget:self action:@selector(selectPictureFromPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];
    [_flipButton addTarget:self action:@selector(flipCamera) forControlEvents:UIControlEventTouchUpInside];
    
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
    [_forwardButton addTarget:self action:@selector(scrollForward) forControlEvents:UIControlEventTouchUpInside];
    
    FAKFontAwesome *leftLabel = [FAKFontAwesome backwardIconWithSize:40];
    [leftLabel addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftLabelImage = [leftLabel imageWithSize:CGSizeMake(40, 40)];
    [_backButton setTitle:@"" forState:UIControlStateNormal];
    [_backButton setTintColor:[UIColor whiteColor]];
    [_backButton setImage:leftLabelImage forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(scrollBackward) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self setupCamera];
    [self setupFriendsCollection];
    [self setupTextCollection];
    [self setupImageOverlay];

    UINib *dareNib = [UINib nibWithNibName:@"SelectDareCell" bundle:nil];
    [self.textCollection registerNib:dareNib forCellWithReuseIdentifier:@"SelectDareCell"];
    UINib *friendNib = [UINib nibWithNibName:@"FriendListIcon" bundle:nil];
    [self.friendsCollection registerNib:friendNib forCellWithReuseIdentifier:@"FriendCell"];
    
    UINib *cancelNib = [UINib nibWithNibName:@"CancelDareCell" bundle:nil];
    [self.friendsCollection registerNib:cancelNib forCellWithReuseIdentifier:@"CancelDareCell"];
    
    [self.view bringSubviewToFront:self.forwardButton];
    [self.view bringSubviewToFront:self.backButton];
    [self configureBottomOverlay];
    _bottomOverlay.text = @"Take a photo or choose one";
}

-(void)flipCamera
{
    if (_cameraManager.session) {
        [_cameraManager.session beginConfiguration];
        AVCaptureInput* currentCameraInput = [_cameraManager.session.inputs objectAtIndex:0];
        [_cameraManager.session removeInput:currentCameraInput];
        
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
        //Add input to session
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        [_cameraManager.session addInput:newVideoInput];
        
        //Commit all the configuration changes at once
        [_cameraManager.session commitConfiguration];
        
    }

}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

- (void)fetchFriends: (void(^)())completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    self.friends = [NSMutableArray arrayWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
    Friend *friend = self.friends[0];
    NSLog(@"%@", friend.displayName);
    completion();
}


-(void)configureBottomOverlay
{
    
    _bottomOverlay = [[UILabel alloc]init];
    _bottomOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomOverlay.backgroundColor = [UIColor DareBlue];
    _bottomOverlay.textColor = [UIColor whiteColor];
    _bottomOverlay.text = @"";
    _bottomOverlay.font = [UIFont boldSystemFontOfSize:20];
    _bottomOverlay.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_bottomOverlay];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomOverlay attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_textCollection attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomOverlay attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_textCollection attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomOverlay attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_textCollection attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomOverlay attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_textCollection attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    
    [self.view bringSubviewToFront:_bottomOverlay];
    _textCollection.hidden = YES;
    _backButton.hidden = YES;
    _forwardButton.hidden = YES;
}


-(void)setupImageOverlay
{
    _dareTextImageOverlay = [[UIView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height, _imageView.frame.size.width, 80)];
    _dareTextImageOverlay.backgroundColor = [UIColor DareCellOverlay];
    [self.view addSubview:_dareTextImageOverlay];
    //[self performSelector:@selector(moveOverlayIntoView) withObject:self afterDelay:3.0];
    _panGestureOnImageOverlay = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_dareTextImageOverlay addGestureRecognizer:_panGestureOnImageOverlay];
    
    //    UITapGestureRecognizer *tapOnImageOverlay = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cropImageToOverlay)];
    //    tapOnImageOverlay.numberOfTapsRequired = 1;
    //    [tapOnImageOverlay requireGestureRecognizerToFail:panRecognizer];
    //    [_dareTextImageOverlay addGestureRecognizer:tapOnImageOverlay];
    
    _dareText = [[UITextField alloc]init];
    _dareText.delegate = self;
    _dareText.userInteractionEnabled = NO;
    _dareText.textAlignment = NSTextAlignmentCenter;
    _dareText.translatesAutoresizingMaskIntoConstraints = NO;
    _dareText.backgroundColor = [UIColor clearColor];
    _dareText.font = [UIFont boldSystemFontOfSize:15];
    _dareText.textColor = [UIColor whiteColor];
    [_dareTextImageOverlay addSubview:_dareText];
    
    [_dareTextImageOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_dareText attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_dareTextImageOverlay attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [_dareTextImageOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_dareText attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_dareTextImageOverlay attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [_dareTextImageOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_dareText attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_dareTextImageOverlay attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [_dareTextImageOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_dareText attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_dareTextImageOverlay attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_cameraManager.session stopRunning];
    _cameraManager.captureSessionIsActive = NO;
    [_cameraManager.captureVideoPreviewLayer removeFromSuperlayer];
    _imageView.image = info[UIImagePickerControllerEditedImage];
    _imageView.hidden = NO;
    NSLog(@"%@", _imageView);
    _cameraView.hidden = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
    _flipButton.hidden = YES;
    [self tapToUsePhoto];
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
    [_dareText resignFirstResponder];
    
    //_dareText.text = @"Tap to set";
    //_bottomOverlay.text = @"Drag to select a background";
    
    CGPoint translation = [uigr translationInView:_dareTextImageOverlay.superview];
    
    if (_dareTextImageOverlay.frame.origin.y <= _cameraView.frame.origin.y  && translation.y < 0) {
        
        [UIView animateWithDuration:0.3 animations:^{
            _dareTextImageOverlay.frame = CGRectMake(0, _cameraView.frame.origin.y, _dareTextImageOverlay.frame.size.width, _dareTextImageOverlay.frame.size.height);
            //[_dareTextImageOverlay updateConstraintsIfNeeded];
        }];
    }else if (CGRectGetMaxY(_dareTextImageOverlay.frame) >= CGRectGetMaxY(_cameraView.frame) && translation.y > 0){
        
        [UIView animateWithDuration:0.3 animations:^{
            _dareTextImageOverlay.frame = CGRectMake(0, _cameraView.frame.origin.y + (_cameraView.frame.size.height - _dareTextImageOverlay.frame.size.height), _dareTextImageOverlay.frame.size.width, _dareTextImageOverlay.frame.size.height);
            // [_dareTextImageOverlay updateConstraintsIfNeeded];
        }];
    }else{
        _dareTextImageOverlay.center = CGPointMake(_imageView.center.x,
                                                   _lastLocation.y + translation.y);
        //[_dareTextImageOverlay updateConstraintsIfNeeded];
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
    //UIImageWriteToSavedPhotosAlbum(cropped, nil, nil, nil);
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
                                             failure:^{_flipButton.hidden = YES; _cameraButton.hidden = YES;}];
}



- (void)setupFriendsCollection
{
    self.friendsCollection.backgroundColor = [UIColor DareBlue];
    self.friendsCollection.delegate = self;
    self.friendsCollection.dataSource = self;
    self.friendsCollection.showsHorizontalScrollIndicator = NO;
}

- (void)setupTextCollection
{
    self.textCollection.backgroundColor = [UIColor DareBlue];
    self.textCollection.bounces = YES;
    self.textCollection.alwaysBounceHorizontal = YES;
    self.textCollection.pagingEnabled = YES;
    self.textCollection.showsHorizontalScrollIndicator = NO;
    self.textCollection.delegate = self;
    self.textCollection.dataSource = self;
}

-(void)scrollForward
{
    [_textCollection setContentOffset:CGPointMake(_textCollection.contentOffset.x + _textCollection.frame.size.width, 0) animated:YES];
}

-(void)scrollBackward
{
    [_textCollection setContentOffset:CGPointMake(_textCollection.contentOffset.x - _textCollection.frame.size.width, 0) animated:YES];
}
- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == _textCollection) {
        
        if (scrollView.contentOffset.x < scrollView.frame.size.width ){
            
            [scrollView scrollRectToVisible:CGRectMake(scrollView.contentOffset.x + ([_messages count] + 1) * scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height) animated:YES];
            
            
        }
        
        else if ( scrollView.contentOffset.x > [_messages count] + 1 *  scrollView.frame.size.width  ){
            
            [scrollView scrollRectToVisible:CGRectMake(scrollView.contentOffset.x - (([_messages count] +1) * scrollView.frame.size.width), 0, scrollView.frame.size.width, scrollView.frame.size.height) animated:YES];
            
        }
    }
    
}

- (IBAction)cameraButtonPressed:(id)sender
{
    if (self.cameraManager.captureSessionIsActive) {
        [self.cameraManager snapStillImageForImageView:self.imageView
                                               isFront:YES
                                                  view:self.cameraView
                                            completion:^(UIImage *image) {
                                                NSLog(@"image snapped");
                                                
                                            } failure:^{
                                                [self selectPictureFromPhotoLibrary];
                                            }];
        _flipButton.hidden = YES;
        [self tapToUsePhoto];
    }else{
        _flipButton.hidden = NO;
        _imageView.image = nil;
        [_cameraManager.captureVideoPreviewLayer removeFromSuperlayer];
        [self setupCamera];
        _bottomOverlay.text = @"Take a photo or choose one";
        
    }
    
}

-(void)tapToUsePhoto
{
    _bottomOverlay.text = @"Tap here to use this image";
    _bottomOverlay.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapToUsePhoto = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(useImage)];
    tapToUsePhoto.numberOfTapsRequired = 1;
    [_bottomOverlay addGestureRecognizer:tapToUsePhoto];
}

-(void)useImage
{
    _bottomOverlay.hidden = YES;
    _albumButton.hidden = YES;
    _flipButton.hidden = YES;
    _cameraButton.hidden = YES;
    _backButton.hidden = NO;
    _forwardButton.hidden = NO;
    _textCollection.hidden = NO;
    
}

- (void)selectPictureFromPhotoLibrary
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
        return [self.images count] + 1;
    } else {
        return [self.messages count] + 1;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.friendsCollection) {
        CGFloat oneThirdOfDisplay = self.friendsCollection.frame.size.width/3;
        NSLog(@"%f %f",oneThirdOfDisplay,collectionView.frame.size.height);
        return CGSizeMake(oneThirdOfDisplay, collectionView.frame.size.height);
    } else {
        return CGSizeMake(self.textCollection.frame.size.width, self.textCollection.frame.size.width);
    }
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return -1.0;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView == self.friendsCollection) {
        
        if (indexPath.row == [self.images count]) {
            CanelDareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CancelDareCell" forIndexPath:indexPath];
            FAKFontAwesome *cancelIcon = [FAKFontAwesome bombIconWithSize:80];
            [cancelIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
            cell.cancelImage.image = [cancelIcon imageWithSize:CGSizeMake(80, 80)];
            cell.cancelLabel.text = @"Cancel";
            cell.backgroundColor = [UIColor DareBlue];
            cell.cancelImage.backgroundColor = [UIColor DareBlue];
            return cell;
        }else{
            FriendListIcon *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
            ((FriendListIcon*)cell).friendImage.image = self.images[indexPath.row];
            return cell;
        }
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView == _textCollection) {
        
        [self configureBottomOverlay];
        _panGestureOnImageOverlay.enabled = NO;
        _tapContinueToSetBackgroundPhoto = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(continueToSetBackgroundPhoto)];
        _tapContinueToSetBackgroundPhoto.numberOfTapsRequired = 1;
        _bottomOverlay.userInteractionEnabled = YES;
        [_bottomOverlay addGestureRecognizer:_tapContinueToSetBackgroundPhoto];
        
        _bottomOverlay.text = @"Continue";
        
        [self moveOverlayIntoView];
        
        if (indexPath.row == 0) {
            _dareText.text = @"I DARE YOU TO ";
            _dareText.returnKeyType = UIReturnKeyDone;
            _dareText.userInteractionEnabled = YES;
            _dareTextImageOverlay.userInteractionEnabled = YES;
            [_dareText becomeFirstResponder];
            NSLog(@"%@",((SelectDareCell*)[_textCollection cellForItemAtIndexPath:indexPath]).messageLabel.text);
        }else{
            _dareText.text = ((SelectDareCell*)[_textCollection cellForItemAtIndexPath:indexPath]).messageLabel.text;
            _dareString = _dareText.text;
            _dareText.userInteractionEnabled = NO;
            UITapGestureRecognizer *tapOnPredeterminedDare = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDareSelection)];
            tapOnPredeterminedDare.numberOfTapsRequired = 1;
            [_dareTextImageOverlay addGestureRecognizer:tapOnPredeterminedDare];
            _dareTextImageOverlay.userInteractionEnabled = YES;
        }
    }else if (collectionView == _friendsCollection){
        if (indexPath.row == ([collectionView numberOfItemsInSection:0] -1)) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            UINavigationController *mainVCNavController = [storyboard instantiateViewControllerWithIdentifier:@"MainNavController"];
            MainScreenViewController *mainView = (MainScreenViewController*)mainVCNavController.view;
            mainView.fromCancel = YES;
            [self presentViewController:mainVCNavController animated:YES completion:nil];
        }
    }
}

-(void)showDareSelection
{
    _textCollection.hidden = NO;
    _backButton.hidden = NO;
    _forwardButton.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        _dareTextImageOverlay.frame = CGRectMake(0, self.view.frame.size.height, _dareTextImageOverlay.frame.size.width, _dareTextImageOverlay.frame.size.height);
        _bottomOverlay.alpha = 0;
    } completion:^(BOOL finished) {
        _bottomOverlay = nil;
    }];
}

-(void)continueToSetBackgroundPhoto
{
    _dareText.userInteractionEnabled = NO;
    _dareText.enabled = NO;
    _panGestureOnImageOverlay.enabled = YES;
    [_bottomOverlay removeGestureRecognizer:_tapContinueToSetBackgroundPhoto];
    _dareText.text = @"Drag to set background";
    _bottomOverlay.text = @"Continue";
    _tapContinueToSetBackgroundPhoto = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(setBackgroundImageForDare)];
    _tapContinueToSetBackgroundPhoto.numberOfTapsRequired = 1;
    [_bottomOverlay addGestureRecognizer:_tapContinueToSetBackgroundPhoto];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _dareTextImageOverlay.frame = CGRectMake(0, _cameraView.center.y - (_dareTextImageOverlay.frame.size.height/2), _dareTextImageOverlay.frame.size.width, _dareTextImageOverlay.frame.size.height);
    }];
    
    
}

-(void)setBackgroundImageForDare
{
    _dareBackgroundImage = [self cropImageToOverlay];
    _dareImage = _imageView.image;
    
    _dareText.text = _dareString;
    _bottomOverlay.text = @"Get Going";
    _tapGetGoing = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(postDare)];
    _tapGetGoing.numberOfTapsRequired = 1;
    [_bottomOverlay addGestureRecognizer:_tapGetGoing];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    _dareString = textField.text;
    return YES;
}

- (void)beginThread: (void(^)(PFObject *messageThread))completion
{
    [ParseClient createMessage:_dareString picture:_dareImage completion:^(PFObject *message) {
        [ParseClient startMessageThreadForUsers:self.parseFriends
                                    withMessage:message
                                      withTitle:message[@"text"]
                                 backroundImage:_dareBackgroundImage
                                     completion:^(PFObject *messageThread) {
                                         
                                         MessageThread *newThread = [NSEntityDescription insertNewObjectForEntityForName:@"MessageThread"
                                                                                                  inManagedObjectContext:self.dataStore.managedObjectContext];
                                         newThread.identifier = messageThread.objectId;
                                         newThread.title = messageThread[@"title"];
                                         PFFile *imageFile = messageThread[@"backgroundImage"];
                                         [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                             newThread.backgroundPicture = data;
                                         }];
                                         PFFile *authorImage = messageThread[@"author"];
                                         [authorImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                             newThread.author = data;
                                         }];
                                         newThread.createdAt = messageThread.createdAt;

                                         Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
                                                                                                  inManagedObjectContext:self.dataStore.managedObjectContext];
                                         newMessage.identifier = message.objectId;
                                         newMessage.text = message[@"text"];
                                         PFFile *messageImageFile = message[@"picture"];
                                         [messageImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                             newMessage.picture = data;
                                         }];

                                         PFFile *messageAuthorImage = message[@"author"];
                                         [messageAuthorImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                             newMessage.author = data;
                                         }];
                                         newMessage.createdAt = message.createdAt;
                                         newMessage.isRead = @0;
                                         [newThread addMessagesObject:newMessage];
                                         [self.dataStore saveContext];
                                         
                                         completion(messageThread);
                                }];
    }];
}

- (void)fetchParseFriends: (void(^)())completion failure: (void(^)())failure
{
    for (Friend *friend in self.friends) {
        PFQuery *friendQuery = [PFUser query];
        [friendQuery whereKey:@"fbId" equalTo:friend.identifier];
        [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.parseFriends = objects;
                completion();
            } else {
                failure();
            }
        }];
    }
}


- (void)sendPush
{
    for (PFUser *parseUser in self.parseFriends) {
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"fbId" equalTo:parseUser[@"fbId"]];
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" matchesQuery:userQuery];
        //Send push to these users
        PFPush *push = [[PFPush alloc] init];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"New message from %@", [PFUser currentUser].username], @"alert",
                              @"Increment", @"badge",
                              nil];
        [push setQuery:pushQuery];
        [push setData:data];
        [push sendPushInBackground];
    }
}




-(void)postDare
{
    [self fetchParseFriends:^{
        _tapGetGoing.enabled = NO;
        [self.view bringSubviewToFront:self.coverView];
        [self beginThread:^(PFObject *messageThread) {
            //[self sendPush];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            UINavigationController *mainScreenNavController = [storyBoard instantiateViewControllerWithIdentifier:@"MainNavController"];
            MainScreenViewController *mainScreen = mainScreenNavController.viewControllers[0];
            mainScreen.fromCancel = NO;
            mainScreen.fromNew = YES;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
            mainScreen.threads = [[NSMutableArray alloc]initWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
            [self presentViewController:mainScreenNavController animated:YES completion:nil];
        }];
    } failure:nil];
}

@end
