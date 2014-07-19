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
@property (nonatomic) NSInteger blurCounter;
@property (weak, nonatomic) IBOutlet UILabel *blurCounterLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) NSMutableArray *messages;
- (IBAction)sendButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)photoLibraryButtonTapped:(id)sender;


@end

@implementation SnapCommentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataStore = [DareDataStore sharedDataStore];
    self.messages = [[NSMutableArray alloc]initWithArray:[self.thread.messages allObjects]];
    self.friends = [[NSMutableArray alloc]init];
    self.imageWillBlur = NO;
    self.view.backgroundColor = [UIColor DareBlue];
    [self.flipButton addTarget:self action:@selector(flipCamera) forControlEvents:UIControlEventTouchUpInside];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.blurTimerOverlay.backgroundColor = [UIColor DareTranslucentBlue];
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
    
    FAKFontAwesome *cancelIcon = [FAKFontAwesome bombIconWithSize:35];
    _cancelButton.tintColor = [UIColor whiteColor];
    [cancelIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [_cancelButton setImage:[cancelIcon imageWithSize:CGSizeMake(35, 35)] forState:UIControlStateNormal];
    [_cancelButton setTitle:@"" forState:UIControlStateNormal];
    
    FAKFontAwesome *postIcon = [FAKFontAwesome commentIconWithSize:35];
    _sendButton.tintColor = [UIColor whiteColor];
    [postIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [_sendButton setImage:[postIcon imageWithSize:CGSizeMake(35, 35)] forState:UIControlStateNormal];
    [_sendButton setTitle:@"" forState:UIControlStateNormal];

    [_cameraButton setTintColor:[UIColor DareBlue]];
    [_flipButton setTintColor:[UIColor DareBlue]];
    [_albumButton setTintColor:[UIColor DareBlue]]; 
}

- (void)setupCamera
{
    [self.view layoutIfNeeded];
    self.blurTimerOverlay.hidden = YES;
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
    self.blurTimerOverlay.hidden = YES;
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
                                            self.choosenImage = image;
                                        } failure:^{
                                            [self selectPictureFromLibrary];
                                            _flipButton.hidden = YES;
                                        }];
}

- (IBAction)blurButtonPressed:(id)sender
{
    if (self.imageView.image) {
        if (!self.imageWillBlur) {
            self.blurTimerOverlay.hidden = NO;
            self.blurCounter = 5;
            self.blurCounterLabel.text = [NSString stringWithFormat:@"%lu",(long)self.blurCounter];
            self.imageWillBlur = YES;
            [self.view bringSubviewToFront:self.blurTimerOverlay];
            self.blurTimerOverlay.alpha = 0;
            self.blurTimerOverlay.hidden = NO;
            self.blurTimerOverlay.backgroundColor = [UIColor DareTranslucentBlue];
            [self.view bringSubviewToFront:self.blurTimerButton];
            [UIView animateWithDuration:0.3 animations:^{
                self.blurTimerOverlay.alpha = 1;
            }];
        }else{
            if (self.blurCounter < 30) {
                self.blurCounter += 5;
                self.blurCounterLabel.text = [NSString stringWithFormat:@"%lu",(long)self.blurCounter];
                
            }else{
                self.blurCounter = 0;
                self.imageWillBlur = NO;
                [UIView animateWithDuration:0.2 animations:^{
                    self.blurTimerOverlay.alpha = 0;
                } completion:^(BOOL finished) {
                    self.blurTimerOverlay.hidden = YES;
                }];
            }
        }
    }
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
    __weak typeof(self) weakSelf = self;
    [self addMessageToThread:^(Message *message, MessageThread *thread) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        MessagesTVC *messagesTVC = [storyboard instantiateViewControllerWithIdentifier:@"MessagesTVC"];
        messagesTVC.thread = weakSelf.thread;
        [weakSelf presentViewController:messagesTVC animated:YES completion:nil];
    }];
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
