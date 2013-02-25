#lang racket
(require fluxus-018/fluxus)

(provide dof)

(define dof-vert "
    void main()
    {
        gl_FrontColor = gl_Color;
        gl_Position = ftransform();
        gl_TexCoord[ 0 ] = gl_MultiTexCoord0;
    }")

; based on http://artmartinsh.blogspot.com/2010/02/glsl-lens-blur-filter-with-bokeh.html by Martins Upitis
(define dof-frag "
    uniform sampler2D tColor;
    uniform sampler2D tDepth;
    
    uniform float maxblur;  // max blur amount
    uniform float aperture; // aperture - bigger values for shallower depth of field
    
    uniform float focus;
    uniform vec2 size;
    
    uniform float bloomStrength;

    float zfar = 100.;
    float znear = 1.;
    
    float linearizeDepth( float z )
    {
        return ( 2.0 * znear ) / ( zfar + znear - z * ( zfar - znear ) );
    }
    
    void main()
    {
        vec2 uv = gl_TexCoord[ 0 ].st;
        vec2 aspectcorrect = vec2( 1.0, size.x / size.y );
        vec4 depth1 = texture2D( tDepth, uv );
        
        float factor = linearizeDepth( depth1.x ) - focus;
        vec2 dofblur = vec2 ( clamp( factor * aperture, -maxblur, maxblur ) );
        
        vec2 dofblur9 = dofblur * 0.9;
        vec2 dofblur7 = dofblur * 0.7;
        vec2 dofblur4 = dofblur * 0.4;
        
        vec4 col = vec4( 0.0 );
        col += texture2D( tColor, uv );
        col += texture2D( tColor, uv + ( vec2(  0.0,   0.4  ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2(  0.15,  0.37 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2(  0.29,  0.29 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2( -0.37,  0.15 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2(  0.40,  0.0  ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2(  0.37, -0.15 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2(  0.29, -0.29 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2( -0.15, -0.37 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2(  0.0,  -0.4  ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2( -0.15,  0.37 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2( -0.29,  0.29 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2(  0.37,  0.15 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2( -0.4,   0.0  ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2( -0.37, -0.15 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2( -0.29, -0.29 ) * aspectcorrect ) * dofblur );
        col += texture2D( tColor, uv + ( vec2(  0.15, -0.37 ) * aspectcorrect ) * dofblur );
        
        col += texture2D( tColor, uv + ( vec2(  0.15,  0.37 ) * aspectcorrect ) * dofblur9 );
        col += texture2D( tColor, uv + ( vec2( -0.37,  0.15 ) * aspectcorrect ) * dofblur9 );
        col += texture2D( tColor, uv + ( vec2(  0.37, -0.15 ) * aspectcorrect ) * dofblur9 );
        col += texture2D( tColor, uv + ( vec2( -0.15, -0.37 ) * aspectcorrect ) * dofblur9 );
        col += texture2D( tColor, uv + ( vec2( -0.15,  0.37 ) * aspectcorrect ) * dofblur9 );
        col += texture2D( tColor, uv + ( vec2(  0.37,  0.15 ) * aspectcorrect ) * dofblur9 );
        col += texture2D( tColor, uv + ( vec2( -0.37, -0.15 ) * aspectcorrect ) * dofblur9 );
        col += texture2D( tColor, uv + ( vec2(  0.15, -0.37 ) * aspectcorrect ) * dofblur9 );
        
        col += texture2D( tColor, uv + ( vec2(  0.29,  0.29 ) * aspectcorrect ) * dofblur7 );
        col += texture2D( tColor, uv + ( vec2(  0.40,  0.0  ) * aspectcorrect ) * dofblur7 );
        col += texture2D( tColor, uv + ( vec2(  0.29, -0.29 ) * aspectcorrect ) * dofblur7 );
        col += texture2D( tColor, uv + ( vec2(  0.0,  -0.4  ) * aspectcorrect ) * dofblur7 );
        col += texture2D( tColor, uv + ( vec2( -0.29,  0.29 ) * aspectcorrect ) * dofblur7 );
        col += texture2D( tColor, uv + ( vec2( -0.4,   0.0  ) * aspectcorrect ) * dofblur7 );
        col += texture2D( tColor, uv + ( vec2( -0.29, -0.29 ) * aspectcorrect ) * dofblur7 );
        col += texture2D( tColor, uv + ( vec2(  0.0,   0.4  ) * aspectcorrect ) * dofblur7 );
        
        col += texture2D( tColor, uv + ( vec2(  0.29,  0.29 ) * aspectcorrect ) * dofblur4 );
        col += texture2D( tColor, uv + ( vec2(  0.4,   0.0  ) * aspectcorrect ) * dofblur4 );
        col += texture2D( tColor, uv + ( vec2(  0.29, -0.29 ) * aspectcorrect ) * dofblur4 );
        col += texture2D( tColor, uv + ( vec2(  0.0,  -0.4  ) * aspectcorrect ) * dofblur4 );
        col += texture2D( tColor, uv + ( vec2( -0.29,  0.29 ) * aspectcorrect ) * dofblur4 );
        col += texture2D( tColor, uv + ( vec2( -0.4,   0.0  ) * aspectcorrect ) * dofblur4 );
        col += texture2D( tColor, uv + ( vec2( -0.29, -0.29 ) * aspectcorrect ) * dofblur4 );
        col += texture2D( tColor, uv + ( vec2(  0.0,   0.4  ) * aspectcorrect ) * dofblur4 );
        
        col /= 41.0;

        // bloom
        vec4 sum = vec4( 0 );
        for ( int i = -4; i < 4; i++ )
        {
            for ( int j = -3; j < 3; j++ )
            {
                sum += texture2D( tColor, uv + vec2( j, i ) * 0.004 ) * bloomStrength;
            }
        }

        if ( col.r < 0.3 )
        {
            gl_FragColor = sum * sum * 0.012 + col;
        }
        else
        if ( col.r < 0.5 )
        {
            gl_FragColor = sum * sum * 0.009 + col;
        }
        else
        {
            gl_FragColor = sum * sum * 0.0075 + col;
        }

        gl_FragColor.a = 1.0;
    }")

(define (dof pprim #:aperture aperture #:focus focus #:maxblur maxblur #:bloom bloom)
    (texture-params 0 '(min linear mag linear))
    (texture-params 1 '(min linear mag linear))
    (multitexture 0 (pixels->texture pprim))
    (multitexture 1 (pixels->depth pprim))
    (shader-source dof-vert dof-frag)
    (shader-set! #:tColor 0 #:tDepth 1
        #:size (with-primitive pprim (vector (pixels-width) (pixels-height)))
        #:maxblur maxblur #:aperture aperture #:focus focus
        #:bloomStrength bloom))

