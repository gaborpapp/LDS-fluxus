(clear)

(require "dof.ss")

(set-camera-transform (mtranslate #(0 0 -10)))

(define p (build-pixels 1024 1024 #t))

(define loc
    (with-pixels-renderer p
        (build-locator)))

(with-pixels-renderer p
    (hint-sphere-map)
    (texture (load-texture "fluxus-icon.png"))
    (clip 1 20)
    (for ([i (in-range 55)])
        (with-primitive (build-icosphere 2)
            (colour (hsv->rgb (vector (rndf) 1 1)))
            (translate (vmul (srndvec) 8))
            (rotate (vmul (crndvec) 180))
            (recalc-normals 0)
            (parent loc))))

(with-primitive p
    (scale 0))

(with-primitive (build-plane)
    (scale #(21 17 1))
    (dof p #:aperture .05 #:focus .01 #:maxblur 2.))

(define (loop)
    (with-pixels-renderer p
        (with-primitive loc
            (rotate (vector 0 .2 0)))))

(every-frame (loop))

