module Node exposing (Node, node, inGroup)

import Identifier exposing (Identifier)
import Attribut exposing (Attribut)


type alias Node =
    { id : Identifier, name : String, parent : Maybe Identifier, attribut : Maybe Attribut, group : Maybe String }


node : Identifier -> String -> Maybe Identifier -> Node
node i s p =
    { id = i, name = s, parent = p, attribut = Nothing, group = Nothing }


inGroup : String -> Node -> Bool
inGroup s n =
    case n.group of
        Nothing ->
            False

        Just g ->
            (g == s)
