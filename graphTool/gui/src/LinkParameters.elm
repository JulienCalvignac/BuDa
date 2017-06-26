module LinkParameters exposing (Model, Property, createProperty, defaultModel, getPropertyIdFromName)

import Identifier exposing (Identifier)
import List


type alias Property =
    { id : Identifier
    , name : String
    }


type alias Model =
    { properties : List Property
    , curIdentifier : Identifier
    }


getPropertyIdFromName : String -> List Property -> Maybe Identifier
getPropertyIdFromName s list =
    case list of
        [] ->
            Nothing

        x :: xs ->
            case x.name == s of
                True ->
                    (Just x.id)

                False ->
                    getPropertyIdFromName s xs


zeroModel : Model
zeroModel =
    { properties = []
    , curIdentifier = 0
    }


defaultModel : Model
defaultModel =
    sampleModel


fromList : List String -> Model -> Model
fromList list model =
    case list of
        [] ->
            model

        x :: xs ->
            let
                new_properties =
                    (property model.curIdentifier x) :: model.properties

                m1 =
                    getNodeIdentifier model

                m2 =
                    { m1 | properties = new_properties }
            in
                fromList xs m2


sampleModel : Model
sampleModel =
    Debug.log "sampleModel"
        fromList
        [ "Air"
        , "Fresh Water"
        , "Salt Water"
        , "400 V AC"
        , "230 V AC"
        , "48 V DC"
        , "Command & Control"
          -- , "Digital"
          -- , "DO/HFO"
          -- , "Others"
        ]
        zeroModel


property : Identifier -> String -> Property
property i s =
    { id = i, name = s }


getNodeIdentifier : Model -> Model
getNodeIdentifier model =
    let
        newId =
            model.curIdentifier + 1
    in
        { model | curIdentifier = newId }


createProperty : String -> Model -> Model
createProperty s model =
    let
        new_properties =
            (property model.curIdentifier s) :: model.properties

        m1 =
            { model | properties = new_properties }
    in
        getNodeIdentifier m1
