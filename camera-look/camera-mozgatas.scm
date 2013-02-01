(clear)
;//////////////// t1-t2 torus geometrey (t1 < t2 !)
;//////////////// r1-r2 torus resolution
(define t1 10)
(define t2 24)
(define r1 18)
(define r2 38)
(define speed 1)
(clip .7 1000)
;//////////////// 

(define (get-pos)
    (let ([t (get-global-transform)])
        (vector (vector-ref t 12)
            (vector-ref t 13)
            (vector-ref t 14))))

(define (set-target-camera eye target up)
    (let* ( [zaxis (vnormalise(vsub eye target))]
            [xaxis  (vnormalise(vcross up zaxis))] 
            [yaxis (vcross zaxis xaxis)]
            [orientation (vector (vx xaxis) (vx yaxis) (vx zaxis) 0 (vy xaxis) (vy yaxis) (vy zaxis) 0 (vz xaxis) (vz yaxis) (vz zaxis) 0 0 0 0 1)]
            [translation (vector 1 0 0 0
                    0 1 0 0 
                    0 0 1 0 
                    (- (vx eye)) (- (vy eye)) (- (vz eye))  1)]
            [camera-matrix (mmul orientation translation)]
            )
        (set-camera camera-matrix)        
        )    
    )

;////////////////
(define p (build-torus t1 t2 r1 r2))
(with-primitive p
    (backfacecull 0)
    (recalc-normals 1)
    (pdata-map!
        (lambda (n)
            (vmul n -1))
        "n")
    ;     (hint-wire)
    
    (hint-sphere-map)
    (multitexture 0 (load-texture "textures/D77.png"))
    (multitexture 1 (load-texture "textures/D111.png"))
    ;(colour #(.2 0 0))
    ;(specular (vector 1 1 1))    
    ;(shader "phong_vert.glsl" "phong_frag.glsl")
    
    )

(light-position 0 #(1 0 10))

(define l (make-light 'point 'free))
;(light-diffuse 0 (vector 0 0 0))
;(light-specular 0 (vector 0 0 0))
(light-diffuse l (vector 1 1 1))
(light-specular l (vector 1 1 1))

(define obj
    (with-state 
        (hint-sphere-map)
        (colour #(1 1 1))
        (specular (vector .1 .1 1))    
        
        (texture (load-texture "textures/colors.png"))
        (build-icosphere 2)))
(with-primitive obj
    (recalc-normals 0))

(define cam (build-locator))
(define pos 12)
(define str 0)
(define (rot t)
    (rotate (vector 0 0 (+ t speed)))
    (translate (vector t2 0 0)))

(define (mouse-look)
    (let* ([max t1]
            [min (- t1)]
            [x (+ (/ (* (mouse-x) (- max min)) (vx (get-screen-size))) min)]
            [y (+ (/ (* (mouse-y) (- max min)) (vy (get-screen-size))) min)]
            )
        
        (translate (vector x 0 (- y)))
        ))


(define (strafe)
    (let*  ([max t1]
            [min (- t1)]
            )
        (if (key-special-pressed 100) (set! str (- str .1)) "")
        (if (key-special-pressed 102) (set! str (+ str .1)) "")
        
        (translate (vector str 0 0)) 
        ))

(every-frame
    (begin  
        ;(displayln (mouse-wheel))       
        (set! pos (+ pos (mouse-wheel)))
        
        
        (with-primitive obj 
            (identity)
            (hint-origin)          
            (rot (* t2 (time)))
            (if (mouse-button 2) (mouse-look) "")
            )
        (with-primitive cam 
            (identity)
            (rot (- (* t2 (time)) pos))
            ;(strafe)
            )

        (define up (vtransform (vector 0 0 1) (mrotate (vector 0 (* 20 (time)) 0))))
        (let ([p (with-primitive obj (get-pos))])
            (wire-colour #(1 .9 .1))
            (draw-line p (vadd p up)))

        (set-target-camera (with-primitive cam (get-pos))
            (with-primitive obj (get-pos))
            up)
        )    
    )

