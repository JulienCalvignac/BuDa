module LinkParameters exposing (Model, createProperty, defaultModel)

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
    let
        new_properties =
            List.map (\x -> (property (getNodeIdentifier model).curIdentifier x)) list
    in
        { model | properties = new_properties }


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
