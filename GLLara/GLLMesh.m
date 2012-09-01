//
//  GLLMesh.m
//  GLLara
//
//  Created by Torsten Kammer on 31.08.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "GLLMesh.h"

#import "GLLModel.h"
#import "TRInDataStream.h"

@interface GLLMesh ()

- (NSData *)_postprocessVertices:(NSData *)vertexData;

@end

@implementation GLLMesh

#pragma mark -
#pragma mark Mesh loading

- (id)initFromStream:(TRInDataStream *)stream partOfModel:(GLLModel *)model;
{
	if (!(self = [super init])) return nil;
	
	_model = model;
	
	_name = [stream readPascalString];
	_countOfUVLayers = [stream readUint32];
	
	NSUInteger numTextures = [stream readUint32];
	NSMutableArray *textures = [[NSMutableArray alloc] initWithCapacity:numTextures];
	for (NSUInteger i = 0; i < numTextures; i++)
	{
		NSString *textureName = [stream readPascalString];
		NSUInteger uvLayer = [stream readUint32];
		[textures addObject:@{
			@"name" : textureName,
			@"layer" : @(uvLayer)
		 }];
	}
	_textures = [textures copy];
	
	_countOfVertices = [stream readUint32];
	NSData *rawVertexData = [stream dataWithLength:_countOfVertices * self.stride];
	_vertexData = [[self _postprocessVertices:rawVertexData] copy];
	
	_countOfElements = 3 * [stream readUint32]; // File saves number of triangles
	_elementData = [stream dataWithLength:_countOfElements * sizeof(uint32_t)];
	
	return self;
}

#pragma mark -
#pragma mark Describe mesh data

- (NSUInteger)offsetForPosition
{
	return 0;
}
- (NSUInteger)offsetForNormal
{
	return 12;
}
- (NSUInteger)offsetForColor
{
	return 24;
}
- (NSUInteger)offsetForTexCoordLayer:(NSUInteger)layer
{
	NSAssert(layer < self.countOfUVLayers, @"Asking for layer %lu but we only have %lu", layer, self.countOfUVLayers);
	
	return 28 + 8*layer;
}
- (NSUInteger)offsetForTangentLayer:(NSUInteger)layer
{
	NSAssert(layer < self.countOfUVLayers, @"Asking for layer %lu but we only have %lu", layer, self.countOfUVLayers);
	
	return 28 + 8*self.countOfUVLayers + 16*layer;
}
- (NSUInteger)offsetForBoneIndices
{
	NSAssert(self.hasBoneWeights, @"Asking for offset for bone indices in mesh that doesn't have any.");
	
	return 28 + 24*self.countOfUVLayers;
}
- (NSUInteger)offsetForBoneWeights
{
	NSAssert(self.hasBoneWeights, @"Asking for offset for bone indices in mesh that doesn't have any.");
	return 28 + 24*self.countOfUVLayers + 8;
}
- (NSUInteger)stride
{
	return 28 + 24*self.countOfUVLayers + (self.hasBoneWeights ? 24 : 0);
}

#pragma mark -
#pragma mark Properties

- (BOOL)hasBoneWeights
{
	return self.model.hasBones;
}

#pragma mark -
#pragma mark Splitting

- (GLLMesh *)partialMeshInBoxMin:(float *)min max:(float *)max name:(NSString *)name;
{
	NSMutableData *newVertices = [[NSMutableData alloc] init];
	NSMutableData *newElements = [[NSMutableData alloc] init];
	NSUInteger newVerticesCount = 0;
	NSMutableDictionary *oldToNewVertices = [[NSMutableDictionary alloc] init];
		
	const NSUInteger stride = self.stride;
	const NSUInteger positionOffset = self.offsetForPosition;
	const NSUInteger countOfFaces = self.countOfElements / 3;
	
	const void *oldBytes = self.vertexData.bytes;
	const uint32_t *oldElements = self.elementData.bytes;
	
	for (NSUInteger i = 0; i < countOfFaces; i++)
	{
		const uint32_t *indices = &oldElements[i*3];
		
		const float *position[3] = {
			&oldBytes[indices[0]*stride + positionOffset],
			&oldBytes[indices[1]*stride + positionOffset],
			&oldBytes[indices[2]*stride + positionOffset]
		};
		
		// Find out if one corner is completely in the box. If yes, then this triangle becomes part of the split mesh.
		BOOL anyCornerInsideBox = NO;
		for (int corner = 0; corner < 3; corner++)
		{
			BOOL allCoordsInsideBox = YES;
			for (int coord = 0; coord < 3; coord++)
				allCoordsInsideBox = allCoordsInsideBox && position[corner][coord] >= min[coord] && position[corner][coord] <= max[coord];
			if (allCoordsInsideBox)
				anyCornerInsideBox = YES;
		}
		
		// All outside - not part of the split mesh.
		if (!anyCornerInsideBox) continue;
		
		for (int corner = 0; corner < 3; corner++)
		{
			// If this vertex is already in the new mesh, then just add the index. Otherwise, add the vertex itself to the vertices, too.
			NSNumber *newIndex = oldToNewVertices[@(indices[corner])];
			if (!newIndex)
			{
				[newVertices appendBytes:&oldBytes[indices[corner] * stride] length:stride];
				
				newIndex = @(newVerticesCount);
				oldToNewVertices[@(indices[corner])] = newIndex;
				newVerticesCount += 1;
			}
			uint32_t index = newIndex.unsignedIntValue;
			[newElements appendBytes:&index length:sizeof(index)];
		}
	}
	
	GLLMesh *result = [[GLLMesh alloc] init];
	result->_vertexData = [newVertices copy];
	result->_elementData = [newElements copy];
	
	result->_boneIndices = [self.boneIndices copy];
	result->_countOfUVLayers = self.countOfUVLayers;
	result->_model = self.model;
	result->_name = [name copy];
	result->_textures = [self.textures copy];
	
	return result;
}

#pragma mark -
#pragma mark Private methods

- (NSData *)_postprocessVertices:(NSData *)vertexData;
{
	if (!self.hasBoneWeights)
		return vertexData; // No processing necessary
	
	NSMutableData *mutableVertices = [vertexData mutableCopy];
	void *bytes = mutableVertices.mutableBytes;
	const NSUInteger boneIndexOffset = self.offsetForBoneIndices;
	const NSUInteger boneWeightOffset = self.offsetForBoneWeights;
	const NSUInteger stride = self.stride;
	
	NSMutableDictionary *localForGlobalIndex = [[NSMutableDictionary alloc] init];
	NSMutableArray *boneIndices = [[NSMutableArray alloc] init];
	
	for (NSUInteger i = 0; i < self.countOfVertices; i++)
	{
		float *weights = &bytes[boneWeightOffset + i*stride];
		uint16_t *indices = &bytes[boneIndexOffset + i*stride];
		
		// Normalize weights. If no weights, use first bone.
		float weightSum = 0.0f;
		for (int i = 0; i < 4; i++)
			weightSum += weights[i];
		
		if (weightSum == 0.0f)
			weights[0] = 1.0f;
		else if (weightSum != 1.0f)
		{
			for (int i = 0; i < 4; i++)
				weights[i] /= weightSum;
		}
		
		// Find the first index with non-null weight (i.e. the first this mesh absolutely has to have). Used later.
		uint16_t firstUsedIndex = UINT16_MAX;
		for (int i = 0; i < 4; i++)
		{
			if (weights[i] > 0.0f)
			{
				firstUsedIndex = indices[i];
				break;
			}
		}
		
		// Convert global to local index.
		for (int i = 0; i < 4; i++)
		{
			// If it doesn't matter what bone is used (because weight is 0), use one that is already required for this mesh.
			uint16_t index = weights[i] > 0.0f ? indices[i] : firstUsedIndex;
			
			NSNumber *local = localForGlobalIndex[@(index)];
			if (!local)
			{
				local = @(boneIndices.count);
				localForGlobalIndex[@(index)] = local;
				[boneIndices addObject:@(index)];
			}
			weights[i] = local.unsignedShortValue;
		}
	}
	
	_boneIndices = [boneIndices copy];
	
	return mutableVertices;
}

@end
