(clear)

(hint-ignore-depth)
(hint-anti-alias)

(wire-colour #(1 .5))
(line-width 5)

(define p-count 512)

(define size 20) ; particle field dimension (size x size)

(define ns .1) ; noise scale

;; helper functions
(define (polar->cartesian r a)
    (vector (* r (cos a)) (* r (sin a)) 0))

(define (fmod-vector v l)
    (list->vector
        (map
            (lambda (x)
                (fmod (+ x l) l))
            (vector->list v))))

(define (rndvec2d)
          (vector (flxrnd) (flxrnd) 0))

(translate (vector (/ size -2) (/ size -2) 0))

;; setup particles
(define p (build-particles p-count))

(with-primitive p
    (blend-mode 'src-alpha 'one)
    (pdata-map!
        (lambda (p)
            (vmul (rndvec2d) size))
        "p")
    (pdata-map!
        (lambda (s) .2) "s")
    (pdata-map!
        (lambda (c)
            (vector 1 .5))
        "c"))


(define (draw-lines)
    (with-primitive p
        (for ([i (in-range 0 p-count)])
             (let ([v0 (pdata-ref "p" i)]
                   [v1 (pdata-op "closest" "p" i)])
                    (draw-line v0 v1)))))

(define (move-particles)
    (with-primitive p
        (pdata-index-map!
            (lambda (i p)
                (let ([ang (* 6.28 (noise (* ns (vx p)) (* ns (vy p)) (* ns (time))))])
                    (fmod-vector
                        (vadd p (polar->cartesian .1 ang)) size)))
            "p")))

(every-frame (begin
                (move-particles)
                (draw-lines)))
