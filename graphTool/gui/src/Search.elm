module Search exposing (Model, defaultModel, init, next)

import Node exposing (Node)


type alias Model =
    { name : String
    , refList :
        -- liste des blocs du modele ayant pour nom name
        List Node
    , dropList :
        --liste de recherche (on initialise avec refList. on drop a chaque appel de next. quand on a terminé, on réinitialise)
        List Node
    , curElement : Maybe Node
    , idx : Int
    }


defaultModel : Model
defaultModel =
    { name = ""
    , refList = []
    , dropList = []
    , curElement = Nothing
    , idx = 0
    }


init : String -> List Node -> Model
init s list =
    { name = s
    , refList = list
    , dropList = list
    , curElement = Nothing
    , idx = 0
    }


init_ : Model -> Model
init_ model =
    { model
        | dropList = model.refList
        , curElement = Nothing
        , idx = 0
    }


next_ : Model -> Model
next_ model =
    let
        element =
            List.head model.dropList

        newDropList =
            List.drop 1 model.dropList

        newIdx =
            case element of
                Nothing ->
                    0

                _ ->
                    model.idx + 1

        newModel =
            { model
                | dropList = newDropList
                , curElement = element
                , idx = newIdx
            }
    in
        newModel


next : Model -> Model
next model =
    case List.isEmpty model.refList of
        True ->
            model

        False ->
            let
                m1 =
                    next_ model

                m2 =
                    case m1.curElement of
                        Just n ->
                            case m1.idx > (List.length m1.refList) of
                                True ->
                                    next_ (init_ m1)

                                False ->
                                    m1

                        Nothing ->
                            next_ (init_ m1)

                z =
                    Debug.log "next" m2.idx
            in
                m2
