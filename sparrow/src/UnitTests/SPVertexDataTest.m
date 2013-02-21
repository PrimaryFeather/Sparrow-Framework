//
//  SPVertexDataTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 19.02.13.
//
//

#import "SPVertexData.h"

#import <SenTestingKit/SenTestingKit.h>

#define E 0.0001f

// -------------------------------------------------------------------------------------------------

@interface SPVertexDataTest : SenTestCase

@end

// -------------------------------------------------------------------------------------------------

@implementation SPVertexDataTest

- (void)testEmpty
{
    SPVertexData *vertexData = [[SPVertexData alloc] initWithSize:0];
    
    STAssertEquals(0, vertexData.numVertices, @"wrong number of vertices");
    STAssertTrue(vertexData.vertices == NULL, @"vertex array should be null");
}

- (void)testBasicMethods
{
    int numVertices = 4;
    
    SPVertex vertex = [self anyVertex];
    SPVertex defaultVertex = [self defaultVertex];
    
    SPVertexData *vertexData = [[SPVertexData alloc] initWithSize:numVertices];
    
    STAssertEquals(numVertices, vertexData.numVertices, @"wrong number of vertices");
    STAssertTrue(vertexData.vertices != NULL, @"vertex array not accessible");
    
    for (int i=0; i<numVertices; ++i)
        [self compareVertex:defaultVertex withVertex:vertexData.vertices[i]];

    [vertexData setVertex:vertex atIndex:1];
    
    [self compareVertex:defaultVertex withVertex:[vertexData vertexAtIndex:0]];
    [self compareVertex:vertex        withVertex:[vertexData vertexAtIndex:1]];
    [self compareVertex:defaultVertex withVertex:[vertexData vertexAtIndex:2]];
    [self compareVertex:defaultVertex withVertex:[vertexData vertexAtIndex:3]];
}

- (void)testResize
{
    SPVertex vertex = [self anyVertex];
    SPVertex defaultVertex = [self defaultVertex];
    SPVertexData *vertexData = [[SPVertexData alloc] initWithSize:4];
    
    STAssertEquals(4, vertexData.numVertices, @"wrong number of vertices");
    
    vertexData.vertices[1] = vertex;
    vertexData.vertices[2] = vertex;
    vertexData.vertices[3] = vertex;
    
    vertexData.numVertices = 2;
    
    STAssertEquals(2, vertexData.numVertices, @"wrong number of vertices");
    [self compareVertex:defaultVertex withVertex:[vertexData vertexAtIndex:0]];
    [self compareVertex:vertex        withVertex:[vertexData vertexAtIndex:1]];
    
    vertexData.numVertices = 4;
    
    [self compareVertex:defaultVertex withVertex:[vertexData vertexAtIndex:2]];
    [self compareVertex:defaultVertex withVertex:[vertexData vertexAtIndex:3]];
}

- (void)testAppend
{
    SPVertex vertex = [self anyVertex];
    SPVertexData *vertexData = [[SPVertexData alloc] init];
    
    STAssertEquals(0, vertexData.numVertices, @"wrong number of vertices");
    
    [vertexData appendVertex:vertex];
    
    STAssertEquals(1, vertexData.numVertices, @"wrong number of vertices");
    [self compareVertex:vertex withVertex:[vertexData vertexAtIndex:0]];
}

- (void)testPremultipliedAlpha
{
    SPVertexData *vertexData = [[SPVertexData alloc] initWithSize:0 premultipliedAlpha:NO];
    
    SPVertex vertex = [self defaultVertex];
    vertex.color.r = 0.8f;
    vertex.color.g = 0.6f;
    vertex.color.b = 0.4f;
    vertex.color.a = 0.5f;
    
    [vertexData appendVertex:vertex];
    
    [self compareVertex:vertex withVertex:vertexData.vertices[0]];
    
    [vertexData setPremultipliedAlpha:YES updateVertices:YES];
    
    SPVertex pmaVertex = [self defaultVertex];
    pmaVertex.color.r = 0.4f;
    pmaVertex.color.g = 0.3f;
    pmaVertex.color.b = 0.2f;
    pmaVertex.color.a = 0.5f;
    
    [self compareVertex:pmaVertex withVertex:vertexData.vertices[0]];
    
    [vertexData setPremultipliedAlpha:NO updateVertices:YES];

    [self compareVertex:vertex withVertex:vertexData.vertices[0]];
}

- (void)testCopy
{
    SPVertex defaultVertex = [self defaultVertex];
    SPVertex vertex = [self anyVertex];
    SPVertexData *sourceData = [[SPVertexData alloc] init];
    
    [sourceData appendVertex:vertex];
    [sourceData appendVertex:defaultVertex];
    [sourceData appendVertex:vertex];
    
    SPVertexData *targetData = [[SPVertexData alloc] initWithSize:5 premultipliedAlpha:NO];
    
    [sourceData copyToVertexData:targetData atIndex:2];
    
    [self compareVertex:defaultVertex withVertex:[targetData vertexAtIndex:0]];
    [self compareVertex:defaultVertex withVertex:[targetData vertexAtIndex:1]];
    [self compareVertex:vertex        withVertex:[targetData vertexAtIndex:2]];
    [self compareVertex:defaultVertex withVertex:[targetData vertexAtIndex:3]];
    [self compareVertex:vertex        withVertex:[targetData vertexAtIndex:4]];
}

- (SPVertex)defaultVertex
{
    SPVertex vertex = {
        .position = GLKVector2Make(0.0f, 0.0f),
        .texCoords = GLKVector2Make(0.0f, 0.0f),
        .color = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)
    };
    return vertex;
}

- (SPVertex)anyVertex
{
    SPVertex vertex = {
        .position = GLKVector2Make(1.0f, 2.0f),
        .texCoords = GLKVector2Make(3.0f, 4.0f),
        .color = GLKVector4Make(5.0f, 6.0f, 7.0f, 8.0f)
    };
    
    return vertex;
}

- (void)compareVertex:(SPVertex)v1 withVertex:(SPVertex)v2
{
    STAssertEqualsWithAccuracy(v1.color.r,     v2.color.r,     E, @"wrong color.r");
    STAssertEqualsWithAccuracy(v1.color.g,     v2.color.g,     E, @"wrong color.g");
    STAssertEqualsWithAccuracy(v1.color.b,     v2.color.b,     E, @"wrong color.b");
    STAssertEqualsWithAccuracy(v1.color.a,     v2.color.a,     E, @"wrong color.a");
    STAssertEqualsWithAccuracy(v1.position.x,  v2.position.x,  E, @"wrong position.x");
    STAssertEqualsWithAccuracy(v1.position.y,  v2.position.y,  E, @"wrong position.y");
    STAssertEqualsWithAccuracy(v1.texCoords.x, v2.texCoords.x, E, @"wrong texCoords.x");
    STAssertEqualsWithAccuracy(v1.texCoords.y, v2.texCoords.y, E, @"wrong texCoords.y");
}

@end
