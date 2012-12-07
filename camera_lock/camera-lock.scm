(clear) 
(clear-colour (rgb->hsv (vector .5 .3 .3)))

(define cam #(-0.6708927154541016 0.10036182403564453 -0.7347314357757568 0.0 -0.014769908040761948 0.988794207572937 0.1485525220632553 0.0 0.7414071559906006 0.11051473766565323 -0.6618925333023071 0.0 0.0 0.0 -54.13999938964844 1.0))
;(set-camera-transform cam)
(unlock-camera)

(define poz (vector 0 0 0))

(with-state 
    (build-torus .7 6 3 36)
    )
(random-seed 6)

(define hegyek
    (for* ([x (in-range 0 5 1)]
            [y (in-range 0 5 1)])
        
        (with-state
            
            (colour (rgb->hsv (vector .3 .09 .1 .7)))
            
            (translate (vector (+ 200 (* (random 23) 8 x)) -2 (+ 200 (* (random 20) 14 y))))
            ;(texture (load-texture "D77.png"))
            
            ;(rotate (vector 45 45 45))
            (scale  (* (random 12) .12))
            (load-primitive "piramis.obj")
            )       
        
        )    
    )

(define felho
    (for* ([x (in-range 0 5 1)]
            [y (in-range 0 5 1)])
        
        (with-state
            
            (colour (vector 1 1.0 1.0 ))
            
            (translate (vector (+ 200 (* (random 25) 8 x)) (+ (random 25) 142) (+ 200 (* (random 19) 14 y))))
            (texture (load-texture "D77.png"))
            
            ;(rotate (vector 45 45 45))
            (scale  (* (random 12) 2))
            (build-cube)
            )       
        
        )    
    )

(define obj (build-cube)) 

(with-state  
    ;(hint-wire)
    (hint-unlit)
    
    (texture (load-texture "D77.png"))
    
    (colour (vector 0.8 0.8 0.8))
    (translate (vector 0 -2 0))
    (rotate (vector 90 0 0))  
    (scale 10000) 
    (build-plane)
)

(lock-camera obj) 
(camera-lag 0) 
(define (animate)
    (clip 2 11002)
    (with-primitive obj
        (hint-none)
        (hint-wire)
        (identity)
        
        (translate (vector (* 12 (sin (time))) 0 (+ 0 (* 5 (cos (time))))))
        (set! poz (pdata-ref "p" 1))
        (displayln poz)
        )
    )                     
(every-frame (animate))