//
//  SPVertexDataTest.m
//  Sparrow
//
//  Created by Daniel Sperl on 19.02.13.
//
//

#import "SPVertexData.h"
#import "SPMatrix.h"
#import "SPMacros.h"

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
    vertex.color = SPVertexColorMake(80, 60, 40, 204); // alpha = 4/5
    [vertexData appendVertex:vertex];
    
    [self compareVertex:vertex withVertex:vertexData.vertices[0]];
    
    [vertexData setPremultipliedAlpha:YES updateVertices:YES];
    
    SPVertex pmaVertex = [self defaultVertex];
    pmaVertex.color = SPVertexColorMake(64, 48, 32, 204);
    
    [self compareVertex:pmaVertex withVertex:vertexData.vertices[0]];
    
    [vertexData setPremultipliedAlpha:NO updateVertices:YES];

    [self compareVertex:vertex withVertex:vertexData.vertices[0]];
}

- (void)testScaleAlphaWithoutPMA
{
    SPVertexData *vertexData = [[SPVertexData alloc] initWithSize:0 premultipliedAlpha:NO];
    
    SPVertex vertex = [self defaultVertex];
    vertex.color = SPVertexColorMake(80, 60, 40, 128);
    
    [vertexData appendVertex:vertex];
    [vertexData scaleAlphaBy:0.5f];
    
    SPVertex expectedVertex;
    expectedVertex.color = SPVertexColorMake(80, 60, 40, 64);
    
    [self compareVertex:expectedVertex withVertex:vertexData.vertices[0]];
}

- (void)testScaleAlphaWithPMA
{
    SPVertexData *vertexData = [[SPVertexData alloc] initWithSize:0 premultipliedAlpha:YES];
    
    SPVertex vertex = [self defaultVertex];
    vertex.color = SPVertexColorMake(80, 60, 40, 204);
    
    [vertexData appendVertex:vertex];
    [vertexData scaleAlphaBy:0.8f]; // factor = 4/5
    
    SPVertex expectedVertex;
    expectedVertex.color = SPVertexColorMake(80 * 0.64f, 60 * 0.64f, 40 * 0.64f, 204 * 0.8f);
    
    [self compareVertex:expectedVertex withVertex:vertexData.vertices[0]];
}

- (void)testTransformVertices
{
    SPVertexData *vertexData = [[SPVertexData alloc] initWithSize:0 premultipliedAlpha:YES];
    
    SPVertex defaultVertex = [self defaultVertex];
    SPVertex secondVertex = [self defaultVertex];
    secondVertex.position.x = 1.0f;
    secondVertex.position.y = 2.0f;
    
    [vertexData appendVertex:defaultVertex];
    [vertexData appendVertex:secondVertex];
    [vertexData appendVertex:defaultVertex];
    
    SPMatrix *matrix = [[SPMatrix alloc] init];
    [matrix rotateBy:M_PI];
    
    [vertexData transformVerticesWithMatrix:matrix atIndex:1 numVertices:1];
    
    SPVertex expectedVertex = defaultVertex;
    expectedVertex.position.x = -1.0f;
    expectedVertex.position.y = -2.0f;
    
    [self compareVertex:vertexData.vertices[0] withVertex:defaultVertex];
    [self compareVertex:vertexData.vertices[1] withVertex:expectedVertex];
    [self compareVertex:vertexData.vertices[2] withVertex:defaultVertex];
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
        .color = SPVertexColorMakeWithColorAndAlpha(0, 1.0f)
    };
    return vertex;
}

- (SPVertex)anyVertex
{
    SPVertex vertex = {
        .position = GLKVector2Make(1.0f, 2.0f),
        .texCoords = GLKVector2Make(3.0f, 4.0f),
        .color = SPVertexColorMake(5, 6, 7, 127)
    };
    
    return vertex;
}

- (void)compareVertex:(SPVertex)v1 withVertex:(SPVertex)v2
{
    STAssertEquals(v1.color, v2.color, @"wrong color");
    STAssertEqualsWithAccuracy(v1.position.x,  v2.position.x,  E, @"wrong position.x");
    STAssertEqualsWithAccuracy(v1.position.y,  v2.position.y,  E, @"wrong position.y");
    STAssertEqualsWithAccuracy(v1.texCoords.x, v2.texCoords.x, E, @"wrong texCoords.x");
    STAssertEqualsWithAccuracy(v1.texCoords.y, v2.texCoords.y, E, @"wrong texCoords.y");
}

@end
