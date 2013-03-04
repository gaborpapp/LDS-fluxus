#lang racket
(require fluxus-018/fluxus)

(provide titles-setup
         titles-seek
         titles-update)

(define tracks (list
        #(51.641179138 0.980231 "Give my try a love")
        #(141.714285714 0.947282 "I wanna break free")
        #(385.518367346 0.945634 "rippin up sound")
        #(674.539682539 0.939044 "birthday in budapest")
        #(908.945124716 0.802306 "metro to oktogon")
        #(1156.446621315 0.957166 "seminal kungfu")
        #(1413.375419501 0.795717 "the happy hungarian")
        #(1636.310204081 0.892916 "welcome to chicago")
        #(1876.408163265 0.855025 "align with this")
        #(2207.020408163 0.843493 "the csocso queens")
        #(2361.004988662 0.891269 "filterdisco revival")
        #(2719.706848072 0.884679 "the kindergarten")))

(define text-prims '())
(define debug-start-time 0) ; 0 = not debug mode
(define start-time (- (flxtime) debug-start-time))    

(define next-track 0)
(define play-timespan 10)

; making type primitives and polys
(define (titles-setup font-path)
    (set! debug-start-time 0)
    (set! start-time (flxtime))

    (for [(i (in-range 0 (length tracks)))]
        (with-state
            (let [(et (build-extruded-type font-path (vz (list-ref tracks i)) .01))]
                (let [(ep (type->poly et))]
                    (set! text-prims (append text-prims (list ep)))
                    (with-primitive ep 
                        (translate #(0 0 -9999))
                        (pdata-copy "p" "p1"))
                    (with-primitive et (scale 0)))))))

(define (titles-seek title-id [seek-before-sec 10])
    (set! debug-start-time (- (vector-ref (list-ref tracks title-id) 0) seek-before-sec))
    (set! start-time (- (flxtime) debug-start-time)))

(define (update-text tm)
    (for [(i (in-range 0 (length tracks)))]
        (when (< (abs (- tm (vx (list-ref tracks i)))) 
                (abs (- tm (vx (list-ref tracks next-track)))))
            (set! next-track i)))
    (let* ([rel-pos (- tm (vx (list-ref tracks next-track)))]
           [gh-scale (* 3 (/ (abs rel-pos) play-timespan))])
        (when (< (abs rel-pos) play-timespan) 
            (with-primitive (list-ref text-prims next-track)
                (hint-ignore-depth)
                (hint-unlit)
                (identity)
                (translate (vector (- (* -.1 (* rel-pos rel-pos rel-pos)) 25) 0 -20))
                (rotate (vector -15 (* 5 (sin (flxtime))) 0))
                (pdata-index-map! (lambda (i p p1) 
                        (let [(p2 (vmix p1 p .95))]
                            (vector
                                (- (vx p2) (clamp (gh (sin (vx p2))) 0 gh-scale))
                                (vy p2)
                                (- (vz p2) (clamp (gh (vx p2)) 0 gh-scale)))))
                    "p" "p1")))))

(define (titles-update)
    (update-text (- (flxtime) start-time)))
