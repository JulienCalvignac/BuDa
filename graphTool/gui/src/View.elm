module View exposing (init, view)

import Messages
import Html exposing (Html, Attribute, button, div, fieldset, input, label, span, text, section)
import Html.Attributes exposing (id, name, style, type_, checked, value, placeholder, class)
import Html.Events exposing (onClick, on, onInput)
import Json.Decode
import Model exposing (..)
import ParametersView
import AttributView


init : ( Model.Model, Cmd Messages.Msg )
init =
    ( Model.defaultModel, Cmd.none )


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
view : Model -> Html Messages.Msg
view model =
    div []
        [ button [ onClick Messages.ShowView, id "showView", value "showView" ]
            [ text "showView" ]
        , div []
            [ fieldset [ id "fieldset" ]
                [ radio (Messages.SwitchToView Model.BULL) "Bubble Diagram"
                , radio (Messages.SwitchToView Model.PBS) "PBS"
                , radio (Messages.SwitchToView Model.ALL) "All"
                ]
            ]
        , button [ onClick Messages.CreateNode, id "new", value "new element" ] [ text "new node" ]
        , button [ onClick Messages.CreateLink, id "edge", value "edge" ] [ text "new link" ]
        , button [ onClick Messages.RenameNode, id "rename", value "rename" ] [ text "rename" ]
        , ParametersView.view model
        , AttributView.view model
        , button [ onClick Messages.CreateParameter, id "createParameter", value "createParameter" ] [ text "+" ]
        , button [ onClick Messages.DeleteParameter, id "deleteParameter", value "deleteParameter" ] [ text "-" ]
          -- , button [ onClick Actions.ParametersDialog, id "dialog", value "dialog" ] [ text "dialog" ]
        , button [ onClick Messages.ExportLink, id "export", value "export" ] [ text "export" ]
        , input [ onInput Messages.InputChange, id "input", placeholder "undefined" ] []
        , button [ onClick Messages.SaveModel, id "saveModel", value "saveModel" ] [ text "saveModel" ]
        , input [ onInputFile Messages.LoadModel, id model.loadModelId, type_ "file" ] []
          -- , input [ id "log", value "" ] [ text "" ]
        ]
