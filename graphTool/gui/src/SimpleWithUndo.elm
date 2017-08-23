module SimpleWithUndo exposing (init, view, subscriptions, update)

import Html exposing (Html, div, button, text)
import Html.Attributes exposing (id, name, style, type_, checked, value, placeholder, class)
import Html.Events exposing (onClick)
import ModelWithUndo exposing (Msg(..), Model, defaultModel)
import Model
import View
import Actions
import Simple


init : ( Model, Cmd Msg )
init =
    ( defaultModel, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        subMsg =
            Simple.subscriptions model.model
    in
        Sub.map ActionMsg subMsg


view : Model -> Html Msg
view model =
    let
        newview =
            View.view model.model
    in
        div []
            [ Html.map ActionMsg newview
            , button [ onClick Undo, id "undo", value "undo" ] [ text "undo" ]
            ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Undo ->
            let
                z =
                    Debug.log "Call Undo" model.undoModel

                newModel =
                    model.undoModel

                newUndoModel =
                    Model.defaultModel

                -- Debug.log "Call Undo" ( { model = model.undoModel, undoModel = Model.defaultModel }, Cmd.none )
            in
                ( { model = newModel, undoModel = newUndoModel }, Cmd.none )

        ActionMsg msg1 ->
            let
                ( simpleModel, simpleCmd ) =
                    Actions.update msg1 model.model

                newModel =
                    { model = simpleModel, undoModel = model.model }
            in
                ( newModel
                , Cmd.map ActionMsg simpleCmd
                  -- , Cmd.none
                )
