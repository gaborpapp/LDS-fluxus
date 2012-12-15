(clear)
(gravity (vector 0 -1 0))
(ground-plane #(0 1 0) 0)
(rotate #(-90 0 0))
(translate #(20 0 0))
(scale 82)
(build-plane)
(identity)
(collisions 1)
(define text "Give my try a love")
(define kern (list 1 3.4 1.4 2.8    2 2   4.1 1 3 1.7 2  
        2 2   2 2   1.5 2.5 2.8))

(define letters '())

(define (sum-kern kern-list refnum)
    (if (> refnum 0)
        (+ (list-ref kern-list refnum) (sum-kern kern-list (- refnum 1)))
        (list-ref kern-list refnum)))

(for [(i (in-range 0 (string-length text)))]
    (with-state
        (translate (vector (sum-kern kern i) 0 0))
        (let [(et (build-extruded-type "chunkfive.ttf" 
                        (substring text i (+ i 1)) 1))]
            (let [(ep (type->poly et))]
                (active-box ep)
                (set! letters (append letters (list ep)))
                (with-primitive et (scale 0))))))

(kick (list-ref letters 0) #(23 0 -.001))