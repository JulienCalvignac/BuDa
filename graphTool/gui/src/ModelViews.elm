module ModelViews
    exposing
        ( getPBSView
        , getBullesViewFromNodeId
        , getBullesView
        , getPBSViewFromNodeId
        , getPBSViewFromNodeName
        , getGeometryViewFromId
        )

import Identifier exposing (Identifier)
import DataModel
import ModelManagement
import Node


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


getGeometryViewFromId : DataModel.Model -> Identifier -> DataModel.Model
getGeometryViewFromId model id =
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
