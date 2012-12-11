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

(define p (build-torus 25 100 40 80))
(with-primitive p
    (translate #(100 0 0))
    (rotate #(90 0 0)))

(define (decay)
    (with-primitive p
        (backfacecull 0)
        (pdata-rnd-map!
            .1
            (lambda (p)
                (vadd p (vmul (crndvec) .1)))
            "p")
        (recalc-normals 1)
        (pdata-map!
            (lambda (n)
                (vmul n -1))
            "n")))

(with-primitive p
    (shinyness 5.0)
    (ambient .01)
    (colour #(.1 .3 .6))
    (shader "phong_vert.glsl" "phong_frag.glsl"))

(decay)

(define (anim)
    (decay)
    (with-primitive p
        (rotate (vector 0 0 -1))))

(every-frame (anim))
