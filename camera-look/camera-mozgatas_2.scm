(clear)
;//////////////// t1-t2 torus geometrey (t1 < t2 !)
;//////////////// r1-r2 torus resolution
(define t1 10)
(define t2 24)
(define r1 5)
(define r2 38)
(define speed 0)
(clip 1 1000)
;(blur .1)
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
    ;(shader "./shaders/phong_vert.glsl" "shaders/phong_frag.glsl")
    
    )

(light-position 0 #(1 0 10))

(define l (make-light 'point 'free))
;(light-diffuse 0 (vector 0 0 0))
;(light-specular 0 (vector 0 0 0))
(light-diffuse l (vector 1 1 1))
(light-specular l (vector 1 1 1))

(define obj
    (build-locator))
(define iko
    (with-state 
        (hint-sphere-map)
        (colour #(1 1 1))
        (specular (vector .1 .1 1))    
        (texture (load-texture "textures/colors.png"))
        (build-icosphere 2))
    )

(with-primitive iko
    (hide 1)
    (recalc-normals 0))

(define cam (build-locator))
(define pos 33)
(define str 0)


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

(define (rot t)
    (rotate (vector 0 0 t))
    (translate (vector t2 0 0))
    )

(define (ikos x)
    (for ((i (in-range x)))
        (with-state
            
            (hint-sphere-map)
            (colour #(1 1 1))
            (specular (vector 1 1 1))    
            (texture (load-texture "textures/D111.png"))
            
            
            (identity)
            (rotate (vector 1 0 (* (time) t2)))
            (translate (vmul (vector  
                        (+ (/ t2 (/ x (gl 0) 3)) (sin (degrees->radians (* i (/ 360 x))))) (sin x) 
                        (cos (degrees->radians (* i (/ 360 x))))) (/ x (gl 0) 3)))
            
            (draw-instance iko)
            ;(draw-cube)
            )
        )
    )

(smoothing-bias .96)
(every-frame
    (begin  
        
        (set! pos (+ pos (mouse-wheel)))
        
        (ikos 4)        
        (ikos (+ 1 (inexact->exact (floor (* 6 (gl 0))))))  
        (ikos 22)
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

