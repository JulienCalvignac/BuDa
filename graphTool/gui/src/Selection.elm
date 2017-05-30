module Selection exposing (Model, updateModelSelection, decodeFromJSMsg)

import DataModel
import Json.Decode
import DataModelDecoders


type alias SelectionId =
    { id : DataModel.Identifier, err : Bool }


type alias Model =
    List DataModel.Identifier


getIdentifier : SelectionId -> DataModel.Identifier
getIdentifier s =
    s.id


updateModelSelection : Model -> List SelectionId -> Model
updateModelSelection model list =
    let
        noError =
            List.all (\s -> not s.err) list

        newModel =
            case noError of
                True ->
                    List.map (\s -> s.id) list

                False ->
                    model
    in
        newModel


decodeFromJSId : String -> SelectionId
decodeFromJSId s =
    let
        x =
            Json.Decode.decodeString (Json.Decode.field "id" DataModelDecoders.decodeIdentifier) s

        selection =
            case x of
                Ok v ->
                    { id = v, err = False }

                Err _ ->
                    { id = -1, err = True }
    in
        selection


decodeFromJSMsg : List String -> List SelectionId
decodeFromJSMsg =
    List.map decodeFromJSId
