//
//  GLLSelection.m
//  GLLara
//
//  Created by Torsten Kammer on 20.12.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "GLLSelection.h"

#import "NSArray+Map.h"
#import "GLLItem.h"

@implementation GLLSelection

+ (NSSet *)keyPathsForValuesAffectingSelectedBones
{
	return [NSSet setWithObject:@"selectedObjects"];
}
+ (NSSet *)keyPathsForValuesAffectingSelectedItems
{
	return [NSSet setWithObject:@"selectedObjects"];
}
+ (NSSet *)keyPathsForValuesAffectingSelectedLights
{
	return [NSSet setWithObject:@"selectedObjects"];
}
+ (NSSet *)keyPathsForValuesAffectingSelectedMeshes
{
	return [NSSet setWithObject:@"selectedObjects"];
}

- (instancetype)init
{
	if (!(self = [super init])) return nil;
	
	self.selectedObjects = [NSMutableArray array];
	
	return self;
}

- (NSArray *)selectedBones;
{
	NSArray *selectedBones = [[self selectedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entity.name == \"GLLItemBone\""]];
	NSArray *selectedBonesFromItems = [[self valueForKeyPath:@"selectedItems"] mapAndJoin:^(GLLItem *item) {
		return item.bones.array;
	}];

	return [selectedBones arrayByAddingObjectsFromArray:selectedBonesFromItems];
}

- (NSArray *)selectedItems
{
	return [[self selectedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entity.name == \"GLLItem\""]];
}

- (NSArray *)selectedLights
{
	return [[self selectedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSManagedObject *object, NSDictionary *bindings){
		return [object.entity isKindOfEntity:[NSEntityDescription entityForName:@"GLLLight" inManagedObjectContext:object.managedObjectContext]];
	}]];
}

- (NSArray *)selectedMeshes
{
	return [[self selectedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entity.name == \"GLLItemMesh\""]];
}

- (NSUInteger)countOfSelectedBones;
{
	return self.selectedBones.count;
}
- (NSUInteger)countOfSelectedLights;
{
	return self.selectedLights.count;
}
- (NSUInteger)countOfSelectedMeshes;
{
	return self.selectedMeshes.count;
}
- (NSUInteger)countOfSelectedObjects;
{
	return self.selectedObjects.count;
}
- (NSUInteger)countOfSelectedItems
{
	return self.selectedItems.count;
}

- (NSManagedObject *)objectInSelectedLightsAtIndex:(NSUInteger)index;
{
	return self.selectedLights[index];
}
- (GLLItemBone *)objectInSelectedBonesAtIndex:(NSUInteger)index;
{
	return self.selectedBones[index];
}
- (GLLItemMesh *)objectInSelectedMeshesAtIndex:(NSUInteger)index;
{
	return self.selectedMeshes[index];
}
- (NSManagedObject *)objectInSelectedObjectsAtIndex:(NSUInteger)index;
{
	return self.selectedObjects[index];
}
- (GLLItem *)objectInSelectedItemsAtIndex:(NSUInteger)index;
{
	return self.selectedItems[index];
}

- (void)insertObject:(GLLItemBone *)object inSelectedBonesAtIndex:(NSUInteger)index;
{
	NSMutableArray *selectedObjects = [self mutableArrayValueForKey:@"selectedObjects"];
	
	// Switch to selecting only bones
	[selectedObjects replaceObjectsInRange:NSMakeRange(0, selectedObjects.count) withObjectsFromArray:[self valueForKey:@"selectedBones"]];
	
	// Insert
	[selectedObjects insertObject:object atIndex:index];
}
- (void)insertObject:(NSManagedObject *)object inSelectedLightsAtIndex:(NSUInteger)index;
{
	NSMutableArray *selectedObjects = [self mutableArrayValueForKey:@"selectedObjects"];
	
	// Switch to selecting only bones
	[selectedObjects replaceObjectsInRange:NSMakeRange(0, selectedObjects.count) withObjectsFromArray:[self valueForKey:@"selectedLights"]];
	
	// Insert
	[selectedObjects insertObject:object atIndex:index];
}
- (void)insertObject:(GLLItemMesh *)object inSelectedMeshesAtIndex:(NSUInteger)index;
{
	NSMutableArray *selectedObjects = [self mutableArrayValueForKey:@"selectedObjects"];
	
	// Switch to selecting only bones
	[selectedObjects replaceObjectsInRange:NSMakeRange(0, selectedObjects.count) withObjectsFromArray:[self valueForKey:@"selectedMeshes"]];
	
	// Insert
	[selectedObjects insertObject:object atIndex:index];
}
- (void)insertObject:(GLLItem *)object inSelectedItemsAtIndex:(NSUInteger)index
{
	NSMutableArray *selectedObjects = [self mutableArrayValueForKey:@"selectedObjects"];
	
	// Switch to selecting only bones
	[selectedObjects replaceObjectsInRange:NSMakeRange(0, selectedObjects.count) withObjectsFromArray:[self valueForKey:@"selectedItems"]];
	
	// Insert
	[selectedObjects insertObject:object atIndex:index];
}

- (void)insertObject:(NSManagedObject *)object inSelectedObjectsAtIndex:(NSUInteger)index;
{
	[self.selectedObjects insertObject:object atIndex:index];
}

- (void)removeObjectFromSelectedBonesAtIndex:(NSUInteger)index;
{
	NSMutableArray *selectedObjects = [self mutableArrayValueForKey:@"selectedObjects"];
	
	// Switch to selecting only bones
	[selectedObjects replaceObjectsInRange:NSMakeRange(0, selectedObjects.count) withObjectsFromArray:[self valueForKey:@"selectedBones"]];
	
	// Remove
	[selectedObjects removeObjectAtIndex:index];
}
- (void)removeObjectFromSelectedLightsAtIndex:(NSUInteger)index;
{
	NSMutableArray *selectedObjects = [self mutableArrayValueForKey:@"selectedObjects"];
	
	// Switch to selecting only bones
	[selectedObjects replaceObjectsInRange:NSMakeRange(0, selectedObjects.count) withObjectsFromArray:[self valueForKey:@"selectedLights"]];
	
	// Remove
	[selectedObjects removeObjectAtIndex:index];
}
- (void)removeObjectFromSelectedMeshesAtIndex:(NSUInteger)index;
{
	NSMutableArray *selectedObjects = [self mutableArrayValueForKey:@"selectedObjects"];
	
	// Switch to selecting only bones
	[selectedObjects replaceObjectsInRange:NSMakeRange(0, selectedObjects.count) withObjectsFromArray:[self valueForKey:@"selectedMeshes"]];
	
	// Remove
	[selectedObjects removeObjectAtIndex:index];
}
- (void)removeObjectFromSelectedObjectsAtIndex:(NSUInteger)index;
{
	[self.selectedObjects removeObjectAtIndex:index];
}
- (void)removeObjectFromSelectedItemsAtIndex:(NSUInteger)index
{
	NSMutableArray *selectedObjects = [self mutableArrayValueForKey:@"selectedObjects"];
	
	// Switch to selecting only bones
	[selectedObjects replaceObjectsInRange:NSMakeRange(0, selectedObjects.count) withObjectsFromArray:[self valueForKey:@"selectedLights"]];
	
	// Remove
	[selectedObjects removeObjectAtIndex:index];
}

@end