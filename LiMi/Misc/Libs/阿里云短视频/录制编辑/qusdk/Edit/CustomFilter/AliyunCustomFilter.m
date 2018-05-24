//
//  AliyunCustomFilter.m
//  qusdk
//
//  Created by Worthy on 2017/8/10.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCustomFilter.h"
#import <OpenGLES/ES2/gl.h>
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const VertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 varying vec2 textureCoordinate;
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

NSString *const FragmentShaderString = SHADER_STRING
(

 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float luminance = dot(textureColor.rgb, luminanceWeighting);
     lowp vec3 greyScaleColor = vec3(luminance);
     
     gl_FragColor = vec4(mix(greyScaleColor, textureColor.rgb, 2.5), textureColor.w);
     
 }
 );
@implementation AliyunCustomFilter {
    GLuint _frameBuffer;
    GLuint _program;
    GLuint _positionSlot;
    GLuint _texCoordSlot;
    GLuint _inputTexture;
    GLuint _outputTexture;
}

-(instancetype)initWithSize:(CGSize)size {
    self = [super init];
    if (self) {
        [self setupProgram];
        [self setupTextureWithSize:size];
    }
    return self;
}

- (int)render:(int)srcTexture size:(CGSize)size {
    glUseProgram(_program);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, size.width, size.height);
    glClearColor(0, 0, 1, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, srcTexture);
    glUniform1i(_inputTexture, 0);

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

    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, 0, 0, positionCoords);
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, 0, 0, textureCoords);
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_texCoordSlot);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    return _outputTexture;
}

- (void)setupTextureWithSize:(CGSize)size {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    

    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &_outputTexture);
    glBindTexture(GL_TEXTURE_2D, _outputTexture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _outputTexture, 0);
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
    
}


- (void)setupProgram
{
    GLuint vertexShader = [self loadShader:GL_VERTEX_SHADER
                                   withString:VertexShaderString];
    GLuint fragmentShader = [self loadShader:GL_FRAGMENT_SHADER
                                     withString:FragmentShaderString];
    
    _program = glCreateProgram();
    if (!_program) {
        NSLog(@"Failed to create program.");
        return;
    }
    
    glAttachShader(_program, vertexShader);
    glAttachShader(_program, fragmentShader);
    
    glLinkProgram(_program);
    
    // 检查错误
    GLint linked;
    glGetProgramiv(_program, GL_LINK_STATUS, &linked );
    if (!linked)
    {
        GLint infoLen = 0;
        glGetProgramiv (_program, GL_INFO_LOG_LENGTH, &infoLen );
        
        if (infoLen > 1)
        {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog (_program, infoLen, NULL, infoLog );
            NSLog(@"Error linking program:\n%s\n", infoLog );
            
            free (infoLog );
        }
        
        glDeleteProgram(_program);
        _program = 0;
        return;
    }
    
    glUseProgram(_program);
    
    _positionSlot = glGetAttribLocation(_program, "position");
    _texCoordSlot = glGetAttribLocation(_program, "inputTextureCoordinate");
    _inputTexture = glGetUniformLocation(_program, "inputImageTexture");
}

-(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString
{
    // Create the shader object
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        NSLog(@"Error: failed to create shader.");
        return 0;
    }
    
    // Load the shader source
    const char * shaderStringUTF8 = [shaderString UTF8String];
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    
    // Compile the shader
    glCompileShader(shader);
    
    // Check the compile status
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );
        
        if (infoLen > 1) {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog (shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:\n%s\n", infoLog );
            
            free(infoLog);
        }
        
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}


@end
