(clear)
(define text "Give my try a love")
(define p (build-pixels 512 512 #t))
(with-primitive p
    (scale 0))
(with-pixels-renderer
    (build-type "chunkfive.ttf" (substring text 0 1)))
(texture (pixels->texture p))
(scale 12)
(build-plane)