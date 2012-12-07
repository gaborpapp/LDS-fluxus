; moving lightsource

(clear)

(define p (build-torus 2.5 3 50 50))
(with-primitive p
    (backfacecull 0)
    (pdata-rnd-map!
        .4
        (lambda (p)
            (vadd p (vmul (crndvec) .3)))
        "p")
    (recalc-normals 1)
    (pdata-map!
        (lambda (n)
            (vmul n -1))
        "n"))

(with-primitive p
    (colour #(.1 .3 1))
    (shader "phong_vert.glsl" "phong_frag.glsl"))

(light-position 0 #(1 0 10))

(every-frame
    (begin
        (let ([p (vtransform #(4 1 0) (mrotate (vector 0 0 (* 50 (time)))))])
            (light-position 0 p)
            (with-state
                (translate p)
                (scale .1)
                (hint-unlit)
                (draw-sphere)))
    (with-primitive p
        (shinyness 1.0)
        (ambient .05)
        (rotate (vector (* 0 (delta)) 0 (* 0 (delta)))))))

