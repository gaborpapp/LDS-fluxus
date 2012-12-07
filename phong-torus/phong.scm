(clear)

(define p (build-torus 1 2 50 50))

(with-primitive p
    (colour #(1 .1 .1))
    (shader "phong_vert.glsl" "phong_frag.glsl"))

(light-position 0 #(1 0 10))

(every-frame
    (with-primitive p
        (shinyness 10.0)
        (ambient .05)
        (rotate (vector (* 15 (delta)) (* 10 (delta)) 0))))

