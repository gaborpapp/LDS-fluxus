; os x: copy the lds and polyhedra folders to ~/Documents/Fluxus/collects
(require lds/titles)
(require polyhedra/polyhedra)

; linux: uncomment these lines and run this script in this directory
; to be able to use the modules
;(require "lds/dof.ss")
;(require "lds/titles.ss")
;(require "polyhedra/polyhedra.ss")

; parameters to tune
(require fluxus-018/fluxus-midi)
(midiin-open 0)

; audio - mac specific
(start-audio "" 512 44100)

; tunnel parameters
(define tunnel-inner-radius 26)
(define tunnel-outer-radius 37)
(define tunnel-slices 15)
(define tunnel-stacks 47)

(define tunnel-texture-namebase "z")
(define object-texture-namebase "o")

(define data-folder "data") ; for textures and title font

(define polyhedron-id 8) ; polyhedra index from the polyhedra list below
(define polyhedron-scale 1.0)
(define polyhedron-envmap "beach.png")

(define clip-near .5) ; clip plane distances - change for fov
(define clip-far 1000)

(define camera-distance 30.) ; distance of camera from the followed object

(define pp-size 1024) ; pixel primitive size for rendering - bigger gives better quality, but slower

(define title-id 3)
(define title-appears-in-sec 30) ; title appears in this seconds after running the script

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
    (scale 0))

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

(define tunnel (with-pixels-renderer render-buffer
        (build-torus tunnel-inner-radius tunnel-outer-radius
            tunnel-slices tunnel-stacks)))

; object being followed
(define object (with-pixels-renderer render-buffer
        (build-polyhedron (list-ref polyhedra polyhedron-id))))

; camera following the object
(define camera-eye (with-pixels-renderer render-buffer (build-locator)))
(define camera-target (with-pixels-renderer render-buffer
        (build-locator)))

(define tunnel-texture (build-pixels pp-size pp-size #t))

(with-primitive tunnel-texture (scale 0))

(define (anim-tunnel-texture)
    (with-pixels-renderer tunnel-texture
        (with-state
            (scale 2)
            (colour (vector 1 0 0))
            (draw-cube))))

(define textref (pixels->texture tunnel-texture))

(with-primitive tunnel-texture (scale 0))

(define (anim-tunnel-texture)
    (with-pixels-renderer tunnel-texture
        (with-state
            (scale 2)
            (colour (vector 1 0 0))
            (draw-cube))))

(with-pixels-renderer render-buffer
    (with-primitive tunnel
        (pdata-copy "p" "pcopy")))


(define (tunnel-man)
    (with-pixels-renderer render-buffer
        (clip clip-near clip-far)
        (with-primitive tunnel
            (backfacecull 0)
            (recalc-normals 1)
            (pdata-map! (λ (n) (vmul n -1)) "n")
           (pdata-map! (λ (p pcopy) (vmul pcopy (+ (*  p1 (gl (vx p))) 1))) "p" "pcopy")
            (hint-sphere-map)
            ;(texture 0)
            ;(texture textref)
            (multitexture 0 (load-texture 
                    (string-append data-folder "/textures/" 
                    tunnel-texture-namebase (number->string p8) ".png")))
#;            (multitexture 1 (load-texture 
                    (string-append data-folder "/textures/" 
                    tunnel-texture-namebase (number->string 11) ".png"))))
        (with-primitive object
            (hint-unlit)
             (texture (load-texture 
                    (string-append data-folder "/textures/" 
                    tunnel-texture-namebase (number->string p7) ".png")))
            (scale p2)
            ;(apply-transform)
        )))



(define (mouse-look)
    (let* ([max tunnel-inner-radius]
            [min (- tunnel-inner-radius)]
            [x (+ (/ (* (mouse-x) (- max min)) (vx (get-screen-size))) min)]
            [y (+ (/ (* (mouse-y) (- max min)) (vy (get-screen-size))) min)])
        (translate (vector x 0 (- y)))))

(define (rot t)
    (rotate (vector 0 0 t))
    (translate (vector tunnel-outer-radius 0 0)))


(define (render-tunnel)
    (define up (vtransform (vector 0 0 1) (mrotate (vector 0 (* 20 (time)) 0))))
    (with-pixels-renderer render-buffer
        (with-primitive object
            (identity)
            (rotate (vector 0 0 (* (time) tunnel-outer-radius)))
            (translate (vector (+ (cos(time)) tunnel-outer-radius) (* 5 (abs (sin (time)))) (* 5 (sin (time)))))
            (scale (+ p2 (abs (sin (gl 0))) 5)))
        
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
    (scale #(21 17 1))
    (hint-unlit)
    (texture (pixels->texture render-buffer)))

; setting up titles
(titles-setup (string-append data-folder "/font/chunkfive.ttf"))
(titles-seek title-id title-appears-in-sec)

(define p1 0)
(define p2 0)
(define p3 0)
(define p4 0)
(define p5 0)
(define p6 0)
(define p7 0)
(define p8 0)

(define (midi-update)
    (set! p1 (* 1 (midi-ccn 0 1)))
    (set! p2 (* .3 (midi-cc 0 2)))
    (set! p3 (midi-ccn 0 3))
    (set! p4 (midi-ccn 0 4))
    (set! p5 (midi-ccn 0 5))
    (set! p6 (midi-cc 0 6))
    (set! p7 (midi-cc 0 7))
    (set! p8 (midi-cc 0 8))
    
    ;(set! camera-distance p6)
    
    )

(define (loop)
    (midi-update)
    (anim-tunnel-texture)
    (tunnel-man)
    (render-tunnel)
    (titles-update))

(every-frame (loop))











