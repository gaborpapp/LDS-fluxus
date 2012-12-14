(clear)
(define text "Give my try a love")
(define tit (build-type "chunkfive.ttf" text))
(define title (type->poly tit))
(with-primitive tit 
    (scale 0))

(every-frame
    (with-primitive title
        (pdata-index-map! (lambda (i p) (vector
                    (+ (* .04 (sin (* 22 (+ i (time))))) (vx p))
                    (vy p)
                    (+ (* .002 (sin (* 8 (+ i (time))))) (vz p))))
                "p")))
    
    
    