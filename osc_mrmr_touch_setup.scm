(clear)
;osc setup iOS mrmr apphoz  
;mrmr-en belül a performance.mmr default setupra működik ez
;mrmr/prefs/player név Gas


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
(define tac3d (vector 0 0 0))
(define acc (vector 0 0 0))

(define (osc-drain path [value #f])
    (if (osc-msg path)
        (osc-drain path (osc 0))
        value))




(define (osc_recieve)
    
    (let ([cbn (osc-drain "/mrmr/pushbutton/1/Gas")])
        (when cbn
            (set! bn cbn)))
    (let ([cb1 (osc-drain "/mrmr/pushbutton/13/Gas")])
        (when cb1
            (set! b1 cb1)))
    (let ([cb2 (osc-drain "/mrmr/pushbutton/14/Gas")])
        (when cb2
            (set! b2 cb2)))
    (let ([cb3 (osc-drain "/mrmr/pushbutton/15/Gas")])
        (when cb3
            (set! b3 cb3)))
    (let ([cb4 (osc-drain "/mrmr/pushbutton/16/Gas")])
        (when cb4
            (set! b4 cb4)))
    (let ([cs1 (osc-drain "/mrmr/pushbutton/17/Gas")])
        (when cs1
            (set! s1 cs1)))
    (let ([cs2 (osc-drain "/mrmr/pushbutton/18/Gas")])
        (when cs2
            (set! s2 cs2)))
    (let ([cs3 (osc-drain "/mrmr/pushbutton/19/Gas")])
        (when cs3
            (set! s3 cs3)))
    (let ([cs4 (osc-drain "/mrmr/pushbutton/20/Gas")])
        (when cs4
            (set! s4 cs4)))    
    
    
    (let ([sl1 (osc-drain "/mrmr/slider/horizontal/21/Gas")])
        (when sl1
            (set! slide1 sl1)
            ))  
    (let ([sl2 (osc-drain "/mrmr/slider/horizontal/22/Gas")])
        (when sl2
            (set! slide2 sl2)
            ))  
    (let ([sl3 (osc-drain "/mrmr/slider/horizontal/23/Gas")])
        (when sl3
            (set! slide3 sl3)
            ))  
    (let ([sl4 (osc-drain "/mrmr/slider/horizontal/24/Gas")])
        (when sl4
            (set! slide4 sl4)
            ))  
    (let ([sl5 (osc-drain "/mrmr/slider/horizontal/25/Gas")])
        (when sl5
            (set! slide5 sl5)))  
    (let ([sl6 (osc-drain "/mrmr/slider/horizontal/26/Gas")])
        (when sl6
            (set! slide6 sl6)))  
    (let ([sl7 (osc-drain "/mrmr/slider/horizontal/27/Gas")])
        (when sl7
            (set! slide7 sl7)))  
    (let ([sl8 (osc-drain "/mrmr/slider/horizontal/28/Gas")])
        (when sl8
            (set! slide8 sl8)))  
    
    (let*  ([tac1x (osc-drain "/mrmr/tactilezoneX/29/Gas")]
            [tac1y (osc-drain "/mrmr/tactilezoneY/29/Gas")])
        (when tac1x 
            (vector-set! tactile1 0 tac1x))
        (when tac1y 
            (vector-set! tactile1 1 tac1y))
        )  
    (let*  ([tac2x (osc-drain "/mrmr/tactilezoneX/30/Gas")]
            [tac2y (osc-drain "/mrmr/tactilezoneY/30/Gas")])
        (when tac2x 
            (vector-set! tactile2 0 tac2x))
        (when tac2y
            (vector-set! tactile2 1 tac2y))
        )  
    (let*  ([tac3x (osc-drain "/mrmr/tactilezoneX/31/Gas")]
            [tac3y (osc-drain "/mrmr/tactilezoneY/31/Gas")])
        (when tac3x 
            (vector-set! tactile3 0 tac3x))
        (when tac3y 
            (vector-set! tactile3 1 tac3y))
        )  
    (let*  ([tac4x (osc-drain "/mrmr/tactilezoneX/32/Gas")]
            [tac4y (osc-drain "/mrmr/tactilezoneY/32/Gas")])
        (when tac4x 
            (vector-set! tactile4 0 tac4x))
        (when tac4y
            (vector-set! tactile4 1 tac4y))
        )  
    
    
    (let*  ([accelx (osc-drain "/mrmr/accelerometerX/33/Gas")]
            [accely (osc-drain "/mrmr/accelerometerY/33/Gas")]
            [accelz (osc-drain "/mrmr/accelerometerZ/33/Gas")]
            )
        (when accelx
            (vector-set! acc 0 accelx))
        (when accely
            (vector-set! acc 1 accely))
        (when accelz
            (vector-set! acc 2 accelz))
        )  
    
    (let*  ([tac3dx (osc-drain "/mrmr/tactile3DX/34/Gas")]
            [tac3dy (osc-drain "/mrmr/tactile3DY/34/Gas")]
            [tac3dz (osc-drain "/mrmr/tactile3DZ/34/Gas")]
            )
        (when tac3dx
            (vector-set! tac3d 0 tac3dx))
        (when tac3dy
            (vector-set! tac3d 1 tac3dy))
        (when tac3dz
            (vector-set! tac3d 2 tac3dz))
        )
    )

(osc-source "1337")

(every-frame (osc_recieve))
