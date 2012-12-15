(clear)
(define text "Give my try a love")
(translate #(-18 5 -15))
(rotate #(35 0 5))
(define tit (build-type "chunkfive.ttf" text))
(define title (type->poly tit))
(with-primitive title (pdata-copy "p" "p1"))
(with-primitive tit 
    (scale 0))

(every-frame
    (with-primitive title
        (pdata-index-map! (lambda (i p p1) 
                (let [(p2 (vmix p1 p .95))]
                    (vector
                        (- (vx p2) (gh (sin (vx p2))))
                        (vy p2)
                        (- (vz p2) (gh (vx p2))))))
            "p" "p1")))


