(clear)

(hint-sphere-map)
(texture (load-texture "transp.png"))

(define p (build-icosphere 3))
(with-primitive p
    (recalc-normals 0))

(every-frame
    (with-primitive p
        (colour (hsv->rgb (vector (fmod (* .2 (time)) 1) 1 1)))))
