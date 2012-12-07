;; Copyright (C) 2010 Gabor Papp
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see http://www.gnu.org/licenses/.

#lang scheme

(require (rename-in fluxus-018/fluxus-engine
		 (shader-set! shader-list-set!)))
(require fluxus-018/building-blocks)
(require "polyhedron-data.ss")

(provide build-polyhedron
		 build-polyhedron-edges)

(define (build-polyhedron psym)
    (let* ([ph (hash-ref polyhedra psym)]
           [points (polyhedron-points ph)]
           [faces (polyhedron-faces ph)]
           [vc (* 3 (foldl (lambda (l s)
                              (+ (- (length l) 2) s))
                           0
                           faces))]
           [p (build-polygons vc 'triangle-list)]
           [ip 0])
        (with-primitive p
            (for ([face faces])
                (let ([p0 (list-ref points (car face))])
                    (for ([i (in-range 2 (length face))])
                        (pdata-set! "p" ip p0)
                        (pdata-set! "p" (+ ip 1) (list-ref points (list-ref face (- i 1))))
                        (pdata-set! "p" (+ ip 2) (list-ref points (list-ref face i)))
                        (set! ip (+ ip 3)))))
            (recalc-normals 0))
        p))

(define (build-polyhedron-edges psym)
    (let* ([ph (hash-ref polyhedra psym)]
           [points (polyhedron-points ph)]
           [edges (polyhedron-edges ph)]
           [lctr (build-locator)])
         (for ([edge edges])
             (let ([l (build-ribbon 2)])
                (with-primitive l
                    (parent lctr)
                    (pdata-set! "p" 0 (list-ref points (car edge)))
                    (pdata-set! "p" 1 (list-ref points (cadr edge)))
                    (pdata-map! (lambda (w) .01) "w"))))
        lctr))

