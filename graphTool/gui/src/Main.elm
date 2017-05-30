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


{-| Main application
-}
view : Model -> Html Actions.Msg
view model =
    div []
        [ button [ onClick Actions.ShowAllData, id "showAllData", value "showAllData" ] [ text "showAllData" ]
        , button [ onClick Actions.ShowBulles, id "showBulles", value "showBulles" ] [ text "showBulles" ]
        , button [ onClick Actions.ShowPBS, id "showPBS", value "showPBS" ] [ text "showPBS" ]
        , button [ onClick Actions.Layout, id "layout", value "layout" ] [ text "layout" ]
        , button [ onClick Actions.CreateNode, id "new", value "new element" ] [ text "new node" ]
        , button [ onClick Actions.CreateEdge, id "edge", value "edge" ] [ text "new edge" ]
        , button [ onClick Actions.DeleteElement, id "delete", value "delete" ] [ text "delete" ]
        , button [ onClick Actions.RenameNode, id "rename", value "rename" ] [ text "rename" ]
        , input [ onInput Actions.InputChange, id "input", placeholder "undefined" ] []
          -- , button [ onClick Actions.RequestModelFromJS, id "import", value "import" ] [ text "import" ]
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
