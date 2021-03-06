; os x: copy the lds and polyhedra folders to ~/Documents/Fluxus/collects
(require lds/dof)
(require lds/titles)
(require polyhedra/polyhedra)

(require fluxus-018/fluxus-midi)

; linux: uncomment these lines and run this script in this directory
; to be able to use the modules
;(require "lds/dof.ss")
;(require "lds/titles.ss")
;(require "polyhedra/polyhedra.ss")

(start-audio "" 512 44100)
(midiin-open 0)

; parameters to tune

; tunnel parameters
(define tunnel-inner-radius 11)
(define tunnel-outer-radius 27)
(define tunnel-slices 7)
(define tunnel-stacks 37)

(define tunnel-texture-0 "D77.png")
(define tunnel-texture-1 "D111.png")

(define data-folder "data") ; for textures and title font

(define polyhedron-id 3) ; polyhedra index from the polyhedra list below
(define polyhedron-scale 4.0)
(define polyhedron-envmap "colors.png")

(define clip-near .5) ; clip plane distances - change for fov
(define clip-far 1000)

(define camera-distance 30.) ; distance of camera from the followed object

; depth of field parameters
(define dof-aperture .06) ; smaller value result in shallower blur range
(define dof-focus .26) ; focus from 0. to 1, 0 is the camera position
(define dof-maxblur .1) ; maximum blur

(define bloom .1) ; bloom

(define pp-size 1024) ; pixel primitive size for rendering - bigger gives better quality, but slower

(define title-id 0)
(define title-appears-in-sec 15) ; title appears in this seconds after running the script

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

(define tunnel-opacity 1.0)
(define object-opacity 1.0)
(define lines-opacity 1.0)
(define particle-size .1)

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
        (backfacecull 0)
        (recalc-normals 1)
        (pdata-map! (λ (n) (vmul n -1)) "n")
        (hint-sphere-map)
        (multitexture 0 (load-texture (string-append data-folder "/textures/" tunnel-texture-0)))
        (multitexture 1 (load-texture (string-append data-folder "/textures/" tunnel-texture-1)))
        (poly-convert-to-indexed)
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
        (hint-sphere-map)
        (colour #(1 1 1))
        (specular (vector .1 .1 1))
        (texture (load-texture (string-append data-folder "/textures/" polyhedron-envmap)))
        (recalc-normals 0)
        (scale polyhedron-scale)
        (apply-transform)
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
            (λ (i c) (vector 1 1)) "c")
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
    (wire-colour (rgb->hsv (vector  (abs (sin (time))) (abs (cos (time))) (rndf) .9)))
    (line-width (* (gl 0) 6))
    (wire-opacity lines-opacity)
    (with-primitive particles
        (for ([i (in-range 0 particle-sum 1)])
            (let ([v0  (pdata-ref "p" i)]
                    [v1 (pdata-op "closest" "p" i)])
                (draw-line v0 v1)))))


(define (render-tunnel)
    (define up (vtransform (vector 0 0 1) (mrotate (vector 0 (* 20 (time)) 0))))
    (with-pixels-renderer render-buffer
        (if (= (midi-cc 0 10) 127)
            (hint-on 'depth-test)
            (hint-off 'depth-test))

        (set! object-points '())

        (with-primitive tunnel
            (opacity tunnel-opacity))

        (with-primitive object
            (identity)
            (opacity object-opacity)
            (rotate (vector 0 0 (* (time) tunnel-outer-radius)))
            (translate (vector (+ (cos(time)) tunnel-outer-radius) (* 5 (abs (sin (time)))) (* 5 (sin (time)))))
            (scale (+ (* 1 (abs (sin (clamp (* 3 (gh 0)) 0 (/ pi 2))))) .1))
            (rotate (vector 0 (* 30 (gl 0)) 0))

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
            (if (= (midi-cc 0 10) 127)
                (hint-on 'depth-test)
                (hint-off 'depth-test))

            (pdata-index-map!
                (λ (i s) particle-size) "s")
            (pdata-index-map!
                (λ (i c) (vector i (* .1 (gh i)))) "c")


            (for ([i (in-range 0 (length tunnel-points) 1)])
                (let ([p (list-ref tunnel-points i)])
                    (pdata-set! "p" i p))))

        (draw-lines)

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

(define (midi-update)
    (set! tunnel-opacity (midi-ccn 0 1))
    (set! lines-opacity (midi-ccn 0 2))
    (set! particle-size (midi-ccn 0 3))
    (set! object-opacity (midi-ccn 0 4))
    (set! bloom (midi-ccn 0 7))
    (set! dof-maxblur (midi-ccn 0 8))
    (set! dof-focus (midi-ccn 0 9)))

(define (loop)
      (midi-update)
    (render-tunnel)
    (with-primitive plane
        (dof render-buffer #:aperture dof-aperture
            #:focus dof-focus
            #:maxblur dof-maxblur
            #:bloom bloom)
        (titles-update)))

(every-frame (loop))

