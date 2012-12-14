(clear)
(define p (build-pixels 512 512 #t))
(with-primitive p
    (scale 0))
(with-pixels-renderer p
    (scale 4)
    (build-cube))
(texture (pixels->texture p))
(scale 12)
(build-plane)