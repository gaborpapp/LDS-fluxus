(require lds/dof) ; os x: copy dof.ss to ~/Documents/Fluxus/collects/lds
;(require "dof.ss")

(define tunnel-inner-radius 11)
(define tunnel-outer-radius 24)
(define tunnel-slices 18)
(define tunnel-stacks 38)

(define clip-near .7) ; clip plane distances - change for fov
(define clip-far 1000)

(define pp-size 1024) ; pixel primitive size for rendering

(define ikopoints '())
(define toruspoints '())
(define all-points '())
(define particle-sum 0)
;//////////////// 

(clear)

(set-camera-transform (mtranslate #(0 0 -10)))

(define render-buffer (build-pixels pp-size pp-size #t))
(with-primitive render-buffer
    (scale 0))

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

;////////////////
(define tunnel (with-pixels-renderer render-buffer
        (build-torus tunnel-inner-radius tunnel-outer-radius
            tunnel-slices tunnel-stacks)))

(with-pixels-renderer render-buffer    
    (clip clip-near clip-far)
    (with-primitive tunnel
        (backfacecull 0)
        (recalc-normals 1)
        (pdata-map! (λ (n) (vmul n -1)) "n")
        (hint-sphere-map)
        (multitexture 0 (load-texture "textures/D77.png"))
        (multitexture 1 (load-texture "textures/D111.png"))
        (poly-convert-to-indexed)
        (for ([i (in-range 0 (pdata-size) 1)])
            (let* ([c (pdata-ref "p" i)])
                (set! toruspoints (cons c toruspoints)))
            )
       
        ))

(define obj (with-pixels-renderer render-buffer
        (build-locator)))

(define ico (with-pixels-renderer render-buffer
        (build-icosphere 2)))

(with-pixels-renderer render-buffer
    (with-primitive ico
        (hint-sphere-map)
        (colour #(1 1 1))
        (specular (vector .1 .1 1))    
        (texture (load-texture "textures/colors.png"))
       ; (hide 1)
        (recalc-normals 0)
        (poly-convert-to-indexed)
        (for ([i (in-range 0 (pdata-size) 1)])
            (let ([c (pdata-ref "p" i)])
                (set! ikopoints (cons c ikopoints)))
            )
        )
    )
(set! all-points (append ikopoints toruspoints))
(set! particle-sum (length all-points))

(define particles (with-pixels-renderer render-buffer
    (with-state
        (scale 3)
        (build-particles particle-sum))
        ))

(with-pixels-renderer render-buffer
    (with-primitive particles 
        (pdata-index-map!
        (lambda (i c)
            (vector 1 1 0 1))
        "c")
        )
    )

(define cam (with-pixels-renderer render-buffer (build-locator)))
(define pos 12)

(define (mouse-look)
    (let* ([max tunnel-inner-radius]
            [min (- tunnel-inner-radius)]
            [x (+ (/ (* (mouse-x) (- max min)) (vx (get-screen-size))) min)]
            [y (+ (/ (* (mouse-y) (- max min)) (vy (get-screen-size))) min)])
        (translate (vector x 0 (- y)))))

(define (rot t)
    (rotate (vector 0 0 t))
    (translate (vector tunnel-outer-radius 0 0)))

(define (destroyer) 
   (set! ikopoints '())
    )
(define (render-tunnel)
    (define up (vtransform (vector 0 0 1) (mrotate (vector 0 (* 20 (time)) 0))))
    (with-pixels-renderer render-buffer
        (destroyer)
       
        (with-primitive ico 
            (identity)
            (rotate (vector 0 0 (* (time) tunnel-outer-radius)))
            (translate (vector tunnel-outer-radius 0 5))
            (for ([i (in-range 0 (pdata-size) 1)])
            (let ([c (pdata-ref "p" i)])
                (set! ikopoints (cons c ikopoints)))
            )
            )
        (set! all-points (append toruspoints ikopoints))


 (with-primitive particles 
  (for ([i (in-range 0 (pdata-size) 1)])
            (let ([p (list-ref all-points i)])
                (pdata-set! "p" i p))
            ))

        (with-primitive obj
            (identity)
            (hint-origin)          
            (hide 1)
            (rot (* tunnel-outer-radius (time)))
            (when (mouse-button 2) (mouse-look)))
        
        (with-primitive cam 
            (identity)
            (rot (- (* tunnel-outer-radius (time)) pos)))
        
        (set-target-camera (with-primitive cam (get-pos))
            (with-primitive obj (get-pos))
            up)))


(define plane (build-plane))
(with-primitive plane
    (scale #(21 17 1)))


(define (loop)
    (render-tunnel)
    (with-primitive plane
        (dof render-buffer #:aperture .09
            #:focus (+ .2 (* .2 (sin (* .5 (time)))))
            #:maxblur 1.5)))

(every-frame (loop))
