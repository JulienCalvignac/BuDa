module Main exposing (..)

import Actions
import Html exposing (Html, button, div, input, label, span, text)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Model exposing (..)
import View


onInputFile : msg -> Html.Attribute msg
onInputFile message =
    on "change" (Json.Decode.succeed message)


checkbox : Bool -> msg -> String -> Html msg
checkbox b msg name =
    div [ id "checkbox" ]
        [ label
            [ style [ ( "padding", "20px" ) ]
            ]
            [ input [ type_ "checkbox", onClick msg, checked b ] []
            , text name
            ]
        ]


{-| Main application
-}
view : Model -> Html Actions.Msg
view model =
    div []
        [ button [ onClick Actions.ShowAllData, id "showAllData", value "showAllData" ] [ text "showAllData" ]
        , button [ onClick Actions.ShowView, id "showView", value "showView" ] [ text "showView" ]
        , checkbox model.isPBSActive Actions.ChangeViewType "PBS"
        , button [ onClick Actions.Layout, id "layout", value "layout" ] [ text "layout" ]
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
