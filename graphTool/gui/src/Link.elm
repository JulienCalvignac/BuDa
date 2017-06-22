module Link
    exposing
        ( Edge
        , ActivePoperties
        , link
        , makeLink
          -- , Link
        )

import Identifier exposing (Identifier)
import LinkParameters
import Set exposing (Set)


type alias ActivePoperties =
    Set Identifier


type alias Edge =
    { id : Identifier
    , source : Identifier
    , target : Identifier
    , parameters : ActivePoperties
    }


makeLink : Identifier -> Identifier -> Identifier -> Edge
makeLink i s t =
    { id = i, source = s, target = t, parameters = Set.empty }


link : Identifier -> Identifier -> Edge
link s t =
    makeLink 0 s t
