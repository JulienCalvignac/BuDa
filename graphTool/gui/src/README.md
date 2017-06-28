# GraphTool

## Implementation Bubble Diagram relativement au node n

  * construction de la liste des enfants de n (nommée childs)
  * creation de la liste des nodes qui ont un lien avec n (nommée others)
  * on filtre la liste others de la façon suivante:
      on conserve un node x si le x.parent == ParentCommun (x,n) ou si x.parent == Nothing
      La liste filtrée est nommée extern

  * la liste des nodes retenues est n + childs + extern (nommée newNodes)

  * création de la liste des liens.
    On filtre la liste des liens du model tels que source et target sont dans newNodes. (nommée newEdges1)
    On filtre la liste newEdges1 avec mainFilter_

      mainFilter_ x
        * x.source != n et x.target != n -> True
        * x.source == n
            il existe un lien entre x.target et un enfant de n -> False
            sinon -> True
        * x.target == n
            il existe un lien entre x.source et un enfant de n -> False
            sinon -> True
