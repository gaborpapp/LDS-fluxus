(clear)

(set-camera-transform (mtranslate #(0 0 -10)))

(define p (build-pixels 1024 1024 #t))

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
        
        gl_FragColor = col / 41.0;
        gl_FragColor.a = 1.0;
    }")

(define loc
    (with-pixels-renderer p
        (build-locator)))

(with-pixels-renderer p
    (hint-sphere-map)
    (texture (load-texture "fluxus-icon.png"))
    (clip 1 20)
    (for ([i (in-range 55)])
        (with-primitive (build-icosphere 2)
            (colour (hsv->rgb (vector (rndf) 1 1)))
            (translate (vmul (srndvec) 8))
            (rotate (vmul (crndvec) 180))
            (recalc-normals 0)
            (parent loc))))

(with-primitive p
    (scale 0))

(define q (with-state
        (scale #(21 17 1))
        (build-plane)))

(with-primitive q
    (multitexture 0 (pixels->texture p))
    (multitexture 1 (pixels->depth p))
    (shader-source dof-vert dof-frag)
    (shader-set! #:tColor 0 #:tDepth 1
        #:size (with-primitive p (vector (pixels-width) (pixels-height)))
        #:maxblur 2. #:aperture 0.05 #:focus .1))

(define (loop)
    (with-pixels-renderer p
        (with-primitive loc
            (rotate (vector 0 .2 0)))))

(every-frame (loop))

