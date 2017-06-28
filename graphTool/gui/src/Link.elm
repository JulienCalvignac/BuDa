module Link
    exposing
        ( Edge
        , ActivePoperties
        , isActive
        , isActiveProperty
        , link
        , makeLink
        , changeActive
        , changeActiveProperty
          -- , Link
        )

import Identifier exposing (Identifier)
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


changeActive : Identifier -> Edge -> Edge
changeActive x edge =
    case isActive x edge of
        False ->
            activate x edge

        True ->
            unActivate x edge


changeActiveProperty : Identifier -> ActivePoperties -> ActivePoperties
changeActiveProperty x set =
    case isActiveProperty x set of
        False ->
            activateProperty x set

        True ->
            unActivateProperty x set


isActiveProperty : Identifier -> ActivePoperties -> Bool
isActiveProperty x set =
    Set.member x set


activateProperty : Identifier -> ActivePoperties -> ActivePoperties
activateProperty x set =
    Set.insert x set


unActivateProperty : Identifier -> ActivePoperties -> ActivePoperties
unActivateProperty x set =
    Set.remove x set


isActive : Identifier -> Edge -> Bool
isActive x edge =
    Set.member x edge.parameters


activate : Identifier -> Edge -> Edge
activate x edge =
    let
        new_parameters =
            Set.insert x edge.parameters
    in
        { edge | parameters = new_parameters }


unActivate : Identifier -> Edge -> Edge
unActivate x edge =
    let
        new_parameters =
            Set.remove x edge.parameters
    in
        { edge | parameters = new_parameters }
