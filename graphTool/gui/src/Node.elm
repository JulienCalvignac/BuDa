module Node exposing (Node, node)

import Identifier exposing (Identifier)
import Attribut exposing (Attribut)


type alias Node =
    { id : Identifier, name : String, parent : Maybe Identifier, attribut : Maybe Attribut }


node : Identifier -> String -> Maybe Identifier -> Node
node i s p =
    { id = i, name = s, parent = p, attribut = Nothing }
