(clear)
(define text "Give my try a love")
(define kern (list 1 3.4 1.4 2.8    2 2   3.8 1 3 1.7 2  
        2 2   2 2   1.5 2.5 2.6 3 4 5 6 2 3 2 3))

(define letters '())

(define (sum-kern kern-list refnum)
    (if (> refnum 0)
        (+ (list-ref kern-list refnum) (sum-kern kern-list (- refnum 1)))
        (list-ref kern-list refnum)))

(for [(i (in-range 0 (string-length text)))]
    (with-state
        (translate (vector (sum-kern kern i) 0 0))
        (set! letters (append letters 
                (list (build-type "chunkfive.ttf" 
                        (substring text i (+ i 1))))))))

(every-frame
    (for [(i (in-range 0 (string-length text)))]
            (with-primitive (list-ref letters i)
                (identity)
                (translate #(-28 0 15))
                (translate (vector (sum-kern kern i) 
                                    0 
                                   (* 99 (sin (- (* i .2) (time)))))))))
