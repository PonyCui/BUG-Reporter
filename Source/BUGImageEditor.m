//
//  BUGImageEditer.m
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import "BUGImageEditor.h"
#import "BUGImagePainterView.h"

@protocol BUGImageCollectionViewCellDelegate <NSObject>

- (void)cellDidEditedImage:(UIImage *)image cellIndex:(NSUInteger)cellIndex;

@end

@interface BUGImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<BUGImageCollectionViewCellDelegate> delegate;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIToolbar *toolBar;

@property (nonatomic, strong) NSArray *toolBarNormalItems;

@property (nonatomic, strong) NSArray *toolBarEditItems;

@property (nonatomic, strong) BUGImagePainterView *painterView;

- (void)updatePainterViewWithImageSize:(CGSize)imageSize;

@end

@interface BUGImageEditor ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BUGImageCollectionViewCellDelegate>

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
        cell.delegate = self;
        cell.tag = indexPath.row;
        cell.imageView.image = [UIImage imageWithData:self.images[indexPath.row]];
        [cell updatePainterViewWithImageSize:cell.imageView.image.size];
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

#pragma mark - Edit

- (void)cellDidEditedImage:(UIImage *)image cellIndex:(NSUInteger)cellIndex {
    if (cellIndex < [self.images count]) {
        NSMutableArray *images = [self.images mutableCopy];
        [images setObject:UIImageJPEGRepresentation(image, 1.0) atIndexedSubscript:cellIndex];
        self.images = images;
        [self.editorCollectionView reloadData];
        [self.delegate imageEditorDidChangedImages:self.images];
    }
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
        CGRect frame = self.bounds;
        frame.size.height -= 44.0;
        self.imageView.frame = frame;
        self.toolBar.frame = CGRectMake(0, self.bounds.size.height - 44.0, self.bounds.size.width, 44.0);
        [self addSubview:self.imageView];
        [self addSubview:self.toolBar];
    }
    return self;
}

- (void)handleEditButtonTapped {
    [self.imageView addSubview:self.painterView];
    self.toolBar.items = self.toolBarEditItems;
}

- (void)handleCancelButtonTapped {
    [self.painterView reset];
    [self.painterView removeFromSuperview];
    self.toolBar.items = self.toolBarNormalItems;
}

- (void)handleSaveButtonTapped {
    UIImage *image = [self.painterView mergeWithImage:self.imageView.image];
    [self.delegate cellDidEditedImage:image cellIndex:self.tag];
    [self.painterView reset];
    [self.painterView removeFromSuperview];
    self.toolBar.items = self.toolBarNormalItems;
}

- (void)updatePainterViewWithImageSize:(CGSize)imageSize {
    self.painterView.frame = [self imageRectWithSize:imageSize];
}

- (CGRect)imageRectWithSize:(CGSize)size {
    if (size.width > size.height) {
        CGRect rect = CGRectZero;
        rect.size.height = CGRectGetWidth(self.imageView.bounds) * size.height / size.width;
        rect.origin.y = (CGRectGetHeight(self.imageView.bounds) - rect.size.height) / 2.0;
        rect.size.width = CGRectGetWidth(self.imageView.bounds);
        return rect;
    }
    else if (size.width < size.height) {
        CGRect rect = CGRectZero;
        rect.size.width = CGRectGetHeight(self.imageView.bounds) * size.width / size.height;
        rect.origin.x = (CGRectGetWidth(self.imageView.bounds) - rect.size.width) / 2.0;
        rect.size.height = CGRectGetHeight(self.imageView.bounds);
        return rect;
    }
    else {
        return self.imageView.bounds;
    }
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (UIToolbar *)toolBar {
    if (_toolBar == nil) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44.0)];
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_toolBar setItems:self.toolBarNormalItems];
    }
    return _toolBar;
}

- (NSArray *)toolBarNormalItems {
    if (_toolBarNormalItems == nil) {
        UIBarButtonItem *leftSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(handleEditButtonTapped)];
        UIBarButtonItem *rightSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _toolBarNormalItems = @[leftSpaceItem, editItem, rightSpaceItem];
    }
    return _toolBarNormalItems;
}

- (NSArray *)toolBarEditItems {
    if (_toolBarEditItems == nil) {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"放弃" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelButtonTapped)];
        UIBarButtonItem *middleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(handleSaveButtonTapped)];
        _toolBarEditItems = @[cancelItem, middleSpaceItem, saveItem];
    }
    return _toolBarEditItems;
}

- (BUGImagePainterView *)painterView {
    if (_painterView == nil) {
        _painterView = [[BUGImagePainterView alloc] initWithFrame:CGRectZero];
        _painterView.userInteractionEnabled = YES;
    }
    return _painterView;
}

@end