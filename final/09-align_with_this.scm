; uses an os x ffgl plugin, this is os x only!

; os x: copy the lds and polyhedra folders to ~/Documents/Fluxus/collects
(require lds/dof)
(require lds/titles)
(require polyhedra/polyhedra)

; linux: uncomment these lines and run this script in this directory
; to be able to use the modules
;(require "lds/dof.ss")
;(require "lds/titles.ss")
;(require "polyhedra/polyhedra.ss")

(require fluxus-018/fluxus-midi)
(start-audio "mplayer:out1" 512 44100)
(midiin-open 0)

(set-screen-size #(1280 720))

; parameters to tune

; tunnel parameters
(define tunnel-inner-radius 11)
(define tunnel-outer-radius 27)
(define tunnel-slices 18)
(define tunnel-stacks 42)

(define tunnel-texture-0 "D77.png")
(define tunnel-texture-1 "D111.png")

(define data-folder "data") ; for textures and title font

(define polyhedron-id 0) ; polyhedra index from the polyhedra list below
(define polyhedron-scale 3.0)
(define polyhedron-envmap "transp.png")
(define polyhedron-envmap2 "colors.png")


(define clip-near .5) ; clip plane distances - change for fov
(define clip-far 1000)

(define camera-distance 40.) ; distance of camera from the followed object
(define speed 1)

; depth of field parameters
(define dof-aperture .06) ; smaller value result in shallower blur range
(define dof-focus .26) ; focus from 0. to 1, 0 is the camera position
(define dof-maxblur .0) ; maximum blur

(define bloom .3) ; bloom

(define pp-size 1024) ; pixel primitive size for rendering - bigger gives better quality, but slower

(define title-id 8)
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
(define tunnel-destroy .0)
(define glitch-x 0.0)
(define glitch-y 0.0)
(define object-opacity 1.0)
(define object-rotation-scale 0)
(define fov-mult .5)

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

; normalized logarithmic gh
(define ngl
    (let* ([bin-count (max 1 (get-num-frequency-bins))]
            [gl-limits (make-vector bin-count (vector 1000. 0))]
            [max-count 1000]
            [counter max-count])
        (lambda (i)
            (when (zero? counter)
                (set! gl-limits (make-vector bin-count (vector 1000. 0)))
                (set! counter max-count))
            (set! counter (- counter 1))
            (let* ([j (remainder i bin-count)]
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

(define glitch-size 32)
(define glitch-buffer (build-pixels glitch-size glitch-size #t 2))
(define glitch-texture (pixels->texture glitch-buffer 1))

(with-primitive glitch-buffer
    (scale 0))

(define plugin (ffgl-load "cifourfoldtranslatedtile" glitch-size glitch-size))

(with-ffgl plugin
   (ffgl-process glitch-buffer
                (pixels->texture glitch-buffer 1)
                (pixels->texture glitch-buffer 0)))

(with-primitive glitch-buffer
    (pixels-render-to (pixels->texture glitch-buffer 0))
    (pixels-display (pixels->texture glitch-buffer 1)))

(define (update-glitch)
    (gain (/ 1 (+ (gl 0) .1)))
        (with-ffgl plugin
            (ffgl-set-parameter! #:angle (ngl 0)
                #:center-x glitch-x 
                #:center-y glitch-y
                #:width (ngl 5)
                #:acute-angle 0))

    (with-pixels-renderer glitch-buffer
        (clear-colour #(0 0))
            (with-state
                (scale 5)
                (colour
                    (vector (if (positive? (midi-cc 0 10)) 1 0)
                            (if (positive? (midi-cc 0 11)) 1 0)
                            (if (positive? (midi-cc 0 12)) 1 0)))
                (rotate (vector (* 54.3 (time)) -59 (* -87 (time))))
                (draw-cube))))


(with-pixels-renderer render-buffer
    (clip clip-near clip-far)
    (with-primitive tunnel
        (backfacecull 0)
        (hint-depth-sort)
        ;(hint-ignore-depth)
        ;(recalc-normals 0)
        (shader "phong_vert.glsl" "phong_frag.glsl")
        (shader-set! #:tex 0)

        (hint-solid)
        (recalc-normals 0)
        (pdata-map! (λ (n) (vmul n -1)) "n")

        (pdata-map! (λ (t) (vector (* 5 (vx t)) (* 15 (vy t)) (vz t))) "t")
        
        (shinyness 1.)
        (ambient .05)
        (texture glitch-texture)
        (texture-params 0 '(min nearest mag nearest wrap-s repeat wrap-t repeat))))    

; camera following the object
(define camera-eye (with-pixels-renderer render-buffer (build-locator)))
(define camera-target (with-pixels-renderer render-buffer
        (build-locator)))

(define objects (with-pixels-renderer render-buffer
        (with-state
            (hide 1)
            (hint-sphere-map)
            (backfacecull 0)
            ;(texture (load-texture (string-append data-folder "/textures/" polyhedron-envmap)))
            (multitexture 0 (load-texture polyhedron-envmap))
            (colour #(1 1))
            (scale polyhedron-scale)
            (map build-polyhedron polyhedra))))

(with-pixels-renderer render-buffer
    (for-each
      (λ (o)
        (with-primitive o
            (apply-transform)))
      objects))

(define current-object-id 0)

; object being followed
(define object (list-ref objects current-object-id))

(define (rot t)
    (rotate (vector 0 0 t))
    (translate (vector tunnel-outer-radius 0 0)))

(define-syntax pdata-rnd-map!
  (syntax-rules ()
    ((_ probability proc pdata-write-name pdata-read-name ...)
     (letrec
         ((loop (lambda (n total)
                  (cond ((not (> n total))
                         (when (< (rndf) probability)
                             (pdata-set! pdata-write-name n
                                         (proc (pdata-ref pdata-write-name n)
                                               (pdata-ref pdata-read-name n) ...)))
                         (loop (+ n 1) total))))))
       (loop 0 (- (pdata-size) 1))))))

(define (render-tunnel)
    (define up (vtransform (vector 0 0 1) (mrotate (vector 0 (* 10 (time)) 0))))

    (when (positive? (midi-cc 0 18))
      (set! current-object-id (remainder (+ 1 current-object-id) (length objects)))
      (set! object (list-ref objects current-object-id)))

    (update-glitch)

    (with-pixels-renderer render-buffer
        (clip (* clip-near (+ .1 (* 1 fov-mult))) clip-far)
        (blur (if (positive? (midi-cc 0 16)) .03 0))
        (with-primitive tunnel
            (shader-set! #:opacity tunnel-opacity)
            (if (positive? (midi-cc 0 13))
                (texture-params 0 '(wrap-s repeat wrap-t repeat))
                (texture-params 0 '(wrap-s clamp wrap-t clamp)))

            (pdata-rnd-map!
                tunnel-destroy
                (lambda (p)
                    (vadd p (vmul (crndvec) .02)))
                "p"))
   
        (if (positive? (midi-cc 0 17)) ; show all
            (for-each (λ (o) (with-primitive o
                                   (hide 0)))
                      objects)
            (for ([i (in-range (length objects))]
                  [o objects])
                (with-primitive o
                    (identity)
                    (rot (* speed tunnel-outer-radius (time)))
                    (hide (if (= i current-object-id)
                            0
                            1)))))
              
        (with-primitive object
            (opacity object-opacity)
            (identity)
            (rot (* speed tunnel-outer-radius (time)))
            (scale (+ (* 1. (abs (sin (clamp (ngl 0) 0 (/ pi 2))))) 1))
            (rotate (vector 0 (* object-rotation-scale (gl 0)) 0)))

        (light-position 0 (with-primitive object (get-pos)))

        (with-primitive camera-target
            (identity)
            (hint-origin)
            (hide 1)
            (rot (* speed tunnel-outer-radius (time))))
        
        (with-primitive camera-eye
            (identity)
            (rot (- (* speed tunnel-outer-radius (time))
                    (+ (* 9.2342 (sin (* .6435 (time))) (cos (* .9923 (time)))) camera-distance))))
        
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

(define (midi-update)
    (set! tunnel-opacity (midi-ccn 0 1))
    (set! tunnel-destroy (midi-ccn 0 2))
    (set! glitch-x (midi-ccn 0 3))
    (set! glitch-y (midi-ccn 0 4))
    (set! object-opacity (midi-ccn 0 6))
    (set! object-rotation-scale (midi-cc 0 9))
    (set! fov-mult (midi-ccn 0 8)))

(define (loop)
    (midi-update)
    (render-tunnel)
    (with-primitive plane
        (titles-update)))

(every-frame (loop))

