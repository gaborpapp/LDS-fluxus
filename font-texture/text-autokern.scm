(clear)
(define text "Give my try a love")
(define letters '())
(define kern '())

(define (pr-width pr)
    (with-primitive pr        
        (apply-transform)
        (let [(vx-min (vx (pdata-ref "p" 0)))
                (vx-max (vx (pdata-ref "p" 0)))]
            (pdata-map! (lambda (p) 
                    (when (< (vx p) vx-min) (set! vx-min (vx p)))
                    (when (> (vx p) vx-max) (set! vx-max (vx p)))
                    p)
                "p")
            (- vx-max vx-min))))

(define (sum-kern kern-list refnum)
    (if (> refnum 0)
        (+ (list-ref kern-list refnum) (sum-kern kern-list (- refnum 1)))
        (list-ref kern-list refnum)))


(for [(i (in-range 0 (string-length text)))]
    (let [(et (build-extruded-type "chunkfive.ttf" 
                    (substring text i (+ i 1)) 1))]
        (let [(ep (type->poly et))]
            (set! letters (append letters (list ep)))
            (set! kern (append kern (list (pr-width ep))))
            (with-primitive et (scale 0)))))


(for [(i (in-range 0 (length letters)))]
    (with-primitive (list-ref letters i)
        (translate (vector (sum-kern kern i) 0 0))))
