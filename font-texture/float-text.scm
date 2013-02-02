(clear)
(define tracks (list #(51.641179138    0.980231 "Give my try a love")
#(141.714285714 0.947282 "I wanna break free")
#(385.518367346 0.945634 "rippin up sound" )
#(674.539682539 0.939044 "birthday in budapest" )
#(908.945124716 0.802306 "metro to oktogon" )
#(1156.446621315 0.957166 "seminal kungfu" )
#(1413.375419501 0.795717 "the happy hungarian" )
#(1636.310204081 0.892916 "welcome to chicago" )
#(1876.408163265 0.855025 "align with this" )
#(2207.020408163 0.843493 "the csocso queens" )
#(2361.004988662 0.891269 "filterdisco revival" )
#(2719.706848072 0.884679 "the kindergarten")))

(define text "Give my try a love")
(define tit (build-type "chunkfive.ttf" text))
(define title (type->poly tit))
(with-primitive title 
    (pdata-copy "p" "p1")
    (translate #(0 5 -15))
    (rotate #(35 0 5)))

(with-primitive tit 
    (scale 0))


(define (update-text tm
    (with-primitive title
        (translate (vector (sin (time)) 0 0))
        (pdata-index-map! (lambda (i p p1) 
                (let [(p2 (vmix p1 p .95))]
                    (vector
                        (- (vx p2) (gh (sin (vx p2))))
                        (vy p2)
                        (- (vz p2) (gh (vx p2))))))
            "p" "p1")))


