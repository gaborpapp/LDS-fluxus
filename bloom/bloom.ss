#lang racket
(require fluxus-018/fluxus)

(provide bloom)

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

(define (bloom strength size)
    (shader-source bloom-vert bloom-frag)
    (shader-set! #:tex 0 #:width (exact->inexact (vx size))
                         #:height (exact->inexact (vy size))
                 #:strength strength))

