module Node exposing (Node, node, inGroup, hasGeometry, removeGeometry)

import Identifier exposing (Identifier)
import Position exposing (Position)
import Attribut exposing (Attribut)
import Set exposing (Set)


type alias Node =
    { id : Identifier
    , name : String
    , parent : Maybe Identifier
    , attribut : Maybe Attribut
    , geometry : Maybe Identifier
    , group : Set Identifier
    , highLighted : Bool
    , position : Position
    }


node : Identifier -> String -> Maybe Identifier -> Node
node i s p =
    { id = i
    , name = s
    , parent = p
    , attribut = Nothing
    , geometry = Nothing
    , group = Set.empty
    , highLighted = False
    , position = Position.defaultPosition
    }


inGroup : Identifier -> Node -> Bool
inGroup s n =
    Set.member s n.group


hasGeometry : Identifier -> Node -> Bool
hasGeometry s n =
    case n.geometry of
        Nothing ->
            False

        Just i ->
            (i == s)


removeGeometry : Identifier -> Node -> Node
removeGeometry s n =
    { n | geometry = Nothing }
