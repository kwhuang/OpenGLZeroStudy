//
//  FlashlightViewController.m
//  OpenGLZeroStudyDemo(7)-光照
//
//  Created by glodon on 2019/8/7.
//  Copyright © 2019 glodon. All rights reserved.
//

#import "FlashlightViewController.h"
#import "FlashlightBindObject.h"
#import "CubeManager.h"

@interface FlashlightViewController ()

@property (nonatomic ,strong) Vertex * vertexPostion ;
@property (nonatomic ,strong) Vertex * vertexTexture ;
@property (nonatomic ,strong) Vertex * vertexNormal ;
@property (nonatomic ,strong) TextureUnit * textureDiffuse ;
@property (nonatomic ,strong) TextureUnit * textureSpecular ;
@end

@implementation FlashlightViewController


-(void)initSubObject{
    //生命周期三秒钟
    __weakSelf
    self.bindObject = [FlashlightBindObject new];
    self.bindObject.uniformSetterBlock = ^(GLuint program) {
        weakSelf.bindObject->uniforms[MVPMatrix] = glGetUniformLocation(self.shader.program, "u_mvpMatrix");
        weakSelf.bindObject->uniforms[FL_UniformLocationModel] = glGetUniformLocation(self.shader.program, "u_model");
        weakSelf.bindObject->uniforms[FL_UniformLocationInvermodel] = glGetUniformLocation(self.shader.program, "u_inverModel");
        weakSelf.bindObject->uniforms[FL_UniformLocationviewPos] = glGetUniformLocation(self.shader.program, "viewPos");
        weakSelf.bindObject->uniforms[FL_UniformLocationMaterialTextureDiffuse] = glGetUniformLocation(self.shader.program, "material.diffuse");
        weakSelf.bindObject->uniforms[FL_UniformLocationMaterialTextureSpecular] = glGetUniformLocation(self.shader.program, "material.specular");
        weakSelf.bindObject->uniforms[FL_UniformLocationMaterialTextureShininess] = glGetUniformLocation(self.shader.program, "material.shininess");
        
        weakSelf.bindObject->uniforms[FL_UniformLocationLightPos] = glGetUniformLocation(self.shader.program, "light.position");
        weakSelf.bindObject->uniforms[FL_UniformLocationLightDirection] = glGetUniformLocation(self.shader.program, "light.direction");
             weakSelf.bindObject->uniforms[FL_UniformLocationLightCutOff] = glGetUniformLocation(self.shader.program, "light.cutOff");
        weakSelf.bindObject->uniforms[FL_UniformLocationLightAmbient] = glGetUniformLocation(self.shader.program, "light.ambient");
        weakSelf.bindObject->uniforms[FL_UniformLocationLightSpecular] = glGetUniformLocation(self.shader.program, "light.specular");
        weakSelf.bindObject->uniforms[FL_UniformLocationLightTDiffuse] = glGetUniformLocation(self.shader.program, "light.diffuse");
        weakSelf.bindObject->uniforms[FL_UniformLocationLightConstant] = glGetUniformLocation(self.shader.program, "light.constant");
        weakSelf.bindObject->uniforms[FL_UniformLocationLightLinear] = glGetUniformLocation(self.shader.program, "light.linear");
        weakSelf.bindObject->uniforms[FL_UniformLocationLightQuadratic] = glGetUniformLocation(self.shader.program, "light.quadratic");
        
    };
}



-(void)createShader{
    __weakSelf
    self.shader = [Shader new];
    [self.shader compileLinkSuccessShaderName:self.bindObject.getShaderName completeBlock:^(GLuint program) {
        [self.bindObject BindAttribLocation:program];
    }];
    if (self.bindObject.uniformSetterBlock) {
        self.bindObject.uniformSetterBlock(self.shader.program);
    }
}

-(void)createTextureUnit{
    UIImage *  image = [UIImage imageNamed:@"container2.png"];
    self.textureDiffuse = [TextureUnit new];
    [self.textureDiffuse setImage:image IntoTextureUnit:GL_TEXTURE0 andConfigTextureUnit:nil];
    
    image = [UIImage imageNamed:@"container2_specular.png"];
    self.textureSpecular =[TextureUnit new];
    [self.textureSpecular setImage:image IntoTextureUnit:GL_TEXTURE1 andConfigTextureUnit:nil];
    
}

double radians(int angle){
    return angle*M_PI/180;
}

-(void)loadVertex{
    //顶点数据缓存
    self.vertexPostion= [Vertex new];
    int vertexNum =[CubeManager getTextureNormalVertexNum];
    [self.vertexPostion allocVertexNum:vertexNum andEachVertexNum:3];
    for (int i=0; i<vertexNum; i++) {
        float onevertex[3];
        for (int j=0; j<3; j++) {
            onevertex[j]=[CubeManager getTextureNormalVertexs][i*8+j];
        }
        [self.vertexPostion setVertex:onevertex index:i];
    }
    [self.vertexPostion bindBufferWithUsage:GL_STATIC_DRAW];
    [self.vertexPostion enableVertexInVertexAttrib:BeginPosition numberOfCoordinates:3 attribOffset:0];
    
    self.vertexTexture = [Vertex new];
    [self.vertexTexture allocVertexNum:vertexNum andEachVertexNum:2];
    for (int i=0; i<vertexNum; i++) {
        float onevertex[2];
        for (int j=0; j<2; j++) {
            onevertex[j]=[CubeManager getTextureNormalVertexs][i*8+j+6];
        }
        [self.vertexTexture setVertex:onevertex index:i];
    }
    [self.vertexTexture bindBufferWithUsage:GL_STATIC_DRAW];
    [self.vertexTexture enableVertexInVertexAttrib:FL_BindAttribLocationTexture numberOfCoordinates:2 attribOffset:0];
    
    self.vertexNormal= [Vertex new];
    [self.vertexNormal allocVertexNum:vertexNum andEachVertexNum:3];
    for (int i=0; i<vertexNum; i++) {
        float onevertex[3];
        for (int j=0; j<3; j++) {
            onevertex[j]=[CubeManager getTextureNormalVertexs][i*8+j+3];
        }
        [self.vertexNormal setVertex:onevertex index:i];
    }
    [self.vertexNormal bindBufferWithUsage:GL_STATIC_DRAW];
    [self.vertexNormal enableVertexInVertexAttrib:FL_BindAttribLocationNormal numberOfCoordinates:3 attribOffset:0];
    
    GLKVector3 ambientLigh = GLKVector3Make(1.0, 1.0, 1.0);
    
    
    FL_Material material;
    
    material.shininess =0.6;
    [self.textureDiffuse bindtextureUnitLocationAndShaderUniformSamplerLocation:self.bindObject->uniforms[FL_UniformLocationMaterialTextureDiffuse]];
    [self.textureSpecular bindtextureUnitLocationAndShaderUniformSamplerLocation:self.bindObject->uniforms[FL_UniformLocationMaterialTextureSpecular]];
    glUniform1fv(self.bindObject->uniforms[FL_UniformLocationMaterialTextureShininess], 1, &material.shininess);
    
    FL_Light light;
    light.position =  GLKVector3Make(0.0f, 0.0f, 3.0f);
    light.ambient  =GLKVector3Make(0.2,0.2,0.2);
    light.diffuse  =GLKVector3Make(0.5,0.5,0.5);
    light.specular  =GLKVector3Make(1.0,1.0,1.0);
    light.constant = 1.0;
    light.linear = 0.09f    ;
    light.quadratic = 0.032f;
//     0.0f, 0.0f, 3.0f
    const float YAW         = -90.0f;
    const float PITCH       =  0.0f;
    GLKVector3 front;
    front.x = cos(radians(YAW)) * cos(radians(PITCH));
    front.y = sin(radians(PITCH));
    front.z = sin(radians(YAW)) * cos(radians(PITCH));
    front = GLKVector3Normalize(front);
    light.direction = front;
    light.cutOff = cos(12.5*M_PI/180);
    glUniform3fv(self.bindObject->uniforms[FL_UniformLocationLightPos], 1, &light.position);
    glUniform3fv(self.bindObject->uniforms[FL_UniformLocationLightAmbient], 1, &light.ambient);
    glUniform3fv(self.bindObject->uniforms[FL_UniformLocationLightSpecular], 1, &light.specular);
    glUniform3fv(self.bindObject->uniforms[FL_UniformLocationLightTDiffuse], 1, &light.diffuse);
    glUniform1fv(self.bindObject->uniforms[FL_UniformLocationLightConstant], 1, &light.constant);
    glUniform1fv(self.bindObject->uniforms[FL_UniformLocationLightLinear], 1, &light.linear);
    glUniform1fv(self.bindObject->uniforms[FL_UniformLocationLightQuadratic], 1, &light.quadratic);
    glUniform3fv(self.bindObject->uniforms[FL_UniformLocationLightDirection], 1, &light.direction);
    glUniform1fv(self.bindObject->uniforms[FL_UniformLocationLightCutOff], 1, &light.cutOff);

}


-(GLKMatrix4)getMVP{
    GLfloat aspectRatio= CGRectGetWidth([UIScreen mainScreen].bounds) / CGRectGetHeight([UIScreen mainScreen].bounds);
    GLKMatrix4 projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(85.0f),
                              aspectRatio,
                              0.1f,
                              100.0f);
    GLKMatrix4 modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         0.0f, 0.0f, 3.0f,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
    return GLKMatrix4Multiply(projectionMatrix,modelviewMatrix);
}




-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    GLKMatrix4  mvp= [self getMVP];
    
    glUniformMatrix4fv(self.bindObject->uniforms[MVPMatrix], 1, 0,mvp.m);
    
    GLKVector3 viewPos = GLKVector3Make(.0, 0.0,2.0);
    glUniform3fv(self.bindObject->uniforms[FL_UniformLocationviewPos], 1,viewPos.v);
    
    GLKVector3 cubePositions[] = {
        GLKVector3Make( 0.0f,  0.0f,  0.0f),
        GLKVector3Make( 2.0f,  5.0f, -15.0f),
        GLKVector3Make(-1.5f, -2.2f, -2.5f),
        GLKVector3Make(-3.8f, -2.0f, -12.3f),
        GLKVector3Make( 2.4f, -0.4f, -3.5f),
        GLKVector3Make(-1.7f,  3.0f, -7.5f),
        GLKVector3Make( 1.3f, -2.0f, -2.5f),
        GLKVector3Make( 1.5f,  2.0f, -2.5f),
        GLKVector3Make( 1.5f,  0.2f, -1.5f),
        GLKVector3Make(-1.3f,  1.0f, -1.5f)
    };
    
    static GLfloat angleTimer=0;
    angleTimer +=5;
    
    for (int i=0; i<10; i++) {
        GLKMatrix4 mode =GLKMatrix4Identity;
        
        GLKVector3 temp =cubePositions[i];
        mode = GLKMatrix4TranslateWithVector3(mode, temp);
        float angle = 20.0f * i+angleTimer;
        mode = GLKMatrix4RotateWithVector3(mode, angle*M_PI/180, GLKVector3Make(1.0, 0.3, 0.5));
        glUniformMatrix4fv(self.bindObject->uniforms[FL_UniformLocationModel], 1, 0,mode.m);
        bool isSuccess = YES;
        mode = GLKMatrix4InvertAndTranspose(mode,&isSuccess);
        glUniformMatrix4fv(self.bindObject->uniforms[FL_UniformLocationInvermodel], 1, 0,mode.m);
        
        [self.vertexPostion drawVertexWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:[CubeManager getNormalVertexNum]];
    }
    
    
}



@end
