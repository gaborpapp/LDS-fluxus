(clear)
;//////////////// t1-t2 torus geometrey (t1 < t2 !)
;//////////////// r1-r2 torus resolution
(define t1 10)
(define t2 60)
(define r1 6)
(define r2 44)
;//////////////// 
(define p (build-torus t1 t2 r1 r2))
(with-primitive p
    (backfacecull 0)
    (recalc-normals 1)
    (pdata-map!
        (lambda (n)
            (vmul n -1))
        "n")
    (hint-wire)
    (colour #(.8 .6 .6))
    (specular (vector .1 .2 .1))
    
    (shader "phong_vert.glsl" "phong_frag.glsl")
    )

(define l (make-light 'point 'free))
;(light-diffuse l (vector .1 1 1))
;(light-specular l (vector 1 .1 1))

(define obj (build-locator))

(lock-camera obj) 
(every-frame
    (begin
        (let ([p (vtransform (vector t2 0 0) (mrotate (vector 0 0 (* t2 (time)))))])
            
            (light-position l p)
            (with-primitive obj
                (identity)
                (translate p)
                ))
        (set-camera-transform (mrotate (vector -90 0 (* (- t2) (time))))) ))  
(clip .99 10000)
(with-primitive p
    (rotate (vector (* 0 (delta)) (* 0 (delta)) (* 0 (delta))))
    )))

