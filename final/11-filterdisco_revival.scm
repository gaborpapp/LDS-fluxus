(require lds/titles)
(require polyhedra/polyhedra)
(require fluxus-018/fluxus-midi)
(midiin-open 0)
(start-audio "" 512 44100)
(set-screen-size #(1280 720))

(define tunnel-inner-radius 11)
(define tunnel-outer-radius 27)
(define tunnel-slices 11)
(define tunnel-stacks 27)

(define tunnel-texture-0 "D77.png")
(define tunnel-texture-1 "D111.png")

(define data-folder "data") ; for textures and title font

(define polyhedron-id 0) ; polyhedra index from the polyhedra list below
(define polyhedron-scale 18)
(define polyhedron-envmap "talaj.png")

(define clip-near .5) ; clip plane distances - change for fov
(define clip-far 1000)

(define camera-distance 30.) ; distance of camera from the followed object

(define bloom .3) ; bloom

(define pp-size 1024) ; pixel primitive size for rendering - bigger gives better quality, but slower

(define title-id 10)
(define title-appears-in-sec 30) ; title appears in this seconds after running the script

(define polyhedra '(medial-hexagonal-hexecontahedron
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

(define tunnel-opacity 1.0)
(define tunnel-normal-opacity 1.0)
(define tunnel-destroy .0)
(define object-opacity 1.0)
(define stars-opacity 1.0)
(define stars-count 1.0)

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

; logaritmic gh
(define (gl n)
    (log (+ 1 (gh n))))

; normalized logarithmic gh
(define ngl
    (let* ([bin-count (max 1 (get-num-frequency-bins))]
            [gl-limits (make-vector bin-count (vector 1000. 0))]
            [max-count 10000]
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

; lists for particles and connector lines
(define object-points '())
(define tunnel-points '())
(define all-points '())
(define particle-sum 0)

(with-pixels-renderer render-buffer
    (clip clip-near clip-far)
    (with-primitive tunnel
        (backfacecull 0)
        (recalc-normals 0)
        ;(hint-none)
        ;(normal-colour #(.1 .9 .0))
        ;(hint-on 'wire 'vertcols 'normal)
        ;(hint-off 'depth-sort)
        ;(line-width 10)
        (pdata-map! (λ (n) (vmul n -1)) "n")
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
        (with-state
            (hint-sphere-map)
            ;(backfacecull 0)
            ;(hint-wire)
            (hint-ignore-depth)
            (colour #(1 1))
            (scale polyhedron-scale)
            (build-polyhedron (list-ref polyhedra polyhedron-id)))))

(define starfield
    (with-pixels-renderer render-buffer
        (build-particles 6)))

#;(with-pixels-renderer render-buffer
    (with-primitive starfield
        (hint-ignore-depth)
        (texture (load-texture "splat.png"))
        (pdata-map!
              (lambda (p)
                  (vtransform
                    (vmul (srndvec) tunnel-inner-radius)
                    (mmul
                        (mrotate (vector 0 0 (* (rndf) 360)))
                        (mtranslate (vector tunnel-outer-radius 0 0)))))
                "p")
        (pdata-map!
              (λ (s) (rndf)) "s")
        (pdata-map!
              (λ (c) #(1 .15)) "c")))

(define (plane-system)
(with-pixels-renderer render-buffer
    (with-state
        (identity)
        (backfacecull 0)
        ;(hint-none)
        ;(hint-wire)
        (hint-ignore-depth)
        ;(hint-anti-alias)
        (for ([i (in-range 1132)])
            (with-state
                (identity)
                (translate (vmul (vector (sin i) (cos i) 1) tunnel-inner-radius))
                (rotate (vector (* i .1 (time)) (* i .03 (time)) (* (sin (* .02 i)) i)))
                (translate (vector tunnel-outer-radius 0 0))
                (scale (vector 1 1 p4))
                (opacity (* (gl i) p4))
                (colour (vector p2 (gl i) (* (gl i) (sin i))))
                (rotate (vector 0 (* 90 (round (* 2 (sin i)))) 
                                   (* 90 (round (* 2 (cos i))))))
                (draw-plane))))))

(with-pixels-renderer render-buffer
    (with-primitive object
        ;(hint-sphere-map)
        ;(hint-none)
        ;(hint-solid)
        ;(hint-unlit)
        ;(colour #(1 1 1))
        ;(line-width 10)
        ;(specular (vector .1 .1 1))
        (texture (load-texture (string-append data-folder "/textures/" polyhedron-envmap)))
        (recalc-normals 0)
        ;(scale polyhedron-scale)
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
    (define up (vtransform (vector 0 0 1) (mrotate (vector 0 (* 20 (time)) 0))))
    (with-pixels-renderer render-buffer
        (set! object-points '())
        
        (with-primitive tunnel
            (texture (load-texture (string-append data-folder "/textures/" 
                    "z" (number->string p8) ".png")))
            (opacity tunnel-opacity)
            (hint-ignore-depth)
            ;(normal-colour (vector 0 1 0 tunnel-normal-opacity))
            (pdata-rnd-map!
                .3
                (lambda (p)
                    (vadd p (vmul (crndvec) tunnel-destroy)))
                "p")

            (pdata-index-map! (λ (i c) (vector 1 (* tunnel-opacity (ngl i)))) "c"))
   
        #;(with-primitive starfield
            (let ([limit (inexact->exact (floor (* stars-count (pdata-size))))])
                (pdata-index-map!
                    (λ (i c) (vector 1 (if (< i limit) stars-opacity .0))) "c")))
     
        (with-primitive object
            (opacity object-opacity)
            (texture (load-texture (string-append data-folder "/textures/" 
                    "z" (number->string p5) ".png")))
            (identity)
            (rotate (vector 0 0 (* (time) tunnel-outer-radius)))
            (translate (vector (+ (cos(time)) tunnel-outer-radius) (* 5 (abs (sin (time)))) (* 5 (sin (time)))))
            (scale (+ 0 polyhedron-scale (* polyhedron-scale .2 (ngl 0))))
            
            (pdata-rnd-map!
                .01
                (lambda (p)
                    (vadd p (vmul (crndvec) .01)))
                "p")
            (recalc-normals 0)

            (for ([i (in-range 0 (pdata-size) 1)])
                (let ([c (pdata-ref "p" i)])
                    (set! object-points (cons c object-points)))))

        
#;        (let ([m (with-primitive object (get-global-transform))])
            (with-primitive particles
                (pdata-index-map!
                    (λ (i p)
                        (vtransform (with-primitive object (pdata-ref "p" i)) m))
                    "p")))
        
        
        (with-primitive particles
            (for ([i (in-range 0 (length tunnel-points) 1)])
                (let ([p (list-ref tunnel-points i)])
                    (pdata-set! "p" i p))))
        
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
    (scale #(21 17 1))
    (hint-unlit)
    (texture (pixels->texture render-buffer)))

; setting up titles
(titles-setup (string-append data-folder "/font/chunkfive.ttf"))
(titles-seek title-id title-appears-in-sec)


(define p8 0)
(define p2 0)
(define p4 0)
(define p5 0)

(define (midi-update)
    (set! tunnel-opacity (midi-ccn 0 1))
    (set! p2 (midi-ccn 0 2))
    (set! object-opacity (midi-ccn 0 3))
    (set! p4 (midi-ccn 0 4))
    (set! p5 (midi-cc 0 5))
    (set! tunnel-destroy (midi-ccn 0 6))
    (set! polyhedron-scale (* 1 (midi-ccn 0 7)))
    (set! p8 (midi-cc 0 8)))

(define (loop)
    (midi-update)
    (render-tunnel)
    (plane-system)
    (titles-update))

(every-frame (loop))













