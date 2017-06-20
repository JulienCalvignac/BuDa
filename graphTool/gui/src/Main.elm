module Main exposing (..)

import Actions
import Html exposing (Html, Attribute, button, div, fieldset, input, label, span, text, section)
import Html.Attributes exposing (id, name, style, type_, checked, value, placeholder)
import Html.Events exposing (onClick, on, onInput)
import Json.Decode
import Model exposing (..)
import View


onInputFile : msg -> Html.Attribute msg
onInputFile message =
    on "change" (Json.Decode.succeed message)


radio : msg -> String -> Html msg
radio msg value =
    label
        [ style [ ( "padding", "5px" ) ]
        ]
        [ input [ type_ "radio", name "viewType-radio", onClick msg ] []
        , text value
        ]


{-| Main application
-}
view : Model -> Html Actions.Msg
view model =
    div []
        [ button [ onClick Actions.ShowView, id "showView", value "showView" ]
            [ text "showView" ]
        , div []
            [ fieldset [ id "fieldset" ]
                [ radio (Actions.SwitchToView Model.BULL) "Bubble Diagram"
                , radio (Actions.SwitchToView Model.PBS) "PBS"
                , radio (Actions.SwitchToView Model.ALL) "All"
                ]
            ]
        , button [ onClick Actions.CreateNode, id "new", value "new element" ] [ text "new node" ]
        , button [ onClick Actions.CreateLink, id "edge", value "edge" ] [ text "new link" ]
        , button [ onClick Actions.RenameNode, id "rename", value "rename" ] [ text "rename" ]
        , input [ onInput Actions.InputChange, id "input", placeholder "undefined" ] []
        , button [ onClick Actions.SaveModel, id "saveModel", value "saveModel" ] [ text "saveModel" ]
        , input [ onInputFile Actions.LoadModel, id model.loadModelId, type_ "file" ] []
          -- , input [ id "log", value "" ] [ text "" ]
        ]


main : Program Never Model.Model Actions.Msg
main =
    Html.program
        { init = View.init
        , view = view
        , update = Actions.update
        , subscriptions = Actions.subscriptions
        }
