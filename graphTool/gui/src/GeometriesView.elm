module GeometriesView exposing (view)

import Html exposing (Html, Attribute, button, div, fieldset, input, label, span, text, section)
import Html.Attributes exposing (id, name, style, type_, checked, value, placeholder, class)
import Html.Events exposing (onClick, onCheck, on, onInput)


-- import Geometries

import Messages
import Model exposing (Model)
import DataModel
import Node exposing (Node)


view : Model -> Html Messages.Msg
view model =
    div [ id "geometries", style [ ( "text-align", "center" ) ] ]
        [ text "Geometries"
        , Html.hr [] []
        , div [ id "geometryView" ] [ expose model ]
        , button [ onClick Messages.CreateGeometry, id "createGeometry", value "createGeometry" ] [ text "+" ]
        , button [ onClick Messages.DeleteGeometry, id "deleteGeometry", value "deleteGeometry" ] [ text "-" ]
        ]


expose : Model -> Html Messages.Msg
expose model =
    let
        m_id =
            case model.selection of
                x :: xs ->
                    Just x

                [] ->
                    Nothing

        m_node =
            case m_id of
                Nothing ->
                    Nothing

                Just x ->
                    DataModel.getNodeFromId x model.dataModel.nodes
    in
        exposeList_ m_node (makeKeyValueList m_node model)


makeKeyValueList : Maybe Node -> Model -> List ( String, Bool )
makeKeyValueList m_node model =
    case m_node of
        Nothing ->
            List.map
                (\x ->
                    ( x.name
                    , False
                    )
                )
                model.dataModel.geometries

        Just node ->
            List.map (\x -> ( x.name, Node.hasGeometry x.id node )) model.dataModel.geometries


exposeList_ : Maybe Node -> List ( String, Bool ) -> Html Messages.Msg
exposeList_ m_node list =
    case m_node of
        Nothing ->
            -- div [] []
            case list of
                [] ->
                    div [] []

                x :: xs ->
                    div []
                        [ highLightLine_ x
                        , exposeList_ m_node xs
                        ]

        Just n ->
            case list of
                [] ->
                    div [] []

                x :: xs ->
                    div []
                        [ fluxLine_ n x
                        , exposeList_ m_node xs
                        ]


fluxLine_ : Node -> ( String, Bool ) -> Html Messages.Msg
fluxLine_ n ( key, b ) =
    div []
        [ checkbox b
            (Messages.CheckNodeGeometryProperty n key)
            -- Messages.NoOp
            key
          -- , svgBox Messages.NoOp key
        ]


highLightLine_ : ( String, Bool ) -> Html Messages.Msg
highLightLine_ ( key, b ) =
    div []
        [ checkbox b
            (Messages.HighLightGeometry key)
            -- Messages.NoOp
            key
          -- , svgBox Messages.NoOp key
        ]


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
            [ input
                [ type_ "checkbox"
                , onClick msg
                , checked b
                ]
                []
            , text name
            ]
        ]



-- svgBox : msg -> String -> Html Messages.Msg
-- svgBox msg s =
--     div [ id "svg" ] [ text s ]
