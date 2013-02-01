(define tunnel-inner-radius 11)
(define tunnel-outer-radius 24)
(define tunnel-slices 18)
(define tunnel-stacks 38)

(define clip-near .7) ; clip plane distances - change for fov
(define clip-far 1000)

(define pp-size 1024) ; pixel primitive size for rendering

;//////////////// 

(clear)
(clip clip-near clip-far)

(define render-buffer (build-pixels 1024 1024 #t))

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
(define tunnel (build-torus tunnel-inner-radius tunnel-outer-radius
                      		tunnel-slices tunnel-stacks))
(with-primitive tunnel
    (backfacecull 0)
    (recalc-normals 1)
    (pdata-map! (λ (n) (vmul n -1)) "n")
    (hint-sphere-map)
    (multitexture 0 (load-texture "textures/D77.png"))
    (multitexture 1 (load-texture "textures/D111.png")))

(define obj
    (build-locator))

(define ico        
        (build-icosphere 2))

(with-primitive ico
    (hide 1)
    (recalc-normals 0))

(define cam (build-locator))
(define pos 12)
(define str 0)

(define (mouse-look)
    (let* ([max tunnel-inner-radius]
           [min (- tunnel-inner-radius)]
           [x (+ (/ (* (mouse-x) (- max min)) (vx (get-screen-size))) min)]
           [y (+ (/ (* (mouse-y) (- max min)) (vy (get-screen-size))) min)])
        (translate (vector x 0 (- y)))))

(define (rot t)
    (rotate (vector 0 0 t))
    (translate (vector tunnel-outer-radius 0 0)))

(define (icos x)
    (when (> x 0)
        (with-state
            (hint-sphere-map)
            (colour #(1 1 1))
            (specular (vector .1 .1 1))    
            (texture (load-texture "textures/colors.png"))
            (identity)
            (rotate (vector 0 0 (* (time) tunnel-outer-radius)))
            (translate (vector tunnel-outer-radius 0 5))
            (draw-instance ico))
        (icos (- x 1))))

(define (loop)
	(icos 1)
	
	(with-primitive obj
		(identity)
		(hint-origin)          
		(rot (* tunnel-outer-radius (time)))
		(when (mouse-button 2) (mouse-look)))

	(with-primitive cam 
		(identity)
		(rot (- (* tunnel-outer-radius (time)) pos)))
	
	(define up (vtransform (vector 0 0 1) (mrotate (vector 0 (* 20 (time)) 0))))
	(let ([p (with-primitive obj (get-pos))])
		(wire-colour #(1 .9 .1))
		(draw-line p (vadd p up)))
	
	(set-target-camera (with-primitive cam (get-pos))
					   (with-primitive obj (get-pos))
					   up))

(every-frame (loop))
