module View exposing (init, view)

import Messages
import Html exposing (Html, Attribute, button, div, fieldset, input, label, span, text, section)
import Html.Attributes exposing (id, name, style, type_, checked, value, placeholder, class)
import Html.Events exposing (onClick, on, onInput)
import Json.Decode
import Model exposing (ViewType(..))
import ParametersView
import AttributView
import GroupsView
import ModelActions


init : ( Model.Model, Cmd Messages.Msg )
init =
    ( Model.defaultModel, Cmd.none )


onInputFile : msg -> Html.Attribute msg
onInputFile message =
    on "change" (Json.Decode.succeed message)


radio : msg -> String -> Bool -> Html msg
radio msg value b =
    label
        [ style [ ( "padding", "5px" ) ]
        ]
        [ input [ type_ "radio", name "viewType-radio", onClick msg, checked b ] []
        , text value
        ]


{-| Main application
-}
view : Model.Model -> Html Messages.Msg
view model =
    div []
        [ div []
            [ fieldset [ id "fieldset" ]
                [ radio (Messages.SwitchToView Model.BULL) "Bubble Diagram" (model.viewType == Model.BULL)
                , radio (Messages.SwitchToView Model.PBS) "PBS" (model.viewType == Model.PBS)
                , radio (Messages.SwitchToView Model.ALL) "All" (model.viewType == Model.ALL)
                , radio (Messages.SwitchToView Model.ALL_LIGHT) "Light" (model.viewType == Model.ALL_LIGHT)
                ]
            ]
        , button [ onClick Messages.CreateNode, id "new", value "new element" ] [ text "Node" ]
        , button [ onClick Messages.CreateLink, id "edge", value "edge" ] [ text "Link" ]
        , button [ onClick Messages.RenameNode, id "rename", value "rename" ] [ text "Name" ]
        , ParametersView.view model
        , AttributView.view model
        , GroupsView.view model
        , button [ onClick Messages.CreateParameter, id "createParameter", value "createParameter" ] [ text "+" ]
        , button [ onClick Messages.DeleteParameter, id "deleteParameter", value "deleteParameter" ] [ text "-" ]
        , button [ onClick Messages.CreateGroup, id "createGroup", value "createGroup" ] [ text "+" ]
        , button [ onClick Messages.DeleteGroup, id "deleteGroup", value "deleteGroup" ] [ text "-" ]
          -- , button [ onClick Actions.ParametersDialog, id "dialog", value "dialog" ] [ text "dialog" ]
        , button [ onClick Messages.ExportLink, id "export", value "export" ] [ text "Export" ]
        , input [ onInput Messages.InputChange, id "input", placeholder "undefined" ] []
        , input [ onInput Messages.InputFileChange, id "inputFile", placeholder "undefined" ] []
        , button [ onClick Messages.SaveModel, id "saveModel", value "saveModel" ] [ text "Save" ]
        , input [ onInputFile Messages.LoadModel, id model.loadModelId, type_ "file" ] []
        , button [ onClick Messages.Undo, id "undo", value "undo" ] [ text "Undo" ]
        , button [ onClick Messages.GroupNodes, id "group", value "group" ] [ text "Group" ]
        , button [ onClick Messages.UpdateTightness, id "Tight", value "Tight" ] [ text "Tight" ]
        , button [ onClick Messages.Redo, id "redo", value "redo" ] [ text "Redo" ]
        , div [ id "label" ] [ text (ModelActions.getAscendantName model) ]
          -- , input [ id "log", value "" ] [ text "" ]
        ]
