(clear)

(define p (build-pixels 256 256 #t))

(with-pixels-renderer p
    (clear-colour (vector 1 .6 .1)))

(with-state
    (hint-unlit)
    (translate #(1.1 0 0))
    (texture (pixels->depth p))
    (build-plane))

(every-frame
    (with-pixels-renderer p
        (random-seed 0)
        (for ([i (in-range 55)])
            (with-state
                (rotate (vector 0 (* 20 (time)) 0))
                (translate (vmul (srndvec) 8))
                (draw-cube)))))