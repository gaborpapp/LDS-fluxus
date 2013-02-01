(clear)

;(set-camera-transform (mtranslate #(0 0 -10)))

(define p (build-pixels 1024 1024 #t))

(define bloom-vert "
    void main()
    {
        gl_FrontColor = gl_Color;
        gl_Position = ftransform();
        gl_TexCoord[ 0 ] = gl_MultiTexCoord0;
    }")

;; very simple bloom shader, shamelessly stolen from http://myheroics.wordpress.com/
(define bloom-frag "
    uniform sampler2D tex;
    uniform float width;
    uniform float height;
    uniform float strength;

    void main()
    {
        vec4 sum = vec4( 0 );
        vec2 texcoord = gl_TexCoord[ 0 ].xy;

        for ( int i = -4 ; i < 4; i++ )
        {
            for ( int j = -3; j < 3; j++ )
            {
                sum += texture2D( tex, texcoord + vec2( j, i ) * 0.004 ) * strength;
            }
        }

        if ( texture2D( tex, texcoord ).r < 0.3 )
        {
            gl_FragColor = sum * sum * 0.012 + texture2D( tex, texcoord );
        }
        else
        if ( texture2D( tex, texcoord ).r < 0.5 )
        {
            gl_FragColor = sum * sum * 0.009 + texture2D( tex, texcoord );
        }
        else
        {
            gl_FragColor = sum * sum* 0.0075 + texture2D( tex, texcoord );
        }
        
    }")

(define loc
    (with-pixels-renderer p
        (build-locator)))

(with-pixels-renderer p
    (hint-sphere-map)
    (texture (load-texture "transp.png"))
    (clip 1 20)
    (for ([i (in-range 55)])
        (with-primitive (build-icosphere 2)
            (colour (hsv->rgb (vector (rndf) .4 1)))
            (translate (vmul (srndvec) 8))
            (rotate (vmul (crndvec) 180))
            (recalc-normals 0)
            (parent loc))))

(with-primitive p
    (scale 0))

(with-primitive (build-plane)
    (scale #(21 17 1))
    (texture (pixels->texture p))
    (shader-source bloom-vert bloom-frag)
    (shader-set! #:tex 0 #:width (exact->inexact (with-primitive p (pixels-width)))
                         #:height (exact->inexact (with-primitive p (pixels-height)))
                 #:strength .3))

(define (loop)
    (with-pixels-renderer p
        (with-primitive loc
            (rotate (vector 0 .2 0)))))

(every-frame (loop))

