; moving lightsource

(clear)

(define-syntax pdata-rnd-map!
    (syntax-rules ()
        ((_ probability proc pdata-write-name pdata-read-name ...)
            (letrec
                ((loop (lambda (n total)
                            (cond ((not (> n total))
                                    (when (< (rndf) probability)
                                        (pdata-set! pdata-write-name n
                                            (proc (pdata-ref pdata-write-name n)
                                                (pdata-ref pdata-read-name n) ...)))
                                    (loop (+ n 1) total))))))
                (loop 0 (- (pdata-size) 1))))))

(define felho
    (for* ([x (in-range 0 5 1)]
            [y (in-range 0 5 1)])
        
        (with-state
            (colour (vector 1 1.0 1.0 ))
            
            (translate (vector (+ 100 (* (random 26) x)) (+ (random 25) 5) (+ 2 (* (random 8) 1 y))))
            (texture (load-texture "D77.png"))            
            ;(rotate (vector 45 45 45))
            (scale  (* (random 12) .4))
            (build-cube)
            
            
            )       
        
        )    
    )


(define p (build-torus 25 100 10 25))
(with-primitive p
    (backfacecull 0)
    (pdata-rnd-map!
        .9
        (lambda (p)
            (vadd p (vmul (crndvec) .7)))
        "p")
    (recalc-normals 1)
    (pdata-map!
        (lambda (n)
            (vmul n -1))
        "n")
    (hint-wire)
    )

(with-primitive p
    (hint-sphere-map)
    (texture (load-texture "transp.png"))
    (colour #(.9 .3 .2))
    (shader "phong_vert.glsl" "phong_frag.glsl"))

(light-position 0 #(1 0 10))

(define l (make-light 'point 'free))
;(light-diffuse 0 (vector 0 0 0))
;(light-specular 0 (vector 0 0 0))
(light-diffuse l (vector 1 1 1))
(light-specular l (vector 1 1 1))


(define obj (build-locator))


(lock-camera obj) 


(every-frame
    (begin
        (let ([p (vtransform #(40 100 0) (mrotate (vector 0 0 (* 50 (time)))))])
            
            (light-position l p)
            (with-primitive obj
                (identity)
                (translate p)
                ))
        (set-camera-transform (mrotate (vector 90 (* 120 (sin (* .1 (time)))) (+ 100 (* -50 (time)))) ))  
        (clip (+ .2 (abs (* .5 (cos (* .2 (time)))))) 11130)
        (with-primitive p
            (specular (vector 1 1 .3))
            (shinyness 2)                       
            (ambient .2)
            (rotate (vector (* 0 (delta)) (* 0 (delta)) (* 0 (delta))))
            )))

