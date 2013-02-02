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

(define text-prims '())
(define debug-start-time 1403) ; 0 = not debug mode
(define start-time (- (time) debug-start-time))    

(define next-track 0)
(define play-timespan 10)

; making type primitives and polys

(for [(i (in-range 0 (length tracks)))]
    (with-state
        (let [(et (build-extruded-type "chunkfive.ttf" (vz (list-ref tracks i)) .01))]
            (let [(ep (type->poly et))]
                (set! text-prims (append text-prims (list ep)))
                (with-primitive ep 
                    (translate #(0 0 -9999))
                    (pdata-copy "p" "p1"))
                (with-primitive et (scale 0))))))



(define (update-text tm)
    (for [(i (in-range 0 (length tracks)))]
        (when (< (abs (- tm (vx (list-ref tracks i)))) 
                (abs (- tm (vx (list-ref tracks next-track)))))
            (set! next-track i)))
    ;(displayln tm)
    (let [(rel-pos (- tm (vx (list-ref tracks next-track))))]
        (when (< (abs rel-pos)  play-timespan) 
            (with-primitive (list-ref text-prims next-track)
                (identity)
                (translate (vector (- (* -.1 (* rel-pos rel-pos rel-pos)) 13) 0 -18))
                (rotate (vector -15 (* 5 (sin (time))) 0))
                (pdata-index-map! (lambda (i p p1) 
                        (let [(p2 (vmix p1 p .95))]
                            (vector
                                (- (vx p2) (gh (sin (vx p2))))
                                (vy p2)
                                (- (vz p2) (gh (vx p2))))))
                    "p" "p1")))))


(every-frame (update-text (- (time) start-time)))