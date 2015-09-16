//
//  BUGImageEditer.m
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import "BUGImageEditor.h"

@interface BUGImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@interface BUGImageEditor ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSArray<NSData *> *images;

@property (nonatomic, strong) UIViewController *editorViewController;

@property (nonatomic, strong) UICollectionView *editorCollectionView;

@property (nonatomic, strong) UIBarButtonItem *plusBarButtonItem;

@end

@implementation BUGImageEditor

- (void)showEditorViewControllerWithImages:(NSArray<NSData *> *)images
                      navigationController:(UINavigationController *)navigationController {
    self.images = images;
    [self.editorCollectionView reloadData];
    [navigationController pushViewController:self.editorViewController animated:YES];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    BUGImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                                 forIndexPath:indexPath];
    if (indexPath.row < [self.images count]) {
        cell.imageView.image = [UIImage imageWithData:self.images[indexPath.row]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
}

#pragma mark - Add

- (void)handlePlusBarButtonItemTapped {
    static UIImagePickerController *imagePickerController;
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self.editorViewController presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.images = [self.images arrayByAddingObject:UIImageJPEGRepresentation(image, 0.8)];
    [self.editorCollectionView reloadData];
    [self.editorCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.images count] - 1 inSection:0]
                                      atScrollPosition:UICollectionViewScrollPositionRight
                                              animated:NO];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.delegate imageEditorDidChangedImages:self.images];
}

#pragma mark - Getter

- (UIViewController *)editorViewController {
    if (_editorViewController == nil) {
        _editorViewController = [[UIViewController alloc] init];
        _editorViewController.title = @"图片附件";
        _editorViewController.navigationItem.rightBarButtonItem = self.plusBarButtonItem;
        self.editorCollectionView.frame = _editorViewController.view.bounds;
        [_editorViewController.view addSubview:self.editorCollectionView];
    }
    return _editorViewController;
}

- (UICollectionView *)editorCollectionView {
    if (_editorCollectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        flowLayout.minimumLineSpacing = 0.0;
        flowLayout.minimumInteritemSpacing = 0.0;
        _editorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _editorCollectionView.pagingEnabled = YES;
        _editorCollectionView.showsHorizontalScrollIndicator = NO;
        _editorCollectionView.backgroundColor = [UIColor whiteColor];
        _editorCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _editorCollectionView.delegate = self;
        _editorCollectionView.dataSource = self;
        [_editorCollectionView registerClass:[BUGImageCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    }
    return _editorCollectionView;
}

- (UIBarButtonItem *)plusBarButtonItem {
    if (_plusBarButtonItem == nil) {
        _plusBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(handlePlusBarButtonItemTapped)];
    }
    return _plusBarButtonItem;
}

@end

@implementation BUGImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.frame = self.bounds;
        [self addSubview:self.imageView];
    }
    return self;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _imageView;
}

@end