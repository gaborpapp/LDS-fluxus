(clear)
;osc setup iOS mrmr apphoz  - osx-en kell egy server
;én az OSCulator-t használom, néha sír h regisztráljak de megy.
;mrmr-en belül a performance.mmr default setupra működik ez
;mrmr/prefs/player név Gas

(osc-source "1337")


;BANK1 buttons/switches (a nagy + legalso utolsoelottisor button és legalso switchek csak)
(define bn 0) ;Nagy gomb
(define b1 0)
(define b2 0)
(define b3 0)
(define b4 0)
(define s1 0)
(define s2 0)
(define s3 0)
(define s4 0)


;BANK2 sliders
(define slide1 0)
(define slide2 0)
(define slide3 0)
(define slide4 0)
(define slide5 0)
(define slide6 0)
(define slide7 0)
(define slide8 0)

;BANK3 tactile-zones
(define tactile1 (vector 0 0 0))
(define tactile2 (vector 0 0 0))
(define tactile3 (vector 0 0 0))
(define tactile4 (vector 0 0 0))

;BANK4 3d -(2 ujjal!)
(define tactile3d (vector 0 0 0))
(define accelero (vector 0 0 0))


(define (osc_recieve)
    
    (displayln s4)
    
    (when (osc-msg "/mrmr pushbutton 1 Gas")
        (set! bn (osc 0)))
    (when (osc-msg "/mrmr pushbutton 13 Gas")
        (set! b1 (osc 0)))
    (when (osc-msg "/mrmr pushbutton 14 Gas")
        (set! b2 (osc 0)))
    (when (osc-msg "/mrmr pushbutton 15 Gas")
        (set! b3 (osc 0)))
    (when (osc-msg "/mrmr pushbutton 16 Gas")
        (set! b4 (osc 0)))
    (when (osc-msg "/mrmr pushbutton 17 Gas")
        (set! s1 (osc 0)))
    (when (osc-msg "/mrmr pushbutton 18 Gas")
        (set! s2 (osc 0)))
    (when (osc-msg "/mrmr pushbutton 19 Gas")
        (set! s3 (osc 0)))
    (when (osc-msg "/mrmr pushbutton 20 Gas")
        (set! s4 (osc 0)))


    (when (osc-msg "/mrmr slider horizontal 21 Gas")
        (set! slide1 (osc 0)))
    (when (osc-msg "/mrmr slider horizontal 22 Gas")
        (set! slide2 (osc 0)))
    (when (osc-msg "/mrmr slider horizontal 23 Gas")
        (set! slide3 (osc 0)))
    (when (osc-msg "/mrmr slider horizontal 24 Gas")
        (set! slide4 (osc 0)))
    (when (osc-msg "/mrmr slider horizontal 25 Gas")
        (set! slide5 (osc 0)))
    (when (osc-msg "/mrmr slider horizontal 26 Gas")
        (set! slide6 (osc 0)))
    (when (osc-msg "/mrmr slider horizontal 27 Gas")
        (set! slide7 (osc 0)))
    (when (osc-msg "/mrmr slider horizontal 28 Gas")
        (set! slide8 (osc 0)))
    
    (when (osc-msg "/mrmr tactilezone 29 Gas")
        (set! tactile1 (vector (osc 0) (osc 1) 0)))
    (when (osc-msg "/mrmr tactilezone 30 Gas")
        (set! tactile2 (vector (osc 0) (osc 1) 0)))
    (when (osc-msg "/mrmr tactilezone 31 Gas")
        (set! tactile3 (vector (osc 0) (osc 1) 0)))
    (when (osc-msg "/mrmr tactilezone 32 Gas")
        (set! tactile4 (vector (osc 0) (osc 1) 0)))
    
    (when (osc-msg "/mrmr accelerometer 33 Gas")
        (set! accelero (vector (osc 0) (osc 1) (osc 2))))
    (when (osc-msg "/mrmr tactile3D 34 Gas")
        (set! tactile3d (vector (osc 0) (osc 1) (osc 2))))
    
    
    
    )

(every-frame (osc_recieve))
