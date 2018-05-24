//
//  AliyunBlurFilter.m
//  qusdk
//
//  Created by Worthy on 2017/11/14.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunBlurFilter.h"



#define STRINGSIZE(x)  #x
#define SHADER_STRING(text) @ STRINGSIZE(text)

NSString *const kBlurImageTextureShaderString =
SHADER_STRING(
              attribute vec4 position;
              attribute vec2 inputTextureCoordinate;
              varying vec2 texCoord;
              uniform float uAspect;

              void main()
              {
                  texCoord = inputTextureCoordinate;
                  gl_Position = position;
              }
              );

NSString *const kBlurImageTextureFragmentString =
SHADER_STRING (
               precision mediump float;
               uniform sampler2D uSrc;
               uniform float uStrength;
               uniform highp vec2 iResolution;
               varying vec2 texCoord;

               void main(void) {
                   vec2 vStep = vec2(1.0/iResolution.x,1.0/iResolution.y);
                   vec2 coo_around[10];
                   vec4 nc;
                   vec4 sc;
                   coo_around[0] = texCoord + vStep * vec2(0.0, -3.0);
                   coo_around[1] = texCoord + vStep * vec2(0.0, 3.0);
                   coo_around[2] = texCoord + vStep * vec2(-3.0, 0.0);
                   coo_around[3] = texCoord + vStep * vec2(3.0, 0.0);
                   
                   coo_around[4] = texCoord + vStep * vec2(2.0, 6.0);
                   coo_around[5] = texCoord + vStep * vec2(6.0, 2.0);
                   coo_around[6] = texCoord + vStep * vec2(4.0, -5.0);
                   coo_around[7] = texCoord + vStep * vec2(-2.0, -6.0);
                   coo_around[8] = texCoord + vStep * vec2(-6.0, -2.0);
                   coo_around[9] = texCoord + vStep * vec2(-4.0, 5.0);
                   
                   sc  = texture2D(uSrc, texCoord);
                   nc  = sc*2.0;
                   nc += texture2D(uSrc, coo_around[0]) * 1.5;
                   nc += texture2D(uSrc, coo_around[1]) * 1.5;
                   nc += texture2D(uSrc, coo_around[2]) * 1.5;
                   nc += texture2D(uSrc, coo_around[3]) * 1.5;
                   
                   nc += texture2D(uSrc, coo_around[4]);
                   nc += texture2D(uSrc, coo_around[5]);
                   nc += texture2D(uSrc, coo_around[6]);
                   nc += texture2D(uSrc, coo_around[7]);
                   nc += texture2D(uSrc, coo_around[8]);
                   nc += texture2D(uSrc, coo_around[9]);
                   nc = nc / 14.0;
                   gl_FragColor = vec4(sc.rgb*(1.0 - uStrength) + nc.rgb*uStrength, sc.a);
//                   vec4 c = texture2D(uSrc, texCoord);
//                   float g = (c.r + c.g +c.b)/3.0;
//                   gl_FragColor = vec4(g,g,g,c.a);
                   
               }
);


@implementation AliyunBlurFilter {
    
    GLuint _vertexShader;
    GLuint _fragmentShader;
    
    GLuint _positionSlot;
    GLuint _coordsOutSlot;
    GLuint _textureSlot;
    GLuint _radiusSlot;

    GLuint _widthSlot;
    GLuint _heightSlot;
    
    GLuint _aspectSlot;
    GLuint _sigmaSlot;
    GLuint _dirSlot;
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
        _strength = 1;
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
    glUniform1f(_aspectSlot, _textureSize.height/_textureSize.width);
    glUniform1f(_radiusSlot, _strength);
    
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
    _vertexShader = [self compileShaderWithSource:kBlurImageTextureShaderString shaderType:GL_VERTEX_SHADER];
    _fragmentShader = [self compileShaderWithSource:kBlurImageTextureFragmentString shaderType:GL_FRAGMENT_SHADER];
    
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
    _textureSlot = glGetUniformLocation(program, "uSrc");
    _radiusSlot = glGetUniformLocation(program, "uStrength");
    _sizeSlot = glGetUniformLocation(program, "iResolution");
    _aspectSlot = glGetUniformLocation(program, "uAspect");

    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_coordsOutSlot);
    
    glUseProgram(0);
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



