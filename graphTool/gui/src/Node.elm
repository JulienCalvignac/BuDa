module Node exposing (Node, node)

import Identifier exposing (Identifier)


type alias Node =
    { id : Identifier, name : String, parent : Maybe Identifier }


node : Identifier -> String -> Maybe Identifier -> Node
node i s p =
    { id = i, name = s, parent = p }
