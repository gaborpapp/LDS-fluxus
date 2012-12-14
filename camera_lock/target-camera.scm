(clear)
(define targetobj 
    (with-state 
        (hint-origin)
        (translate (vmul (rndvec) 8))
        (build-cube)
        ))
(define camobj 
    (with-state 
        (hint-origin)
        
        (translate (vmul (rndvec) 8))
        (build-locator)
        ))

(with-primitive
    (build-sphere 32 32)       
    (hint-solid)
    (hint-wire)
    (scale 12)
    (recalc-normals 1)
    (backfacecull 0)
    (pdata-map!
        (lambda (n)
            (vmul n -1))
        "n")
    
    )


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
(every-frame
    (begin
        (with-primitive targetobj
            (identity)
            (colour (vector 0 0 1))
            (translate (vmul (vector (cos (time)) (sin (time)) 0) 10))
            )
        (with-primitive camobj
            (identity)
            (translate (vmul (vector (cos (- (time) 1)) (sin (- (time) 1)) 0) 10))
            )
        
        (set-target-camera (with-primitive camobj (get-pos))
            (with-primitive targetobj (get-pos))
            (vector 0 1 1))
        ))

