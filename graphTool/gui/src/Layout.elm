module Layout exposing (Layout, NodeLayout)

import Identifier exposing (Identifier)
import Position exposing (NodePosition)


type alias Layout =
    List NodePosition


type alias NodeLayout =
    { id : Identifier
    , layout : Layout
    }
