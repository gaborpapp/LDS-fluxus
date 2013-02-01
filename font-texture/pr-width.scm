; pr-width function test - counts bound coordinates of a primitive
(clear)
(define tr (build-cube))
(with-primitive tr
    (scale 2)
    (translate #(45 0 3)))
(build-cube)
(define (pr-width pr)
    (with-primitive pr
        (apply-transform pr)
        (let [(vx-min (vx (pdata-ref "p" 0)))
                (vx-max (vx (pdata-ref "p" 0)))]
            (pdata-map! (lambda (p) 
                    (when (< (vx p) vx-min) (set! vx-min (vx p)))
                    (when (> (vx p) vx-max) (set! vx-max (vx p)))
                    p)
                "p")
            (vector vx-max vx-min))))
(display (pr-width tr))