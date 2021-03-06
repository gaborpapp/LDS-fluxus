(require lds/dof) ; os x: copy dof.ss to ~/Documents/Fluxus/collects/lds
(require polyhedra/polyhedra) ; copy the polyhedra module to ~/Documents/collects/polyhedra
;(require "dof.ss") ; linux: place the modules next to this script
;(require "polyhedra.ss")

; parameters to tune

; tunnel parameters
(define tunnel-inner-radius 11)
(define tunnel-outer-radius 27)
(define tunnel-slices 9)
(define tunnel-stacks 27)

(define polyhedron-id 3) ; polyhedra index from the polyhedra list below
(define polyhedron-scale 4.0)

(define clip-near .5) ; clip plane distances - change for fov
(define clip-far 1000)

(define camera-distance 10.) ; distance of camera from the followed object

; depth of field parameters
(define dof-aperture .06) ; smaller value result in shallower blur range
(define dof-focus .15) ; focus from 0. to 1, 0 is the camera position
(define dof-maxblur 1.) ; maximum blur

(define pp-size 1024) ; pixel primitive size for rendering - bigger gives better quality, but slower

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
        (multitexture 0 (load-texture "textures/D77.png"))
        (multitexture 1 (load-texture "textures/D111.png"))
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
        (texture (load-texture "textures/colors.png"))
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
    (wire-colour (rgb->hsv (vector  (abs (sin (time))) (abs (cos (time))) (rndf) .9)))
    (line-width (* (gl 0) 6))

    (with-primitive particles
        (for ([i (in-range 0 particle-sum 1)])
            (let ([v0  (pdata-ref "p" i)]
                    [v1 (pdata-op "closest" "p" i)])
                (draw-line v0 v1)))))


(define (render-tunnel)
    (define up (vtransform (vector 0 0 1) (mrotate (vector 0 (* 20 (time)) 0))))
    (with-pixels-renderer render-buffer
        (set! object-points '())

        (with-primitive object
            (identity)
            (rotate (vector 0 0 (* (time) tunnel-outer-radius)))
            (translate (vector (+ (cos(time)) tunnel-outer-radius) (* 5 (abs (sin (time)))) (* 5 (sin (time)))))
            (scale (+ (abs (sin (gl 0))) .5))

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

(define (loop)
    (render-tunnel)
    (with-primitive plane
        (dof render-buffer #:aperture dof-aperture
            #:focus dof-focus
            #:maxblur dof-maxblur)))

(every-frame (loop))

