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


@interface NewDareViewController () <UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CameraManager *cameraManager;

@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollection;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (weak, nonatomic) IBOutlet UICollectionView *textCollection;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *messages;



@end

@implementation NewDareViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFObject *messageOne = [PFObject objectWithClassName:@"Message"];
    [messageOne addObject:@"I DARE YOU\n to code the killer app" forKey:@"text"];
    UIImage *imageOne = [UIImage imageNamed:@"mesOne.jpeg"];
    NSData *imageDataOne = UIImagePNGRepresentation(imageOne);
    PFFile *fileOne = [PFFile fileWithName:@"userPic" data:imageDataOne];
    [fileOne saveInBackground];
    [messageOne addObject:fileOne forKey:@"picture"];
    [messageOne save];
    
    self.images = @[[UIImage imageNamed:@"angry.jpeg"], [UIImage imageNamed:@"tricolor.jpeg"], [UIImage imageNamed:@"kitten.jpeg"], [UIImage imageNamed:@"cat.jpeg"]];
    self.messages = @[@"I DARE YOU\nto pet a cat", @"I DARE YOU\nto eat icecream", @"I DARE YOU\nto have fun"];
    
//    [ParseClient getUser:[PFUser currentUser] completion:^(User *loggedUser) {
//        [ParseClient startMessageThreadForUsers:loggedUser.friends withMessage:messageOne withTitle:<#(NSString *)#> backroundImage:<#(UIImage *)#> completion:<#^(void)completion#>]
//    } failure:nil];
    
    
    _imageView.backgroundColor = [UIColor DareBlue];
    _cameraView.backgroundColor = [UIColor DareBlue];
    self.imageView.hidden = YES;
    [self.view bringSubviewToFront:self.cameraButton];
    [self setupCamera];
    [self setupFriendsCollection];
    [self setupTextCollection];
    
    UINib *dareNib = [UINib nibWithNibName:@"SelectDareCell" bundle:nil];
    [self.textCollection registerNib:dareNib forCellWithReuseIdentifier:@"SelectDareCell"];
    UINib *friendNib = [UINib nibWithNibName:@"FriendListIcon" bundle:nil];
    [self.friendsCollection registerNib:friendNib forCellWithReuseIdentifier:@"FriendCell"];
}

- (void)setupCamera
{
    self.cameraManager = [[CameraManager alloc]init];
    self.cameraManager.captureSessionIsActive = YES;
    [self.cameraManager initializeCameraForImageView:self.imageView
                                             isFront:YES view:self.cameraView
                                             failure:^{[self selectPictureFromLibrary];}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)setupFriendsCollection
{
    self.friendsCollection.backgroundColor = [UIColor blackColor];
    self.friendsCollection.bounces = NO;
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
        return [self.messages count];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.friendsCollection) {
        CGFloat oneThirdOfDisplay = self.friendsCollection.frame.size.width/3;
        return CGSizeMake(oneThirdOfDisplay, oneThirdOfDisplay);
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
    return 0;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView == self.friendsCollection) {
        FriendListIcon *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
        ((FriendListIcon*)cell).friendImage.image = self.images[indexPath.row];
        return cell;
    } else {
        SelectDareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectDareCell" forIndexPath:indexPath];
        ((SelectDareCell *)cell).messageLabel.text = self.messages[indexPath.row];
        return cell;
    }
}





@end
