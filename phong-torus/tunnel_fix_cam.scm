(clear)
;//////////////// t1-t2 torus geometrey (t1 < t2 !)
;//////////////// r1-r2 torus resolution
(define t1 10)
(define t2 24)
(define r1 8)
(define r2 18)
(clip 1 1000)
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
    
;    (hint-sphere-map)
    (texture (load-texture "textures/D77.png"))
   
    (colour #(.8 .6 .1))
    (specular (vector .1 .2 .1))    
    (shader "phong_vert.glsl" "phong_frag.glsl")
    
    )

(light-position 0 #(1 0 10))

(define l (make-light 'point 'free))
;(light-diffuse 0 (vector 0 0 0))
;(light-specular 0 (vector 0 0 0))
(light-diffuse l (vector 1 1 1))
(light-specular l (vector 1 1 1))

(define obj
    (build-cube)
    )
(define cam (build-locator))

(define (rot t)
    (rotate (vector 0 0 t))
    (translate (vector t2 0 0)))

(every-frame
    (begin  
        (with-primitive obj 
            (identity)
            (hint-none)
            (rot (time))
;            (translate (vmul (vector (sin(time)) (cos (time)) 0) t2))
            ;(translate (vtransform (vector t2 0 0) (mrotate (vector 0 0 (* t2 (time))))))
            )
        (with-primitive cam 
            (identity)
            (hint-origin)
 ;           (translate (vmul (vector (sin (- (time) .4)) (cos (- (time) .4)) 0) t2))
            (translate (vtransform (vector t2 0 0) (mrotate (vector 0 0 (*  .9999 t2 (time))))))
            )
        
        (set-target-camera (with-primitive cam (get-pos))
            (with-primitive obj (get-pos))
            (vector 0 0 1))
        )    
    )

