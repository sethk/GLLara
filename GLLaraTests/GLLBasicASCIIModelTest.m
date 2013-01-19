//
//  GLLBasicASCIIModelTest.m
//  GLLara
//
//  Created by Torsten Kammer on 17.10.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "GLLBasicASCIIModelTest.h"

#import "GLLModel.h"
#import "GLLModelBone.h"
#import "GLLModelMesh.h"

@implementation GLLBasicASCIIModelTest

- (void)testEmptyFile
{
	NSString *string = @"0 0";
	
	NSURL *baseURL = [NSURL fileURLWithPath:@"/tmp/generic_item.mesh"];
	GLLModel *model = [[GLLModel alloc] initASCIIFromString:string baseURL:baseURL error:NULL];
	STAssertNotNil(model, @"Model has to be loaded.");
	
	STAssertEquals(model.bones.count, (NSUInteger) 0, @"Model should have no bones.");
	STAssertEquals(model.meshes.count, (NSUInteger) 0, @"Model should have no meshes.");
}

- (void)testBone
{
	NSString *string = @"1 #bone count\n\
	Test\n\
	-1\n\
	0.0 0 0.0\n\
	0";
	NSURL *baseURL = [NSURL fileURLWithPath:@"/tmp/generic_item.mesh"];
	GLLModel *model = [[GLLModel alloc] initASCIIFromString:string baseURL:baseURL error:NULL];
	STAssertNotNil(model, @"Model has to be loaded.");
	
	STAssertEquals(model.bones.count, (NSUInteger) 1, @"Model should have one bone.");
	STAssertEquals(model.meshes.count, (NSUInteger) 0, @"Model should have no meshes.");
	
	GLLModelBone *bone = model.bones[0];
	STAssertEqualObjects(bone.name, @"Test", @"Incorrect name of bone");
	STAssertEquals(bone.parentIndex, (NSUInteger) UINT16_MAX, @"Bone parent index should be invalid");
	STAssertNil(bone.parent, @"Bone should not have a parent");
	STAssertTrue(bone.children == nil || bone.children.count == 0, @"Bone should not have children");
	STAssertEquals(bone.positionX, 0.0f, @"incorrect position");
	STAssertEquals(bone.positionY, 0.0f, @"incorrect position");
	STAssertEquals(bone.positionZ, 0.0f, @"incorrect position");
}

- (void)testEmptyMesh
{
	NSString *string = @"0 #bone count\n\
	1\n\
	Test\n\
	0\n\
	0\n\
	0\n\
	0";
	GLLModel *model = [[GLLModel alloc] initASCIIFromString:string baseURL:nil error:NULL];
	STAssertNotNil(model, @"Model has to be loaded.");
	
	STAssertEquals(model.bones.count, (NSUInteger) 0, @"Model should have no bones.");
	STAssertEquals(model.meshes.count, (NSUInteger) 1, @"Model should have one mesh.");
	
	GLLModelMesh *mesh = model.meshes[0];
	STAssertEqualObjects(mesh.name, @"Test", @"Incorrect name of mesh");
	STAssertTrue(mesh.textures == nil || mesh.textures.count == 0, @"Mesh should not have textures");
	STAssertEquals(mesh.countOfElements, (NSUInteger) 0, @"Mesh is not empty");
	STAssertEquals(mesh.countOfUVLayers, (NSUInteger) 0, @"Mesh is not empty");
	STAssertEquals(mesh.countOfVertices, (NSUInteger) 0, @"Mesh is not empty");
	
	STAssertEquals(mesh.vertexData.length, (NSUInteger) 0, @"Mesh is not empty");
	STAssertEquals(mesh.elementData.length, (NSUInteger) 0, @"Mesh is not empty");
}

- (void)testTypicalModel
{
	NSString *string = @"2 # bones\n\
	Bone1\n\
	-1\n\
	-0.50 0 0\n\
	\n\
	Bone2\n\
	0\n\
	0.50 0 0.0\n\
	\n\
	1 # the count of them meshes\n\
	Test\n\
	1 # uv layers\n\
	1 # textures\n\
	tex.tga\n\
	0\n\
	3 # num verts\n\
	-.5 0 0\n\
	0 0 1\n\
	255 0 0 255\n\
	0 0\n\
	0 0 0 0\n\
	1 0 0 0\n\
	0.5 0 0\n\
	0 0 1\n\
	0 255 0  255\n\
	1 0\n\
	1 0 0 0\n\
	1 0 0 0\n\
	0.0 1.000000 0\n\
	0 0 1\n\
	0 0 255 255\n\
	0 1\n\
	0 1 0 0\n\
	0.5 0.5 0 0\n\
	1 # count of tris\n\
	0 1 2	";
	NSURL *baseURL = [NSURL fileURLWithPath:@"/tmp/generic_item.mesh"];
	GLLModel *model = [[GLLModel alloc] initASCIIFromString:string baseURL:baseURL error:NULL];
	STAssertNotNil(model, @"Model has to be loaded.");
	
	STAssertEquals(model.bones.count, (NSUInteger) 2, @"Model should have two bones.");
	STAssertEquals(model.meshes.count, (NSUInteger) 1, @"Model should have one mesh.");
	
	GLLModelBone *bone1 = model.bones[0];
	GLLModelBone *bone2 = model.bones[1];
	STAssertEqualObjects(bone1.name, @"Bone1", @"Incorrect name of bone");
	STAssertEquals(bone1.parentIndex, (NSUInteger) UINT16_MAX, @"Bone parent index should be invalid");
	STAssertNil(bone1.parent, @"Bone should not have a parent");
	STAssertEquals(bone1.children.count, 1UL, @"Bone should not have children");
	STAssertEqualObjects(bone1.children, @[ bone2 ], @"bone 2 should be child of bone 1");
	STAssertEquals(bone1.positionX, -0.5f, @"incorrect position");
	STAssertEquals(bone1.positionY, 0.0f, @"incorrect position");
	STAssertEquals(bone1.positionZ, 0.0f, @"incorrect position");
	
	STAssertEqualObjects(bone2.name, @"Bone2", @"Incorrect name of bone");
	STAssertEquals(bone2.parentIndex, (NSUInteger) 0, @"Bone parent index should be 0");
	STAssertEqualObjects(bone2.parent, bone1, @"bone 2 should have bone 1 as parent");
	STAssertTrue(bone2.children == nil || bone2.children.count == 0, @"Bone 2 should not have children");
	STAssertEquals(bone2.positionX, 0.5f, @"incorrect position");
	STAssertEquals(bone2.positionY, 0.0f, @"incorrect position");
	STAssertEquals(bone2.positionZ, 0.0f, @"incorrect position");
	
	GLLModelMesh *mesh = model.meshes[0];
	STAssertEqualObjects(mesh.name, @"Test", @"Incorrect name of mesh");
	STAssertEquals(mesh.textures.count, (NSUInteger) 1, @"Mesh should have textures");
	STAssertEqualObjects([mesh.textures[0] absoluteURL], [NSURL fileURLWithPath:@"/tmp/tex.tga"], @"Incorrect URL");
	STAssertEquals(mesh.countOfElements, (NSUInteger) 3, @"Not enough indices");
	STAssertEquals(mesh.countOfUVLayers, (NSUInteger) 1, @"Not enough UV layers");
	STAssertEquals(mesh.countOfVertices, (NSUInteger) 3, @"Not enough vertices");
	
	STAssertEquals(mesh.vertexData.length, (NSUInteger) 228, @"Vertex data count wrong");
	STAssertEquals(mesh.elementData.length, (NSUInteger) 12, @"Element data count wrong");
	STAssertEquals(mesh.stride, (NSUInteger) 76, @"Wrong stride");
	STAssertEquals(mesh.offsetForPosition, (NSUInteger) 0, @"Wrong offset");
	STAssertEquals(mesh.offsetForNormal, (NSUInteger) 12, @"Wrong offset");
	STAssertEquals(mesh.offsetForColor, (NSUInteger) 24, @"Wrong offset");
	STAssertEquals([mesh offsetForTexCoordLayer:0], (NSUInteger) 28, @"Wrong offset");
	STAssertEquals([mesh offsetForTangentLayer:0], (NSUInteger) 36, @"Wrong offset");
	
	const uint32_t *elements = mesh.elementData.bytes;
	STAssertTrue(memcmp(elements, (const uint32_t []) { 0, 1, 2 }, sizeof(uint32_t [3])) == 0, @"incorrect indices");
	
	const void *vertices = mesh.vertexData.bytes;
	STAssertTrue(memcmp(vertices + mesh.stride*0 + mesh.offsetForPosition,
						(float [3]) { -0.5, 0.0, 0.0 },
						sizeof(float [3])) == 0,
				 @"Vertex position 0");
	STAssertTrue(memcmp(vertices + mesh.stride*1 + mesh.offsetForPosition,
						(float [3]) { 0.5, 0.0, 0.0 },
						sizeof(float [3])) == 0,
				 @"Vertex position 1");
	STAssertTrue(memcmp(vertices + mesh.stride*2 + mesh.offsetForPosition,
						(float [3]) { 0.0, 1.0, 0.0 },
						sizeof(float [3])) == 0,
				 @"Vertex position 2");
}

- (void)testFilledMesh
{
	NSString *string = @"0\n\
	1 # the count of them meshes\n\
	Test\n\
	1 # uv layers\n\
	1 # textures\n\
	tex.tga\n\
	0\n\
	3 # num verts\n\
	-.5 0 0\n\
	0 0 1\n\
	255 0 0 255\n\
	0 0\n\
	0.5 0 0\n\
	0 0 1\n\
	0 255 0  255\n\
	1 0\n\
	0.0 1.000000 0\n\
	0 0 1\n\
	0 0 255 255\n\
	0 1\n\
	1 # count of tris\n\
	0 1 2	";
	NSURL *baseURL = [NSURL fileURLWithPath:@"/tmp/generic_item.mesh"];
	GLLModel *model = [[GLLModel alloc] initASCIIFromString:string baseURL:baseURL error:NULL];
	STAssertNotNil(model, @"Model has to be loaded.");
	
	STAssertEquals(model.bones.count, (NSUInteger) 0, @"Model should have no bones.");
	STAssertEquals(model.meshes.count, (NSUInteger) 1, @"Model should have one mesh.");
	
	GLLModelMesh *mesh = model.meshes[0];
	STAssertEqualObjects(mesh.name, @"Test", @"Incorrect name of mesh");
	STAssertEquals(mesh.textures.count, (NSUInteger) 1, @"Mesh should have textures");
	STAssertEqualObjects([mesh.textures[0] absoluteURL], [NSURL fileURLWithPath:@"/tmp/tex.tga"], @"Incorrect URL");
	STAssertEquals(mesh.countOfElements, (NSUInteger) 3, @"Not enough indices");
	STAssertEquals(mesh.countOfUVLayers, (NSUInteger) 1, @"Not enough UV layers");
	STAssertEquals(mesh.countOfVertices, (NSUInteger) 3, @"Not enough vertices");
	
	STAssertEquals(mesh.vertexData.length, (NSUInteger) 156, @"Vertex data count wrong");
	STAssertEquals(mesh.elementData.length, (NSUInteger) 12, @"Element data count wrong");
	STAssertEquals(mesh.stride, (NSUInteger) 52, @"Wrong stride");
	STAssertEquals(mesh.offsetForPosition, (NSUInteger) 0, @"Wrong offset");
	STAssertEquals(mesh.offsetForNormal, (NSUInteger) 12, @"Wrong offset");
	STAssertEquals(mesh.offsetForColor, (NSUInteger) 24, @"Wrong offset");
	STAssertEquals([mesh offsetForTexCoordLayer:0], (NSUInteger) 28, @"Wrong offset");
	STAssertEquals([mesh offsetForTangentLayer:0], (NSUInteger) 36, @"Wrong offset");
	
	const uint32_t *elements = mesh.elementData.bytes;
	STAssertTrue(memcmp(elements, (const uint32_t []) { 0, 1, 2 }, sizeof(uint32_t [3])) == 0, @"incorrect indices");
	
	const void *vertices = mesh.vertexData.bytes;
	STAssertTrue(memcmp(vertices + mesh.stride*0 + mesh.offsetForPosition,
						(float [3]) { -0.5, 0.0, 0.0 },
						sizeof(float [3])) == 0,
				 @"Vertex position 0");
	STAssertTrue(memcmp(vertices + mesh.stride*1 + mesh.offsetForPosition,
						(float [3]) { 0.5, 0.0, 0.0 },
						sizeof(float [3])) == 0,
				 @"Vertex position 1");
	STAssertTrue(memcmp(vertices + mesh.stride*2 + mesh.offsetForPosition,
						(float [3]) { 0.0, 1.0, 0.0 },
						sizeof(float [3])) == 0,
				 @"Vertex position 2");
}

@end