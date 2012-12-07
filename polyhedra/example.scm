(require polyhedra/polyhedra)

(clear)

(hint-ignore-depth)
(colour #(1 .5))

; build polyhedron object
(build-polyhedron 'j70)

; build edges
(hint-unlit)
(colour 0)
(build-polyhedron-edges 'j70)

