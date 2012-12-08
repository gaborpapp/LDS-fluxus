(clear)

(hint-sphere-map)
(hint-ignore-depth)
(backfacecull 0)
(texture (load-texture "transp.png"))

(define p (build-icosphere 2))
(with-primitive p
    (recalc-normals 0))

(every-frame
    (for ([s (in-range 1 19 2)])
        (with-state
            (scale s)
            (rotate (vector (* 70.957 (sin (* s .01941 (time))))
                            (* 91.722 (cos (* s .00935 (time))))
                            (* 67.219 (cos (* s -.0021 (time))))))
            (draw-instance p))))
