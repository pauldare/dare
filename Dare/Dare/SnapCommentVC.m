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
#import "MessagesTVC.h"
#import "MessageThread+Methods.h"
#import "MainScreenViewController.h"


@interface SnapCommentVC ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
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
@property (nonatomic) BOOL imageWillBlur;
@property (nonatomic) NSInteger blurCounter;
@property (weak, nonatomic) IBOutlet UILabel *blurCounterLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) NSMutableArray *messages;
@property (nonatomic) BOOL isSelectingBlurTime;
@property (strong, nonatomic) UIPickerView *blurTimePicker;
@property (strong, nonatomic) UILabel *blurLabel;

- (IBAction)sendButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)photoLibraryButtonTapped:(id)sender;


@end

@implementation SnapCommentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isSelectingBlurTime = NO;
    self.dataStore = [DareDataStore sharedDataStore];
    self.messages = [[NSMutableArray alloc]initWithArray:[self.thread.messages allObjects]];
    self.friends = [[NSMutableArray alloc]init];
    self.imageWillBlur = NO;
    self.view.backgroundColor = [UIColor DareBlue];
    [self.flipButton addTarget:self action:@selector(flipCamera) forControlEvents:UIControlEventTouchUpInside];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self fetchFriends:^{
        [self.collectionView reloadData];
    }];
    [self setupViews];
    [self setupButtons];
    _imageView.backgroundColor = [UIColor whiteColor];
    _cameraView.backgroundColor = [UIColor whiteColor];
    //self.imageView.hidden = YES;
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
    
    _cameraView = [[UIView alloc]init];
    
    _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_cameraView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    _textLabel.text = _thread.title;
    
    [self.view bringSubviewToFront:_cameraView];
    [self.view bringSubviewToFront:self.dareTextImageOverlay];
    self.blurTimePicker = [[UIPickerView alloc]initWithFrame:CGRectMake(130, 0, 135, self.dareTextImageOverlay.frame.size.height)];
    self.blurTimePicker.hidden = YES;
    [self setupCamera];
    
    
    
}

- (void)fetchFriends: (void(^)())completion
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    self.friends = [NSMutableArray arrayWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
    completion();
}


- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor DareBlue];
    self.blurLabel = [[UILabel alloc]init];
    self.blurLabel.hidden = YES;
    self.dareView.backgroundColor = [UIColor DareCellOverlay];
    self.textLabel.backgroundColor = [UIColor DareCellOverlay];
    self.textLabel.font = [UIFont boldSystemFontOfSize:18];
    self.textLabel.textColor = [UIColor whiteColor];
    self.dareTextImageOverlay = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 100)];
    self.dareTextImageOverlay.backgroundColor = [UIColor DareTranslucentBlue];
    [self.view addSubview:self.dareTextImageOverlay];
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
    
    self.sendButton =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:72];
    self.sendButton.tintColor = [UIColor greenColor];
    [self.sendButton setTitle:@"✓" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.frame = CGRectMake(120, 20, 80, 80);
    [self.dareTextImageOverlay addSubview:self.sendButton];
    
    [_cameraButton setTintColor:[UIColor DareBlue]];
    [_flipButton setTintColor:[UIColor DareBlue]];
    [_albumButton setTintColor:[UIColor DareBlue]];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancelButton setTitle:@"X" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:60];
    [self.cancelButton setTintColor:[UIColor DareUnreadBadge]];
    self.cancelButton.frame = CGRectMake(20, 20, 80, 80);
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.dareTextImageOverlay addSubview:self.cancelButton];
    
    self.blurTimerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.blurTimerButton.frame = CGRectMake(self.view.frame.size.width - 80, 20, 60, 60);
    self.blurTimerButton.tintColor = [UIColor whiteColor];
    [self.blurTimerButton addTarget:self action:@selector(blurButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    FAKFontAwesome *cancelIcon = [FAKFontAwesome bombIconWithSize:80];
    [cancelIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [self.blurTimerButton setImage:[cancelIcon imageWithSize:CGSizeMake(80, 80)] forState:UIControlStateNormal];
    [self.dareTextImageOverlay addSubview:self.blurTimerButton];
}

- (void)setupCamera
{
    [self.view layoutIfNeeded];
    self.blurTimerButton.hidden = YES;
    self.sendButton.hidden = YES;
    [self.view bringSubviewToFront:_cameraButton];
    [self.view bringSubviewToFront:_albumButton];
    [self.view bringSubviewToFront:_flipButton];
    [self.view bringSubviewToFront:_blurTimerButton];
    _flipButton.hidden = NO;
    self.cameraManager = [[CameraManager alloc]init];
    self.cameraManager.captureSessionIsActive = YES;
    [self.cameraManager initializeCameraForImageView:self.imageView
                                             isFront:YES
                                                view:self.cameraView
                                             failure:^{
                                                 [self selectPictureFromLibrary];
                                                 self.cameraView.hidden = YES;
                                                 self.imageView.hidden = NO;
                                                 _flipButton.hidden = YES;
                                             }];
}



- (IBAction)cameraButtonPressed:(id)sender
{
    self.cameraView.hidden = NO;
    self.imageView.image = nil;
    self.blurCounter = 0;
    self.imageWillBlur = NO;
    self.sendButton.hidden = YES;
    self.blurTimerButton.hidden = YES;
    if(_cameraManager.session.isRunning){
        _flipButton.hidden = YES;
    }else{
        _flipButton.hidden = NO;
    }
    AVCaptureInput* currentCameraInput;
    
    if (_cameraManager.session.isRunning) {
        
        currentCameraInput = [_cameraManager.session.inputs objectAtIndex:0];
    }
    
    [self.cameraManager snapStillImageForImageView:self.imageView
                                           isFront:YES
                                              view:self.cameraView
                                        completion:^(UIImage *image) {
                                            NSLog(@"image snapped");
                                            
                                            if (((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack) {
                                                self.imageView.image = image;
                                            }else{
                                                self.imageView.image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
                                            }
                                            self.cameraView.hidden = YES;
                                            self.blurTimerButton.hidden = NO;
                                            self.sendButton.hidden = NO;
                                            self.choosenImage = image;
                                        } failure:^{
                                            [self selectPictureFromLibrary];
                                            _flipButton.hidden = YES;
                                        }];
}

- (IBAction)blurButtonPressed:(id)sender
{
    self.isSelectingBlurTime = YES;
    
    if (self.imageView.image) {
        if (!self.imageWillBlur) {
            self.cancelButton.hidden = YES;
            self.blurTimerButton.hidden = YES;
            self.blurCounter = 0;
            [UIView animateWithDuration:0.2f animations:^{
                
                self.dareTextImageOverlay.frame = CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150);
                self.sendButton.frame = CGRectMake(self.view.frame.size.width - 60, 45, 60, 60);
            }];
            self.blurLabel.frame = CGRectMake(0, 0, 135, self.dareTextImageOverlay.frame.size.height);
            self.blurLabel.font = [UIFont boldSystemFontOfSize:30];
            self.blurLabel.hidden = NO;
            self.blurLabel.textColor = [UIColor whiteColor];
            self.blurLabel.numberOfLines = 2;
            self.blurLabel.text = @"Blur this image in";
            [self.dareTextImageOverlay addSubview:self.blurLabel];
            self.blurTimePicker.hidden = NO;
            self.blurTimePicker.delegate = self;
            self.blurTimePicker.dataSource = self;
            [self.dareTextImageOverlay addSubview:self.blurTimePicker];
            
            //self.blurCounterLabel.text = [NSString stringWithFormat:@"%lu",(long)self.blurCounter];
        }
    }
}


-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSMutableAttributedString *rowTitle = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%lu sec", ((long)row * 5)]];
    [rowTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, rowTitle.length)];
    [rowTitle addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:60] range:NSMakeRange(0, rowTitle.length)];
    return rowTitle;
    
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 13;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
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
    [_cameraManager.session stopRunning];
    _cameraManager.captureSessionIsActive = NO;
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imageView.image = image;
    self.choosenImage = image;
    self.imageView.hidden = NO;
    self.imageView.opaque = YES;
    self.cameraView.hidden = YES;
    self.blurTimerButton.hidden = NO;
    self.sendButton.hidden = NO;
    
}

-(void)moveOverlayIntoView
{
    [UIView animateWithDuration:0.3 animations:^{
        [_dareTextImageOverlay setFrame:CGRectMake(0, _cameraView.frame.origin.y + 60, _cameraView.frame.size.width, 112)];
    }];
}

//-(void)setupImageOverlay
//{
//    _dareTextImageOverlay = [[UIView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height, _imageView.frame.size.width, 80)];
//    _dareTextImageOverlay.backgroundColor = [UIColor DareCellOverlay];
//    [self.view addSubview:_dareTextImageOverlay];
//    
//    _dareText = [[UITextField alloc]init];
//    _dareText.delegate = self;
//    _dareText.userInteractionEnabled = YES;
//    _dareText.textAlignment = NSTextAlignmentCenter;
//    _dareText.translatesAutoresizingMaskIntoConstraints = NO;
//    _dareText.backgroundColor = [UIColor clearColor];
//    _dareText.font = [UIFont boldSystemFontOfSize:15];
//    _dareText.textColor = [UIColor whiteColor];
//    [_dareTextImageOverlay addSubview:_dareText];
//    
//    [_dareTextImageOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_dareText attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_dareTextImageOverlay attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
//    [_dareTextImageOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_dareText attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_dareTextImageOverlay attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
//    [_dareTextImageOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_dareText attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_dareTextImageOverlay attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
//    [_dareTextImageOverlay addConstraint:[NSLayoutConstraint constraintWithItem:_dareText attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_dareTextImageOverlay attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_dareText resignFirstResponder];
    //adds
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


- (void)addMessageToThread: (void(^)(Message *, MessageThread *))completion
{
    [ParseClient addMessageToThread:self.thread withText:@""
                            picture:self.choosenImage
                          blurTimer:self.blurCounter
                         completion:^(PFObject *message) {
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
                             [self.thread addMessagesObject:newMessage];
                             [self.dataStore saveContext];
                             
                             NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
                             NSString *searchID = self.thread.identifier;
                             NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"identifier==%@",searchID];
                             fetchRequest.predicate = searchPredicate;
                             NSArray *threads = [self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil];
                             MessageThread *thread = threads[0];
                             completion(newMessage, thread);
                         }];
}

- (IBAction)sendButtonTapped:(id)sender
{
    if (!self.isSelectingBlurTime) {
    __weak typeof(self) weakSelf = self;
    [self addMessageToThread:^(Message *message, MessageThread *thread) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        MessagesTVC *messagesTVC = [storyboard instantiateViewControllerWithIdentifier:@"MessagesTVC"];
        messagesTVC.thread = weakSelf.thread;
        [weakSelf presentViewController:messagesTVC animated:YES completion:nil];
    }];
    }else{
        self.isSelectingBlurTime = NO;
        self.imageWillBlur = YES;
        self.blurCounter = ([self.blurTimePicker selectedRowInComponent:0] * 5);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.dareTextImageOverlay.frame = CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 100);
            
            
        }];
        [UIView animateWithDuration:0.2 animations:^{
             self.sendButton.frame = CGRectMake(120, 20, 80, 80);
            self.blurTimePicker.alpha = 0;
            self.blurLabel.alpha = 0;
            
        } completion:^(BOOL finished) {
            self.blurTimePicker.hidden = YES;
            self.blurLabel.hidden = YES;
            self.blurTimerButton.hidden = NO;
            self.cancelButton.hidden = NO;
           
            [UIView animateWithDuration:0.2 animations:^{
                self.blurTimerButton.frame = CGRectMake(self.view.frame.size.width - 80, 20, 60, 60);
                self.cancelButton.frame = CGRectMake(20, 20, 80, 80);
            }];
            
        }];
        NSLog(@"Blur image in %lu seconds", (long)self.blurCounter);
    }
}

- (IBAction)cancelButtonTapped:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UINavigationController *mainViewNavController = [storyBoard instantiateViewControllerWithIdentifier:@"MainNavController"];
    MainScreenViewController *mainScreen = mainViewNavController.viewControllers[0];
    mainScreen.fromCancel = YES;
    mainScreen.fromNew = NO;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MessageThread"];
    mainScreen.threads = [[NSMutableArray alloc]initWithArray:[self.dataStore.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
    [self presentViewController:mainViewNavController animated:NO completion:nil];
}

- (IBAction)photoLibraryButtonTapped:(id)sender
{
    [self selectPictureFromLibrary];
    self.flipButton.hidden = YES;
}
@end
