//
//  SnapCommentVC.m
//  Dare
//
//  Created by Nadia on 7/5/14.
//  Copyright (c) 2014 Dare. All rights reserved.
//

#import "SnapCommentVC.h"
#import "FriendListIcon.h"
#import "UIColor+DareColors.h"
#import "CameraManager.h"
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "DareDataStore.h"
#import "Friend+Methods.h"
#import "ParseClient.h"


@interface SnapCommentVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *flipButton;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *blurTimerButton;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) CameraManager *cameraManager;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) DareDataStore *dataStore;
@property (strong, nonatomic) UIView *dareTextImageOverlay;
@property (strong, nonatomic) UITextField *dareText;
@property (strong, nonatomic) UIImage *choosenImage;
@property (weak, nonatomic) IBOutlet UIView *blurTimerOverlay;
@property (nonatomic) BOOL imageWillBlur;

@end

@implementation SnapCommentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataStore = [DareDataStore sharedDataStore];
    self.friends = [[NSMutableArray alloc]init];
    self.imageWillBlur = NO;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.blurTimerOverlay.backgroundColor = [UIColor DareBlue];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self fetchFriends:^{
    [self.collectionView reloadData];
    }];
    
    [self setupViews];
    [self setupCamera];
    [self setupButtons];
    _imageView.backgroundColor = [UIColor whiteColor];
    _cameraView.backgroundColor = [UIColor whiteColor];
    self.imageView.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (!self.imageView.image) {
        self.blurTimerButton.hidden = YES;
    }
    self.imageView.contentMode = UIViewContentModeScaleToFill;
//    self.images = @[[UIImage imageNamed:@"angry.jpeg"], [UIImage imageNamed:@"tricolor.jpeg"], [UIImage imageNamed:@"kitten.jpeg"], [UIImage imageNamed:@"cat.jpeg"]];
//    UIImage *flower = [UIImage imageNamed:@"flower.jpeg"];
//    self.dareImageView.image = flower;
    self.dareImageView.image = [UIImage imageWithData:self.thread.backgroundPicture];
    UINib *friendNib = [UINib nibWithNibName:@"FriendListIcon" bundle:nil];
    [self.collectionView registerNib:friendNib forCellWithReuseIdentifier:@"FriendCell"];
}

- (void)fetchFriends: (void(^)())completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    self.friends = [NSMutableArray arrayWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
    completion();
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor DareBlue];
    self.dareView.backgroundColor = [UIColor DareCellOverlay];
    self.textLabel.backgroundColor = [UIColor DareCellOverlay];
    self.textLabel.font = [UIFont boldSystemFontOfSize:18];
    self.textLabel.textColor = [UIColor whiteColor];
}


- (void)setupButtons
{
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
    
    [_cameraButton setTintColor:[UIColor DareBlue]];
    [_flipButton setTintColor:[UIColor DareBlue]];
    [_albumButton setTintColor:[UIColor DareBlue]];

}

- (void)setupCamera
{
    _cameraView = [[UIView alloc]initWithFrame:_imageView.frame];
    self.blurTimerOverlay.hidden = YES;
    [self.view addSubview:_cameraView];
    [self.view bringSubviewToFront:_cameraButton];
    [self.view bringSubviewToFront:_albumButton];
    [self.view bringSubviewToFront:_flipButton];
    [self.view bringSubviewToFront:_blurTimerButton];
    
    

    self.cameraManager = [[CameraManager alloc]init];
    self.cameraManager.captureSessionIsActive = YES;
        [self.cameraManager initializeCameraForImageView:self.imageView
                                             isFront:YES
                                                view:self.cameraView
                                             failure:^{
                                                 [self selectPictureFromLibrary];
                                                 self.cameraView.hidden = YES;
                                             }];
}



- (IBAction)cameraButtonPressed:(id)sender
{
    self.cameraView.hidden = NO;
    [self.cameraManager snapStillImageForImageView:self.imageView
                                           isFront:YES
                                              view:self.cameraView
                                        completion:^(UIImage *image) {
                                            NSLog(@"image snapped");
                                            self.imageView.image = image;
                                            self.cameraView.hidden = YES;
                                            self.blurTimerButton.hidden = NO;
                                             [self.view bringSubviewToFront:self.blurTimerOverlay];
                                            self.blurTimerOverlay.alpha = 0;
                                            self.blurTimerOverlay.hidden = NO;
                                            [self.view bringSubviewToFront:self.blurTimerButton];
                                            [UIView animateWithDuration:0.3 animations:^{
                                                self.blurTimerOverlay.alpha = 0.4;
                                            }];
                                            self.choosenImage = image;
                                        } failure:^{
                                            [self selectPictureFromLibrary];
                                        }];
}

- (IBAction)blurButtonPressed:(id)sender
{
//    [self setupImageOverlay];
//    [self moveOverlayIntoView];
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imageView.image = image;
    self.choosenImage = image;
    self.imageView.hidden = NO;
    self.imageView.opaque = YES;
    self.cameraView.hidden = YES;
}

-(void)moveOverlayIntoView
{
    [UIView animateWithDuration:0.3 animations:^{
        [_dareTextImageOverlay setFrame:CGRectMake(0, _cameraView.frame.origin.y + 60, _cameraView.frame.size.width, 112)];
    }];
}

-(void)setupImageOverlay
{
    _dareTextImageOverlay = [[UIView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height, _imageView.frame.size.width, 80)];
    _dareTextImageOverlay.backgroundColor = [UIColor DareCellOverlay];
    [self.view addSubview:_dareTextImageOverlay];
    
    _dareText = [[UITextField alloc]init];
    _dareText.delegate = self;
    _dareText.userInteractionEnabled = YES;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_dareText resignFirstResponder];    
    [ParseClient addMessageToThread:self.thread withText:_dareText.text picture:self.choosenImage completion:nil];
    return YES;
}


#pragma collection view delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.friends count];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat oneThirdOfDisplay = self.collectionView.frame.size.width/3;
    return CGSizeMake(oneThirdOfDisplay, collectionView.frame.size.height);
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
    FriendListIcon *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
    Friend *friend = self.friends[indexPath.row];
    UIImage *image = [UIImage imageWithData:friend.image];
    ((FriendListIcon *)cell).friendImage.image = image;
    return cell;
}


@end
