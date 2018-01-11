//
//  BBMapDownloadBaseViewController.m
//  Boobuz
//
//  Created by xiaoyuan on 2018/1/4.
//  Copyright © 2018年 erlinyou.com. All rights reserved.
//

#import "BBMapDownloadBaseViewController.h"
#import "BBMapDownloadConst.h"
#import "BBMapDownloadSectionHeaderView.h"
#import "BBBaseTableViewCell.h"

@interface BBMapDownloadBaseViewController ()

@end

@implementation BBMapDownloadBaseViewController

@synthesize tableView = _tableView;
@synthesize customNavView = _customNavView;

- (void)dealloc {
    self.sectionItems = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)_setupViews {
    
    self.view.backgroundColor = BBMapDownloadViewBackgroundColor;
    [self.view addSubview:self.tableView];
    NSMutableDictionary *viewsDict = @{@"tableView": self.tableView}.mutableCopy;
    NSString *topViewVFormat = @"V:|[tableView]|";
    if ([self shouldDisplayCustomNavView]) {
        [self _setupTopView];
        [viewsDict setObject:self.customNavView forKey:@"customNavView"];
        topViewVFormat = @"V:[customNavView]-0-[tableView]|";
    }
    NSArray *constraints = @[
                             [NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:kNilOptions metrics:nil views:viewsDict],
                             [NSLayoutConstraint constraintsWithVisualFormat:topViewVFormat options:kNilOptions metrics:nil views:viewsDict],
                             ];
    [self.view addConstraints:[constraints valueForKeyPath:@"@unionOfArrays.self"]];
}

- (void)_setupTopView {
    BBMapDownloadNavigationView *topView = [BBMapDownloadNavigationView new];
    [self.view addSubview:topView];
    _customNavView = topView;
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topViewTop = [NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:BBMapDownloadStateBarHeight];
    NSLayoutConstraint *topViewLeft = [NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    NSLayoutConstraint *topViewRight = [NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    NSLayoutConstraint *topViewHeight = [NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BBMapDownloadNavHeight];
    [NSLayoutConstraint activateConstraints:@[topViewTop, topViewLeft, topViewRight, topViewHeight]];
    
    self.customNavView.titleAttributedText = self.navTitle;
    __weak typeof(&*self) weakSelf = self;
    self.customNavView.backActionCallBack = ^(UIButton *backButton) {
        __strong typeof(&*weakSelf) self = weakSelf;
        [self navigateBackAction:backButton];
    };

}


- (void)setNavTitle:(NSAttributedString *)navTitle {
    if (_navTitle == navTitle) {
        return;
    }
    _navTitle = navTitle;
    
    self.customNavView.titleAttributedText = navTitle;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *items = self.sectionItems[section].items;
    return items.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBMapDownloadBaseItem *item = self.sectionItems[indexPath.section].items[indexPath.row];
    return item.height;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    BBTableViewSection *sec = self.sectionItems[indexPath.section];
//    BaseCellModel *cellModel = sec.items[indexPath.row];
//    return cellModel.estimatedHeight;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self mapDownloadTableView:tableView cellForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    BOOL shouldDisplay = [self mapDownloadTableView:tableView shouldDisplayHeaderInSection:section];
    if (shouldDisplay) {
        BBMapDownloadSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:BBMapDownloadSectionHeaderViewDefaultIdentifier];
        headerView.attributedText = [self mapDownloadTableView:tableView titleForHeaderInSection:section];
        return headerView;
    }
    else {
        return nil;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    BOOL shouldDisplay = [self mapDownloadTableView:tableView shouldDisplayFooterInSection:section];
    if (shouldDisplay) {
        BBMapDownloadSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:BBMapDownloadSectionHeaderViewDefaultIdentifier];
        headerView.attributedText = [self mapDownloadTableView:tableView titleForHeaderInSection:section];
        return headerView;
    }
    else {
        return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    BOOL shouldDisplay = [self mapDownloadTableView:tableView shouldDisplayHeaderInSection:section];
    if (shouldDisplay) {
        return BBMapDownloadDownloadSectionHeaderHeight;
    }
    else {
        return 0.01;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    BOOL shouldDisplay = [self mapDownloadTableView:tableView shouldDisplayFooterInSection:section];
    if (shouldDisplay) {
        return BBMapDownloadDownloadSectionHeaderHeight;
    }
    else {
        return 0.01;
    }
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (UITableViewCell *)mapDownloadTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BBTableViewSection *section = self.sectionItems[indexPath.section];
    section.sectionOfTable = indexPath.section;
    BBMapDownloadBaseItem *item = self.sectionItems[indexPath.section].items[indexPath.row];
    id<BBBaseTableViewCell> cell = [tableView dequeueReusableCellWithIdentifier:[item.cellClass defaultIdentifier] forIndexPath:indexPath];
    
    item.indexPathOfTable = indexPath;
    cell.cellModel = item;
    return (UITableViewCell *)cell;
}

- (BOOL)mapDownloadTableView:(UITableView *)tableView shouldDisplayHeaderInSection:(NSInteger)section {
    BBTableViewSection *sec = self.sectionItems[section];
    return sec.items.count && sec.headerTitle != nil;
}

- (BOOL)mapDownloadTableView:(UITableView *)tableView shouldDisplayFooterInSection:(NSInteger)section {
    BBTableViewSection *sec = self.sectionItems[section];
    return sec.items.count && sec.footerTitle != nil;
}

- (NSAttributedString *)mapDownloadTableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    BBTableViewSection *sec = self.sectionItems[section];
    return sec.headerTitle;
}

- (NSAttributedString *)mapDownloadTableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    BBTableViewSection *sec = self.sectionItems[section];
    return sec.footerTitle;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy
////////////////////////////////////////////////////////////////////////
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [UITableView new];
        _tableView = tableView;
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[BBMapDownloadSectionHeaderView class] forHeaderFooterViewReuseIdentifier:BBMapDownloadSectionHeaderViewDefaultIdentifier];
    }
    return _tableView;
}

- (NSMutableArray<BBTableViewSection *> *)sectionItems {
    if (!_sectionItems) {
        _sectionItems = @[].mutableCopy;
    }
    return _sectionItems;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (BOOL)shouldDisplayCustomNavView {
    return NO;
}

- (void)navigateBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSLayoutConstraint *)tableViewTopConstraint {
    NSEnumerator *enumerator = self.view.constraints.objectEnumerator;
    NSLayoutConstraint *obj = nil;
    while ((obj = enumerator.nextObject)) {
        if ([obj.firstItem isEqual:self.tableView] && obj.firstAttribute == NSLayoutAttributeTop) {
            break;
        }
    }
    return obj;
}

- (NSLayoutConstraint *)tableViewBottomConstraint {
    NSEnumerator *enumerator = self.view.constraints.objectEnumerator;
    NSLayoutConstraint *obj = nil;
    while ((obj = enumerator.nextObject)) {
        if ([obj.firstItem isEqual:self.tableView] && obj.firstAttribute == NSLayoutAttributeBottom) {
            break;
        }
    }
    return obj;
}

@end

@implementation BBMapDownloadBaseViewController (SectionItemsExtend)

////////////////////////////////////////////////////////////////////////
#pragma mark - Section
////////////////////////////////////////////////////////////////////////

- (void)loadSectionItems {
    
}

- (void)clearSectionItems {
    [self.sectionItems removeAllObjects];
    [self.tableView reloadData];
}

- (BOOL)appendSection:(BBTableViewSection *)section {
    if (!section) {
        return NO;
    }
    NSParameterAssert([section isKindOfClass:[BBTableViewSection class]]);
    [self.sectionItems addObject:section];
    return YES;
}

- (BOOL)insertSection:(BBTableViewSection *)section atIndex:(NSInteger)index {
    if (!section) {
        return NO;
    }
    if (index < self.sectionItems.count) {
        [self.sectionItems insertObject:section atIndex:index];
    }
    else {
        [self.sectionItems addObject:section];
    }
    return YES;
}

- (BBTableViewSection *)getSectionWithIdentifier:(NSString *)identifier {
    NSUInteger foundIdx = [self.sectionItems indexOfObjectPassingTest:^BOOL(BBTableViewSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = [obj.identifier isEqualToString:identifier];
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    if (self.sectionItems && foundIdx != NSNotFound) {
        return [self.sectionItems objectAtIndex:foundIdx];
    }
    return nil;
}

- (BBTableViewSection *)getSectionWithIndex:(NSInteger)index {
    if (index >= self.sectionItems.count) {
        return nil;
    }
    return [self.sectionItems objectAtIndex:index];
}

- (NSIndexPath *)getIndexPathWithCellModel:(id<CellModelProtocol>)cellModel {
    
    if (!cellModel) {
        return nil;
    }
    
    __block NSIndexPath *indexPath = nil;
    [self.sectionItems enumerateObjectsUsingBlock:^(BBTableViewSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger foundIdx = NSNotFound;
        if (obj.items) {
            foundIdx = [obj.items indexOfObject:cellModel];
        }
        if (foundIdx != NSNotFound) {
            *stop = YES;
            indexPath = [NSIndexPath indexPathForRow:foundIdx inSection:idx];
        }
    }];
    
    return indexPath;
}

- (id<CellModelProtocol>)getCellModelWithIndexPath:(NSIndexPath *)indexPath {
    BBTableViewSection *section = [self getSectionWithIndex:indexPath.section];
    if (!section) {
        return nil;
    }
    
    if (indexPath.row >= section.items.count) {
        return nil;
    }
    return [section.items objectAtIndex:indexPath.row];
}


- (BOOL)removeObjectInSectionsAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!indexPath) {
        return NO;
    }
    if (indexPath.section >= self.sectionItems.count) {
        return NO;
    }
    NSMutableArray *items = self.sectionItems[indexPath.section].items;
    if (!items.count || indexPath.row >= items.count) {
        [items removeObjectAtIndex:indexPath.row];
        return YES;
    }
    return NO;
}

- (void)removeObjectsInSectionsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths removedIndexPaths:(NSArray<NSIndexPath *> * __autoreleasing *)removedIndexPaths {
    
    if (!indexPaths.count) {
        return;
    }
    
    NSMutableArray *removeds = @[].mutableCopy;
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        if (indexPath.section >= self.sectionItems.count) {
            return;
        }
        NSMutableArray *items = self.sectionItems[indexPath.section].items;
        if (!items.count || indexPath.row >= items.count) {
            [items removeObjectAtIndex:indexPath.row];
            [removeds addObject:indexPath];
        }
    }];
    
    if (removedIndexPaths) {
        *removedIndexPaths = removeds;
    }
}

- (BOOL)removeObject:(id<CellModelProtocol>)cellModel removedIndexPath:(NSIndexPath * __autoreleasing *)indexPath {
    
    if (!cellModel || !self.sectionItems.count) {
        return NO;
    }
    
    __block BOOL res = NO;
    [self.sectionItems enumerateObjectsUsingBlock:^(BBTableViewSection * _Nonnull obj, NSUInteger sectionIndex, BOOL * _Nonnull stop) {
        NSInteger foundIdx = NSNotFound;
        if (obj.items) {
            foundIdx = [obj.items indexOfObject:cellModel];
        }
        if (foundIdx != NSNotFound) {
            *stop = YES;
            if (indexPath) {
                *indexPath = [NSIndexPath indexPathForRow:foundIdx inSection:sectionIndex];
            }
            [obj.items removeObjectAtIndex:foundIdx];
            res = YES;
        }
    }];
    
    
    return res;
}

- (void)removeObjects:(NSArray<id<CellModelProtocol>> *)cellModels removedIndexPaths:(NSArray<NSIndexPath *> * __autoreleasing *)indexPaths {
    
    if (!cellModels.count || !self.sectionItems.count) {
        return;
    }
    
    NSMutableArray *removedIndexPaths = @[].mutableCopy;
    [cellModels enumerateObjectsUsingBlock:^(id<CellModelProtocol>  _Nonnull cellModel, NSUInteger index, BOOL * _Nonnull stop) {
        [self.sectionItems enumerateObjectsUsingBlock:^(BBTableViewSection * _Nonnull section, NSUInteger sectionIndex, BOOL * _Nonnull stop) {
            NSInteger foundIdx = NSNotFound;
            if (section.items) {
                foundIdx = [section.items indexOfObject:cellModel];
            }
            if (foundIdx != NSNotFound) {
                if (indexPaths) {
                    [removedIndexPaths addObject:cellModel.indexPathOfTable];
                }
                [section.items removeObjectAtIndex:foundIdx];
                return;
            }
        }];
    }];
    if (indexPaths) {
        *indexPaths = removedIndexPaths.copy;
    }
    
}

- (void)updateSectionOfTableViewSection:(BBTableViewSection *)section {
    section.sectionOfTable = [self.sectionItems indexOfObject:section];
}

- (void)deleteCellModelsInSectionsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
    if (!indexPaths.count) {
        return;
    }
    
    [self.tableView beginUpdates];
    
    // 移动时，如果这一组只有这一个元素，就从sectionItems中移除这组
    NSArray *removedIndexPaths = nil;
    [self removeObjectsInSectionsAtIndexPaths:indexPaths removedIndexPaths:&removedIndexPaths];
    
    NSMutableArray *needRemoveSections = @[].mutableCopy;
    // 移除成功时，且此时removedIndexPaths中每一组的items，只要个数为0.就将这一组从sectionItems中移除
    [removedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *  _Nonnull removedIndexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        BBTableViewSection *sec1 = self.sectionItems[removedIndexPath.section];
        if (![needRemoveSections containsObject:sec1] &&
            !sec1.items.count) {
            // 注意: 遍历中不要直接移除sectionItems的元素，不然对下次遍历有影响
            [needRemoveSections addObject:sec1];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:removedIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView deleteRowsAtIndexPaths:@[removedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
    if (needRemoveSections.count) {
        [self.sectionItems removeObjectsInArray:needRemoveSections];
    }
    
    [self.tableView endUpdates];
    
}



- (void)deleteCellModels:(NSArray<id<CellModelProtocol>> *)cellModels inSections:(BBTableViewSection *)section {
    
    if (!cellModels.count) {
        return;
    }
    
    if (!section) {
        // 如果没有传section，就移除整个sectionItems中所有为cellModels的元素
        [self.tableView beginUpdates];
        
        // 移动时，如果这一组只有这一个元素，就从sectionItems中移除这组
        NSArray *removedIndexPaths = nil;
        [self removeObjects:cellModels removedIndexPaths:&removedIndexPaths];
        NSMutableArray *needRemoveSections = @[].mutableCopy;
        // 移除成功时，且此时removedIndexPaths中每一组的items，只要个数为0.就将这一组从sectionItems中移除
        [removedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *  _Nonnull removedIndexPath, NSUInteger idx, BOOL * _Nonnull stop) {
            BBTableViewSection *sec1 = self.sectionItems[removedIndexPath.section];
            if (![needRemoveSections containsObject:sec1] &&
                !sec1.items.count) {
                // 注意: 遍历中不要直接移除sectionItems的元素，不然对下次遍历有影响
                [needRemoveSections addObject:sec1];
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:removedIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {
                [self.tableView deleteRowsAtIndexPaths:@[removedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
        // 当某一组移除了，新的组的index就要减1
        if (needRemoveSections.count) {
            [self.sectionItems removeObjectsInArray:needRemoveSections];
        }
        [self.tableView endUpdates];
        
    }
    else {
        [self.tableView beginUpdates];
        // 移动时，如果这一组只有这一个元素，就从sectionItems中移除这组
        [section.items removeObjectsInArray:cellModels];
        [self updateSectionOfTableViewSection:section];
        if (!section.items.count) {
            // 移除这一组
            [self.sectionItems removeObject:section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:section.sectionOfTable] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        else {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section.sectionOfTable] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }
    
    
}

- (void)appendCellModels:(NSArray<id<CellModelProtocol>> *)cellmodels toSection:(BBTableViewSection *)section {
    if (!cellmodels.count || !section) {
        return;
    }
    [section.items addObjectsFromArray:cellmodels];
    if (![self.sectionItems containsObject:section]) {
        [self insertSection:section atIndex:section.sectionOfTable];
    }
    [self updateSectionOfTableViewSection:section];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section.sectionOfTable] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)appendCellModel:(id)cellmodel toSection:(BBTableViewSection *)section {
    if (!cellmodel || !section) {
        return;
    }
    [section.items addObject:cellmodel];
    if (![self.sectionItems containsObject:section]) {
        [self insertSection:section atIndex:section.sectionOfTable];
    }
    
    [self updateSectionOfTableViewSection:section];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section.sectionOfTable] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)moveCellModelAtIndexPath:(NSIndexPath *)indexPath toSection:(BBTableViewSection *)toSection {
    
    // 当传入参数是错误的时，会导致下面的逻辑错误，所以不要传错数据
    NSParameterAssert(toSection && indexPath.section < self.sectionItems.count && indexPath.row < self.sectionItems[indexPath.section].items.count);
    
    if (!toSection) {
        return;
    }
    if (indexPath.section >= self.sectionItems.count) {
        return;
    }
    BBTableViewSection *orSec = self.sectionItems[indexPath.section];
    if (indexPath.row >= orSec.items.count) {
        return;
    }
    
    [self.tableView beginUpdates];
    
    // 移动时，如果这一组只有这一个元素，就从sectionItems中移除这组
    id<CellModelProtocol> cellModel = orSec.items[indexPath.row];
    if (orSec.items.count == 1) {
        [self.sectionItems removeObject:orSec];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    if (![self.sectionItems containsObject:toSection]) {
        [self insertSection:toSection atIndex:MAX(0, toSection.sectionOfTable)];
    }
    [self updateSectionOfTableViewSection:toSection];
    
    // 当toSection.items的count为0时，我会认定他为刚添加的一组
    // 因为当item.count为0时，我会将他从sectionItems移除
    BOOL isNewSection = toSection.items.count == 0;
    if (!isNewSection) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:toSection.sectionOfTable] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:toSection.items.count inSection:toSection.sectionOfTable];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [toSection.items addObject:cellModel];
    
    [self.tableView endUpdates];
}

- (void)moveCellModel:(id<CellModelProtocol>)cellModel toSection:(BBTableViewSection *)toSection {
    // 当传入参数是错误的时，会导致下面的逻辑错误，所以不要传错数据
    NSParameterAssert(toSection && cellModel);
    
    if (!toSection) {
        return;
    }
    
    [self.tableView beginUpdates];
    
    // 移动时，如果这一组只有这一个元素，就从sectionItems中移除这组
    NSIndexPath *removedIndexPath = nil;
    BOOL isRemoveSuccess = [self removeObject:cellModel removedIndexPath:&removedIndexPath];
    if (isRemoveSuccess) {
        // 移除成功时，且此时removedIndexPath这一组的items个数为0.就将这一组从sectionItems中移除
        BBTableViewSection *sec1 = self.sectionItems[removedIndexPath.section];
        if (!sec1.items.count) {
            [self.sectionItems removeObjectAtIndex:removedIndexPath.section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:removedIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView deleteRowsAtIndexPaths:@[removedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }
    
    if (![self.sectionItems containsObject:toSection]) {
        [self insertSection:toSection atIndex:MAX(0, toSection.sectionOfTable)];
    }
    [self updateSectionOfTableViewSection:toSection];
    
    // 当toSection.items的count为0时，我会认定他为刚添加的一组
    // 因为当item.count为0时，我会将他从sectionItems移除
    BOOL isNewSection = toSection.items.count == 0;
    if (!isNewSection) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:toSection.items.count inSection:toSection.sectionOfTable];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:toSection.sectionOfTable] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    [toSection.items addObject:cellModel];
    
    [self.tableView endUpdates];
}

- (void)moveCellModels:(NSMutableArray<id<CellModelProtocol>> *)cellModels toSection:(BBTableViewSection *)toSection {
    // 当传入参数是错误的时，会导致下面的逻辑错误，所以不要传错数据
    NSParameterAssert(cellModels.count && toSection);
    
    if (!toSection) {
        return;
    }
    
    [self.tableView beginUpdates];
    
    // 移动时，如果这一组只有这一个元素，就从sectionItems中移除这组
    NSArray *removedIndexPaths = nil;
    [self removeObjects:cellModels removedIndexPaths:&removedIndexPaths];
    NSMutableArray *needRemoveSections = @[].mutableCopy;
    // 移除成功时，且此时removedIndexPaths中每一组的items，只要个数为0.就将这一组从sectionItems中移除
    [removedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *  _Nonnull removedIndexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        BBTableViewSection *sec1 = self.sectionItems[removedIndexPath.section];
        if (![needRemoveSections containsObject:sec1] &&
            !sec1.items.count) {
            // 注意: 遍历中不要直接移除sectionItems的元素，不然对下次遍历有影响
            [needRemoveSections addObject:sec1];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:removedIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView deleteRowsAtIndexPaths:@[removedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
    // 当某一组移除了，新的组的index就要减1
    NSInteger newSectionIndex = toSection.sectionOfTable;
    if (needRemoveSections.count) {
        [self.sectionItems removeObjectsInArray:needRemoveSections];
        newSectionIndex--;
        newSectionIndex = MAX(0, newSectionIndex);
    }
    
    if (![self.sectionItems containsObject:toSection]) {
        [self insertSection:toSection atIndex:newSectionIndex];
    }
    
    [self updateSectionOfTableViewSection:toSection];
    
    [cellModels enumerateObjectsUsingBlock:^(id<CellModelProtocol>  _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
        // 当toSection.items的count为0时，我会认定他为刚添加的一组
        // 因为当item.count为0时，我会将他从sectionItems移除
        BOOL isNewSection = toSection.items.count == 0;
        if (!isNewSection) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:toSection.items.count inSection:toSection.sectionOfTable];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:toSection.sectionOfTable] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        [toSection.items addObject:cellModel];
    }];
    
    [self.tableView endUpdates];
}


@end
