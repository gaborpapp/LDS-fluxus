; os x: copy the lds and polyhedra folders to ~/Documents/Fluxus/collects
(require lds/dof)
(require lds/titles)
(require polyhedra/polyhedra)

;%%%%%%%%%%%%%% OSC %%%%%%%%%%%%%%%

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
(define slide6 0.5)
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
(gain .01)


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

(define wireopacity 0)
(define solid-opacity 0)
(define point-scale 0)
(define point-colour 0)

; linux: uncomment these lines and run this script in this directory
; to be able to use the modules
;(require "lds/dof.ss")
;(require "lds/titles.ss")
;(require "polyhedra/polyhedra.ss")

; parameters to tune

; tunnel parameters
(define tunnel-inner-radius 11)
(define tunnel-outer-radius 27)
(define tunnel-slices 8)
(define tunnel-stacks 64)
(define tunnel-texture '( 
        "ink0.png"
        "d111.png" 
        "d77.png" 
        "grafika.png" 
        "beach.png" 
        "szin.png"
        "minta.png"
        ) )
;(define tunnel-texture-1 "D111.png")
(set-num-frequency-bins 8)

(define data-folder "data") ; for textures and title font

(define polyhedron-id 8) ; polyhedra index from the polyhedra list below
(define polyhedron-scale 2.4)
(define polyhedron-envmap "beach.png")

(define clip-near .1) ; clip plane distances - change for fov
(define clip-far 1000)

(define camera-distance 300) ; distance of camera from the followed object

; depth of field parameters
(define dof-aperture .06) ; smaller value result in shallower blur range
(define dof-focus .26) ; focus from 0. to 1, 0 is the camera position
(define dof-maxblur .1) ; maximum blur

(define bloom .2) ; bloom

(define pp-size 1024) ; pixel primitive size for rendering - bigger gives better quality, but slower

(define title-id 9)
(define title-appears-in-sec 35) ; title appears in this seconds after running the script


;------------------------------------------------------------------------------

; list of polyhedron to choose from
(define polyhedra '(medial-disdyakistriacontahedron
        great-dodecahemidodecahedron
        great-icosihemidodecahedron
        great-stellated-truncated-dodecahedron
        zonohedron-7-random
        tetradyakishexahedron
        stellated-icosahedron-5
        cubitruncated-cuboctahedron
        disdyakisdodecahedron
        great-cubicuboctahedron
        j86
        octagonal-dipyramid))

;------------------------------------------------------------------------------

(clear)

; lock camera
(set-camera-transform (mtranslate #(0 0 -10)))

; create a render buffer for post processing (dof, bloom)
(define render-buffer (build-pixels pp-size pp-size #t))
(with-primitive render-buffer
    (scale #(21 17 1)))

; returns the world position of the grabbed primitive
(define (get-pos)
    (let ([t (get-global-transform)])
        (vector (vector-ref t 12)
            (vector-ref t 13)
            (vector-ref t 14))))

(define (set-target-camera eye target up)
    (let* ([zaxis (vnormalise(vsub eye target))]
            [xaxis  (vnormalise(vcross up zaxis))] 
            [yaxis (vcross zaxis xaxis)]
            [orientation (vector (vx xaxis) (vx yaxis) (vx zaxis) 0
                    (vy xaxis) (vy yaxis) (vy zaxis) 0
                    (vz xaxis) (vz yaxis) (vz zaxis) 0
                    0 0 0 1)]
            [translation (mtranslate (vector (- (vx eye)) (- (vy eye)) (- (vz eye)) 1))]
            [camera-matrix (mmul orientation translation)])
        (set-camera camera-matrix)))

;------------------------------------------------------------------------------

; logaritmic gh
(define (gl n)
    (log (+ 1 (gh n))))

; normalized logarithmic gh
(define ngl
    (let* ([gl-limits (make-vector (get-num-frequency-bins) (vector 1000. 0))]
            [max-count 10000]
            [counter max-count])
        (lambda (i)
            (when (zero? counter)
                (set! gl-limits (make-vector (get-num-frequency-bins) (vector 1000. 0)))
                (set! counter max-count))
            (set! counter (- counter 1))
            (let* ([j (remainder i (get-num-frequency-bins))]
                    [v (gl j)]
                    [limits (vector-ref gl-limits j)])
                (when (< v (vx limits))
                    (vector-set! gl-limits j (vector v (vy limits))))
                (when (> v (vy limits))
                    (vector-set! gl-limits j (vector (vx limits) v)))
                (let ([new-limits (vector-ref gl-limits j)])
                    (/ (- v (vx new-limits)) (- (vy new-limits) (vx new-limits))))))))

(define tunnel (with-pixels-renderer render-buffer
        (build-torus tunnel-inner-radius tunnel-outer-radius
            tunnel-slices tunnel-stacks)))

; lists for particles and connector lines
(define object-points '())
(define tunnel-points '())
(define all-points '())
(define particle-sum 0)

(with-pixels-renderer render-buffer
    (clip clip-near clip-far)
    (with-primitive tunnel
        
        ;(hint-off 'depth-sort)
        ;(line-width 10)
        (pdata-map! (λ (n) (vmul n -1)) "n")
        (poly-convert-to-indexed)
        (pdata-add "p1" "v")
        (pdata-copy "p" "p1")
        (pdata-add "nt" "v")    
        (pdata-copy "t" "nt")
        (for ([i (in-range 0 (pdata-size) 1)])
            (let* ([c (pdata-ref "p" i)])
                (set! tunnel-points (cons c tunnel-points))))))

; camera following the object
(define camera-eye (with-pixels-renderer render-buffer (build-locator)))
(define camera-target (with-pixels-renderer render-buffer
        (build-locator)))

; object being followed
(define object (with-pixels-renderer render-buffer
        (build-polyhedron (list-ref polyhedra polyhedron-id))))

(with-pixels-renderer render-buffer
    (with-primitive object
        (scale polyhedron-scale)        
        (apply-transform)
        
        
        (pdata-add "p1" "v")
        (pdata-copy "p" "p1")
        (for ([i (in-range 0 (pdata-size) 1)])
            (let ([c (pdata-ref "p" i)])
                (set! object-points (cons c object-points))))))

(set! all-points (append object-points tunnel-points))
(set! particle-sum (length all-points))

(define particles (with-pixels-renderer render-buffer
        (with-state
            (build-particles particle-sum))))

(with-pixels-renderer render-buffer
    (with-primitive particles
        (pdata-index-map!
            (λ (i c) (vector 1 .1)) "c")
        (pdata-index-map!
            (λ (i s) .1) "s")))

(define (mouse-look)
    (let* ([max tunnel-inner-radius]
            [min (- tunnel-inner-radius)]
            [x (+ (/ (* (mouse-x) (- max min)) (vx (get-screen-size))) min)]
            [y (+ (/ (* (mouse-y) (- max min)) (vy (get-screen-size))) min)])
        (translate (vector x 0 (- y)))))

(define (rot t)
    (rotate (vector 0 0 t))
    (translate (vector tunnel-outer-radius 0 0)))

(define (draw-lines)
    
    (if (= s1 1)
        (begin
            (wire-colour (ngl 0))
            (wire-opacity 1)
            (line-width (ngl 1)))
        (wire-opacity 0)
        
        )
    #;(if (= s2 1)
        (wire-colour (rgb->hsv (vector  (abs (sin (time))) (abs (cos (time))) (rndf) .9)))
        (wire-colour 1))
    
    (with-primitive particles
        (for ([i (in-range 0 particle-sum 1)])
            (let ([v0  (pdata-ref "p" i)]
                    [v1 (pdata-op "closest" "p" i)])
                (draw-line (vmul v0  1) v1)))))

(define (destroyer) (with-pixels-renderer render-buffer (destroy tunnel)))
(define (setter) 
    (begin 
        
        
        (set! object (with-pixels-renderer render-buffer
                (build-polyhedron (list-ref polyhedra num))))
        
        (with-pixels-renderer render-buffer
            (with-primitive object
                (scale (list-ref polyhedra-scale-list num))        
                (apply-transform)
                ; (poly-convert-to-indexed)
                
                (pdata-add "p1" "v")
                (pdata-copy "p" "p1")
                (for ([i (in-range 0 (pdata-size) 1)])
                    (let ([c (pdata-ref "p" i)])
                        (set! object-points (cons c object-points))))))
        
        (set! all-points (append object-points tunnel-points))
        ))

(define (render-tunnel)
    
    
    ;    (when (= bn 1)
        ;        (set! camera-distance (+ 10 (inexact->exact (* (crndf) 100)))))
    
    (define up (vtransform (vector 0 0 1) (mrotate (vector 0 (* 20 (time)) 0))))
    (with-pixels-renderer render-buffer
        (clip clip-near clip-far)
        
        (set! object-points '())
        
        (with-primitive tunnel
            (pdata-index-map! (λ (i c) (ngl (remainder i (+ 1 (inexact->exact (floor (* slide2 10))))))) "c")
            (backfacecull 0)
            (line-width (* 5 (ngl 0)))
            ;(hint-none)
            (hint-unlit)
            (wire-opacity slide2)
            (opacity slide1)
            ;(wire-opacity slide8)
            ;(wire-colour (vector 1 0 0))
            (if (= s1 1)
                (hint-on  'vertcols )
                (hint-off  'vertcols ))
            (if (= s2 1)
                (hint-on  'solid )
                (hint-off  'solid 'none))
            ;(hint-vertcols)
            ;(hint-sphere-map)
            (when (and (= s3 1) (= (ngl 0) 1))
                (let* ([tex1 (random 6)]
                        [tex2 (random 6)])
                    (multitexture 0 (load-texture (string-append data-folder "/textures/" (list-ref tunnel-texture tex1))))
                    (multitexture 1 (load-texture (string-append data-folder "/textures/" (list-ref tunnel-texture tex2))))
                    )
                ; (multitexture 0 (load-texture (string-append data-folder "/textures/" (list-ref tunnel-texture 4))))
                
                )
            ;(multitexture 0 (load-texture (string-append data-folder "/textures/" "d111.png")))
            ;(multitexture 1 (load-texture (string-append data-folder "/textures/" tunnel-texture-1)))
            (hint-anti-alias)
            ;
            
            (pdata-index-map!
                (lambda (n t)
                    (vadd  t (vector 0  (* .1 (gl 0)) (gl 1))) 
                    )
                "t")
            
            
            (if (= s4 1)
                (specular (vector 1 (ngl 0) .0))
                
                (specular (vector 0 0 .0))
                )
            
            
            (if (> slide7 .1)
                (pdata-index-map! (lambda (i p p1 n)
                        (vadd (vmul n (* (gl i) 16)) p1))
                    "p" "p1" "n")
                (pdata-map! (lambda (p p1 n)
                        p1)
                    "p" "p1" "n")
                
                )
            
            )
        
        (with-primitive object
            (hint-anti-alias)
            ;(hint-on 'vertcols )
            
            #;(when (> slide2 .7)
                (hint-ignore-depth))
            
            ;(hint-sphere-map)
            (colour #(1 1 1))            
            ;(hint-none)            
            (hint-wire)
            (line-width (* 1 (ngl 0)))
            
            (backfacecull 0)
            (specular (vector .4 .4 .4))
            (recalc-normals 0)
            ;(opacity (* solid-opacity (ngl 0)))
            (identity)
            (rotate (vector 0 (gl 0) (* (time) tunnel-outer-radius)))
            (translate (vector (+ (cos(time)) tunnel-outer-radius) (* 5 (abs (sin (time)))) (* 5 (sin (time)))))
            ;(wire-opacity wireopacity)
            
            
            (when (and (= b1 1)( = (ngl 0) 1))
                (pdata-index-map! (lambda (i p p1 n)
                        (vadd (vmul n (* 23 (gl i)) ) p1))
                    "p" "p1" "n"))
            
            (when (and (= b1 1)( = (ngl 0) 1))   
                (pdata-index-map! (lambda (i p p1 n)
                        (vadd (vector (* 1 (gl 0)) (* 1 (gl 0)) (* 1 (gl 0))) p1))
                    "p" "p1" "n")
                
                
                
                (for ([i (in-range 0 (pdata-size) 1)])
                    (let ([c (pdata-ref "p" i)])
                        (set! object-points (cons c object-points)))))
            
            (let ([m (with-primitive object (get-global-transform))])
                (with-primitive particles
                    (pdata-index-map!
                        (λ (i p)
                            (vtransform (with-primitive object (pdata-ref "p" i)) m))
                        "p")))
            
            
            
            (with-primitive particles
                (hint-vertcols)
                (for ([i (in-range 0 (length tunnel-points) 1)])
                    (let ([p (list-ref tunnel-points i)])
                        (pdata-set! "p" i p))
                    )
                
                
                (pdata-index-map! (λ (i c) 
                        (* 1 point-colour) ) "c")
                (pdata-index-map! (λ (i s) 
                        (* point-scale (* 1 (gl i))) ) "s")
                
                
                )
            ;(draw-lines)
            
            (with-primitive camera-target
                (identity)
                (hint-origin)
                (hide 1)
                (rot (* tunnel-outer-radius (time)))
                (when (mouse-button 2) (mouse-look)))
            
            (with-primitive camera-eye
                (identity)
                (rot (- (* tunnel-outer-radius (time)) camera-distance)))
            
            (set-target-camera (with-primitive camera-eye (get-pos))
                (with-primitive camera-target (get-pos))
                up)))
    
    
    ; plane for post-processed output
    (define plane (build-plane))
    (with-primitive plane
        (scale #(21 17 1)))
    
    ; setting up titles
    (titles-setup (string-append data-folder "/font/chunkfive.ttf"))
    (titles-seek title-id title-appears-in-sec)
    
    (define (osc-set)
        (set! wireopacity slide1) 
        (set! solid-opacity slide2) 
        (set! point-scale slide3)
        (set! point-colour slide4)
        
        (set! clip-near slide6) 
        ;    (set! camera-distance (* 10 (ngl 0) (abs (+ 1 slide5))))
        
        )
    
    
    (define (loop)
        (osc_recieve)
        (osc-set)
        (render-tunnel)
        (with-primitive plane
            ;(dof render-buffer #:aperture dof-aperture
                ;   #:focus dof-focus
                ;  #:maxblur dof-maxblur
                ;#:bloom bloom
                ; )
            (titles-update)))
    
    (every-frame (loop))
    