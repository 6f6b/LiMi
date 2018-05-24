//
//  AliyunMosaicFilter.m
//  qusdk
//
//  Created by Worthy on 2017/11/14.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMosaicFilter.h"

#define STRINGSIZE(x)  #x
#define SHADER_STRING(text) @ STRINGSIZE(text)

NSString *const kMosaicImageTextureShaderString =
SHADER_STRING(
              
              attribute vec4 position;
              attribute vec4 inputTextureCoordinate;
              varying vec2 texCoord;
              void main (void) {
                  gl_Position = position;
                  texCoord = inputTextureCoordinate.xy;
              }
              );

NSString *const kMosaicImageTextureFragmentString =
SHADER_STRING (
               varying highp vec2 texCoord;
               uniform sampler2D inputImageTexture;
               uniform highp vec2 iResolution;
               uniform highp float radius;
               void main() {
                   highp float x = texCoord.x * iResolution.x;
                   highp float y = texCoord.y * iResolution.y;
                   highp float realX = floor(x/radius + 0.5) * radius;
                   highp float realY = floor(y/radius + 0.5) * radius;
                   gl_FragColor = texture2D(inputImageTexture, vec2(realX/iResolution.x, realY/iResolution.y) );
               }
               );


@implementation AliyunMosaicFilter {
    
    GLuint _vertexShader;
    GLuint _fragmentShader;
    
    GLuint _positionSlot;
    GLuint _coordsOutSlot;
    GLuint _textureSlot;
    
    GLuint _radiusSlot;
    GLuint _sizeSlot;
    
    GLenum program;
    GLuint _tmp_fb;
    GLuint _tmp_tid;
    int present_viewport[4];
    GLint present_fb[1];
}

- (void)tmp_init {
    glGenFramebuffers(1, &_tmp_fb);
    
    glGenTextures(1, &_tmp_tid);
    if(_tmp_tid > 0) {
        glBindTexture(GL_TEXTURE_2D, _tmp_tid);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)_textureSize.width, (int)_textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    }
    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, present_fb);
    glBindFramebuffer(GL_FRAMEBUFFER, _tmp_fb);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _tmp_tid, 0);
    int status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        glBindFramebuffer(GL_FRAMEBUFFER, present_fb[0]);
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, present_fb[0]);
}

- (void)tmp_delete {
    if(glIsFramebuffer(_tmp_fb)) {
        glDeleteFramebuffers(1, &_tmp_fb);
        _tmp_fb = 0;
    }
    if(glIsTexture(_tmp_tid)) {
        glDeleteTextures(1, &_tmp_tid);
        _tmp_tid = 0;
    }
}

- (instancetype)initWithTextureSize:(CGSize)textureSize {
    self = [super init];
    if (self) {
        _textureSize = textureSize;
        _radius = 12;
        [self setupBuffers];
    }
    return self;
}

- (int)renderWithTexture:(NSInteger)textureName textureSize:(CGSize)textureSize {
    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, present_fb);
    glGetIntegerv(GL_VIEWPORT, present_viewport);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _tmp_fb);
    
    glViewport(0, 0, (int)textureSize.width, (int)textureSize.height);
    if(true) {
        glClearColor(1, 1, 0, 1);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
    glUseProgram(program);
    
    
    glActiveTexture(GL_TEXTURE0);
    
    glBindTexture(GL_TEXTURE_2D, (GLuint)textureName);
    
    
    glUniform1i(_textureSlot, 0);
    
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    
    GLfloat positionCoords[] = {
        -1.0f, -1.0f, 0.0f,
        1.0f, -1.0f, 0.0f,
        -1.0f, 1.0f, 0.0f,
        1.0f, 1.0f, 0.0f,
    };
    GLfloat textureCoords[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    glUniform2f(_sizeSlot, _textureSize.width, _textureSize.height);
    GLfloat r = (GLfloat)_radius;
    glUniform1f(_radiusSlot, r);
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_coordsOutSlot);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, 0, 0, positionCoords);
    glVertexAttribPointer(_coordsOutSlot, 2, GL_FLOAT, 0, 0, textureCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, 0, 0, 0);
    glVertexAttribPointer(_coordsOutSlot, 2, GL_FLOAT, 0, 0, 0);
    glUseProgram(0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, present_fb[0]);
    glViewport(present_viewport[0], present_viewport[1], present_viewport[2], present_viewport[3]);
    
    
    return (NSInteger)_tmp_tid;
}

- (void)setupBuffers {
    
    [self tmp_init];
    _vertexShader = [self compileShaderWithSource:kMosaicImageTextureShaderString shaderType:GL_VERTEX_SHADER];
    _fragmentShader = [self compileShaderWithSource:kMosaicImageTextureFragmentString shaderType:GL_FRAGMENT_SHADER];
    
    program = glCreateProgram();
    
    glAttachShader(program, _vertexShader);
    glAttachShader(program, _fragmentShader);
    
    glLinkProgram(program);
    
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    glUseProgram(program);
    
    
    _positionSlot = glGetAttribLocation(program, "position");
    _coordsOutSlot = glGetAttribLocation(program, "inputTextureCoordinate");
    _textureSlot = glGetUniformLocation(program, "inputImageTexture");
    
    _radiusSlot = glGetUniformLocation(program, "radius");
    _sizeSlot = glGetUniformLocation(program, "iResolution");
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_coordsOutSlot);
    
    glUseProgram(0);
    //    glUniform1i(_textureSlot, 0);
}

- (GLuint)compileShaderWithSource:(NSString *)shaderSourceName shaderType:(GLenum)shaderType {
    
    const char *shaderStringUTF8 = [shaderSourceName UTF8String];
    int length = (int)[shaderSourceName length];
    
    GLuint shader = glCreateShader(shaderType);
    
    glShaderSource(shader, 1, &shaderStringUTF8, &length);
    
    glCompileShader(shader);
    
    GLint error;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &error);
    if (error == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@>>>>>>%@",shaderSourceName, messageString);
        exit(1);
    }
    
    return shader;
}
@end


