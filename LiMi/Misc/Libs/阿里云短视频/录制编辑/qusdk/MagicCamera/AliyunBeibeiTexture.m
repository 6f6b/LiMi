//
//  AliyunBeibeiTexture.m
//  qurecorder
//
//  Created by dangshuai on 17/3/2.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunBeibeiTexture.h"


#define STRINGSIZE(x)  #x
#define SHADER_STRING(text) @ STRINGSIZE(text)

NSString *const kGPUImageTextureShaderString =
SHADER_STRING(

              attribute vec4 position;
              attribute vec4 inputTextureCoordinate;
              varying vec2 texture;
              void main (void) {
                  gl_Position = position;
                  texture = inputTextureCoordinate.xy;
              }
);

NSString *const kGPUImageTextureFragmentString =
SHADER_STRING (
                                                                     
            varying highp vec2 texture;
            uniform sampler2D inputImageTexture;
            void main() {
                highp vec4 textureColor = texture2D(inputImageTexture, texture);
                highp float v = textureColor.r*0.5+textureColor.g*0.3+textureColor.b*0.4;
//                gl_FragColor = vec4(v,v,v,1.0);
                gl_FragColor = textureColor.bgra;
            }
);


@implementation AliyunBeibeiTexture {
    
    GLuint _vertexShader;
    GLuint _fragmentShader;
    
    GLuint _positionSlot;
    GLuint _coordsOutSlot;
    GLuint _textureSlot;
    
    GLenum program;
    GLuint _tmp_fb;
    GLuint _tmp_tid;
    int _tmp_w;
    int _tmp_h;
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
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)_tmp_w, (int)_tmp_h, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
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
        _tmp_w = textureSize.width;
        _tmp_h = textureSize.height;
        [self setupBuffers];
    }
    return self;
}

- (NSInteger)renderWithTexture:(NSInteger)textureName textureSize:(CGSize)textureSize {
    
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
    _vertexShader = [self compileShaderWithSource:kGPUImageTextureShaderString shaderType:GL_VERTEX_SHADER];
    _fragmentShader = [self compileShaderWithSource:kGPUImageTextureFragmentString shaderType:GL_FRAGMENT_SHADER];
    
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
