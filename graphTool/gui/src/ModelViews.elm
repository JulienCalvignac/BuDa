module ModelViews
    exposing
        ( getPBSView
        , getBullesViewFromNodeId
        , getBullesView
        , getPBSViewFromNodeId
        , getPBSViewFromNodeName
        , getGeometryView
        )

import Identifier exposing (Identifier)
import DataModel
import ModelManagement
import Node
import Geometries


getPBSView : DataModel.Model -> DataModel.Model
getPBSView model =
    ModelManagement.listNodeToPBS model.nodes


getBullesViewFromNodeId : DataModel.Model -> Identifier -> DataModel.Model
getBullesViewFromNodeId model id =
    ModelManagement.subBullesModelFromId model id


getBullesView : DataModel.Model -> DataModel.Model
getBullesView model =
    ModelManagement.subBullesFromUniverse model


getBullesViewFromNodeName : DataModel.Model -> String -> DataModel.Model
getBullesViewFromNodeName model s =
    ModelManagement.subBullesModelFromName model s


getPBSViewFromNodeId : DataModel.Model -> Identifier -> DataModel.Model
getPBSViewFromNodeId model id =
    ModelManagement.listNodeToPBSFromNodeId model.nodes id


getPBSViewFromNodeName : DataModel.Model -> String -> DataModel.Model
getPBSViewFromNodeName model s =
    ModelManagement.listNodeToPBSFromNodeName model.nodes s


getGeometryView : DataModel.Model -> Maybe Identifier -> DataModel.Model
getGeometryView model m_id =
    case m_id of
        Just id ->
            getGeometryViewFromId_ { model | geometryImage = (Geometries.getImageFromId id model.geometries) } id

        Nothing ->
            getAllGeometries_ { model | geometryImage = Nothing }


getAllGeometries_ : DataModel.Model -> DataModel.Model
getAllGeometries_ model =
    let
        newNodes =
            List.filter (\x -> not (x.geometry == Nothing)) model.nodes

        newEdges =
            List.filter
                (\x ->
                    (DataModel.isNodeIdPresent x.source newNodes)
                        && (DataModel.isNodeIdPresent x.target newNodes)
                )
                model.edges
    in
        { model | nodes = newNodes, edges = newEdges }


getGeometryViewFromId_ : DataModel.Model -> Identifier -> DataModel.Model
getGeometryViewFromId_ model id =
    let
        newNodes =
            List.filter (\x -> Node.hasGeometry id x) model.nodes

        newEdges =
            List.filter
                (\x ->
                    let
                        ( m_s, m_t ) =
                            ( DataModel.getNodeFromId x.source model.nodes, DataModel.getNodeFromId x.target model.nodes )

                        res =
                            case ( m_s, m_t ) of
                                ( Just ns, Just nt ) ->
                                    (Node.hasGeometry id ns) && (Node.hasGeometry id nt)

                                _ ->
                                    False
                    in
                        res
                )
                model.edges
    in
        { model | nodes = newNodes, edges = newEdges }
