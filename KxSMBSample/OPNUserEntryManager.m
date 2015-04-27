//
//  OPNUserEntryManager.m
//  OPNFileReader
//
//  Created by Shota Takai on 2015/04/23.
//  Copyright (c) 2015年 NRI Netcom. All rights reserved.
//

#import "OPNUserEntryManager.h"
#import "OPNUserEntry.h"
#import "OPNUserEntry.h"

@implementation OPNUserEntryManager
+ (OPNUserEntryManager*)sharedManager
{
    static OPNUserEntryManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[OPNUserEntryManager alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSData *entriesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEntries"];
        NSMutableArray *entries = [NSKeyedUnarchiver unarchiveObjectWithData:entriesData];
        
        if ([entries count] > 0) {
            self.userEntries = entries;
        } else {
            self.userEntries = [@[] mutableCopy];
        }
    }
    return self;
}

- (void)addUserEntry:(OPNUserEntry*)entry {
    if (!entry) {
        return;
    }
    
    [self.userEntries addObject:entry];
    [self save];
}

- (void)insertUserEntry:(OPNUserEntry *)entry inUserEntriesAtIndex:(NSUInteger)index {
    if (!entry) {
        return;
    }
    if (index > [self.userEntries count]) {
        return;
    }
    
    [self.userEntries insertObject:entry atIndex:index];
    [self save];
}

- (void)removeUserEntry:(NSUInteger)index {
    if (index > [self.userEntries count] - 1) {
        return;
    }
    
    [self.userEntries removeObjectAtIndex:index];
    [self save];
}

- (void)removeAllUserEntries {
    if (!self.userEntries) {
        return;
    }
    
    [self.userEntries removeAllObjects];
    [self save];
}

- (void)moveUserEntryAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (fromIndex > [self.userEntries count] - 1) {
        return;
    }
    if (toIndex > [self.userEntries count]) {
        return;
    }
    
    OPNUserEntry *userEntry;
    userEntry = [self.userEntries objectAtIndex:fromIndex];
    [self.userEntries removeObject:userEntry];
    [self.userEntries insertObject:userEntry atIndex:toIndex];
    [self save];
}

- (void)save {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.userEntries];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"UserEntries"];
}

- (NSString*)getServerIpAtIndex:(NSUInteger)index {
    NSMutableArray *entries= self.userEntries;
    if (![entries count] < 0) {
        return nil;
    }
    OPNUserEntry *entry = entries[index];
    return entry.targetServer.ip;
}

@end