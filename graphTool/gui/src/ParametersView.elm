module ParametersView exposing (view)

import Html exposing (Html, Attribute, button, div, fieldset, input, label, span, text, section)
import Html.Attributes exposing (id, name, style, type_, checked, value, placeholder, class)
import Html.Events exposing (onClick, on, onInput)
import Model exposing (..)
import Actions
import DataModel
import Link exposing (Edge)


checkbox : Bool -> msg -> String -> Html msg
checkbox b msg name =
    div
        [ id "checkbox"
        , style
            [ ( "padding", "10px" )
            , ( "text-align", "left" )
            ]
        ]
        [ label []
            [ input [ type_ "checkbox", onClick msg, checked b ] []
            , text name
            ]
        ]


fluxLine_ : Maybe Edge -> ( String, Bool ) -> Html Actions.Msg
fluxLine_ m_edge ( key, b ) =
    case m_edge of
        Nothing ->
            div []
                [ checkbox b (Actions.CheckFlux key) key
                ]

        Just x ->
            div []
                [ checkbox b (Actions.CheckProperty x key) key
                ]


exposeList_ : Maybe Edge -> List ( String, Bool ) -> Html Actions.Msg
exposeList_ m_edge list =
    case list of
        [] ->
            div [] []

        x :: xs ->
            div []
                [ fluxLine_ m_edge x
                , exposeList_ m_edge xs
                ]


makeKeyValueList : Maybe Edge -> Model -> List ( String, Bool )
makeKeyValueList m_edge model =
    case m_edge of
        Nothing ->
            List.map (\x -> ( x.name, False )) model.dataModel.parameters

        Just edge ->
            List.map (\x -> ( x.name, Link.isActive x.id edge )) model.dataModel.parameters


expose : Model -> Html Actions.Msg
expose model =
    let
        m_id =
            case model.selection of
                x :: xs ->
                    Just x

                [] ->
                    Nothing

        m_edge =
            case m_id of
                Nothing ->
                    Nothing

                Just x ->
                    DataModel.getEdgeFromId x model.dataModel.edges
    in
        exposeList_ m_edge (makeKeyValueList m_edge model)


view : Model -> Html Actions.Msg
view model =
    div [ id "parameters", style [ ( "text-align", "center" ) ] ]
        [ text "Parameters"
        , Html.hr [] []
        , expose model
        ]



-- view : Model -> Html Actions.Msg
-- view model =
--     div []
--         [
--         Dialog.render
--             { styles =
--                 [ ( "text-align", "center" )
--                   -- , ( "width", "20%" )
--                   -- , ( "height", "50%" )
--                   -- , ( "padding", "10px" )
--                   -- , ( "margin", "10px" )
--                 ]
--             , title = "Parameters"
--             , content =
--                 [ (Html.hr [] [])
--                 , expose model
--                 ]
--             , actionBar = [ dialogButton "Close" ]
--             }
--           model.parameters.visible
--         ]


dialogButton : String -> Html Actions.Msg
dialogButton caption =
    button
        [ -- onClick Actions.ParametersDialog
          class "mdl-button mdl-button--raised mdl-button--accent"
        ]
        [ text caption ]
