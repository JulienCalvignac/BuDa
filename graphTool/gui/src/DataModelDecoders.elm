module DataModelDecoders
    exposing
        ( decodeNode
        , decodeEdge
        , decodeIdentifier
        , decodeDataModel
        , decodeNodesPosition
        , decodeNotification
        , decodeGeometryProperty
        )

import Identifier exposing (Identifier)
import Attribut exposing (Attribut)
import Node exposing (Node)
import Link exposing (Edge)
import DataModel
import Json.Decode exposing (field)
import Json.Decode.Pipeline
import Json.Decode.Extra
import LinkParameters
import Groups
import Set
import Position exposing (Position)
import Layout exposing (NodeLayout)
import Notifications
import Geometries


decodeIdentifier : Json.Decode.Decoder Identifier
decodeIdentifier =
    Json.Decode.int


decodeAttribut : Json.Decode.Decoder Attribut
decodeAttribut =
    Json.Decode.string


decodePosition : Json.Decode.Decoder Position
decodePosition =
    Json.Decode.Pipeline.decode Position
        |> Json.Decode.Pipeline.required "x" Json.Decode.float
        |> Json.Decode.Pipeline.required "y" Json.Decode.float


decodeNode : Json.Decode.Decoder Node
decodeNode =
    Json.Decode.Pipeline.decode Node
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "parent" (Json.Decode.maybe decodeIdentifier)
        |> Json.Decode.Pipeline.required "attribut" (Json.Decode.maybe decodeAttribut)
        |> Json.Decode.Pipeline.optional "geometry" (Json.Decode.maybe decodeIdentifier) Nothing
        |> Json.Decode.Pipeline.required "group" (Json.Decode.Extra.set decodeIdentifier)
        |> Json.Decode.Pipeline.hardcoded False
        |> Json.Decode.Pipeline.optional "position" decodePosition Position.defaultPosition
        |> Json.Decode.Pipeline.optional "blow" Json.Decode.bool False


decodeDataNode : Json.Decode.Decoder DataModel.DataNode
decodeDataNode =
    Json.Decode.Pipeline.decode DataModel.DataNode
        |> Json.Decode.Pipeline.required "data" decodeNode


decodeNodes : Json.Decode.Decoder (List DataModel.DataNode)
decodeNodes =
    Json.Decode.list decodeDataNode


decodeActiveProperties : Json.Decode.Decoder Link.ActivePoperties
decodeActiveProperties =
    -- (Set.fromList (Json.Decode.list decodeIdentifier))
    (Json.Decode.Extra.set decodeIdentifier)


decodeEdge : Json.Decode.Decoder Edge
decodeEdge =
    Json.Decode.Pipeline.decode Edge
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "source" decodeIdentifier
        |> Json.Decode.Pipeline.required "target" decodeIdentifier
        |> Json.Decode.Pipeline.required "parameters" (Json.Decode.Extra.set decodeIdentifier)
        |> Json.Decode.Pipeline.required "attribut" (Json.Decode.maybe decodeAttribut)
        |> Json.Decode.Pipeline.hardcoded 0
        |> Json.Decode.Pipeline.optional "tightness" (Json.Decode.Extra.set decodeIdentifier) Set.empty


decodeDataEdge : Json.Decode.Decoder DataModel.DataEdge
decodeDataEdge =
    Json.Decode.Pipeline.decode DataModel.DataEdge
        |> Json.Decode.Pipeline.required "data" decodeEdge


decodeEdges : Json.Decode.Decoder (List DataModel.DataEdge)
decodeEdges =
    Json.Decode.list decodeDataEdge


decodeProperty : Json.Decode.Decoder LinkParameters.Property
decodeProperty =
    Json.Decode.Pipeline.decode LinkParameters.Property
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "name" Json.Decode.string


decodeParameters : Json.Decode.Decoder LinkParameters.Model
decodeParameters =
    Json.Decode.list decodeProperty


decodeGroupProperty : Json.Decode.Decoder Groups.Property
decodeGroupProperty =
    Json.Decode.Pipeline.decode Groups.Property
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "name" Json.Decode.string


decodeGroups : Json.Decode.Decoder Groups.Model
decodeGroups =
    Json.Decode.list decodeGroupProperty


decodeGeometryProperty : Json.Decode.Decoder Geometries.Property
decodeGeometryProperty =
    Json.Decode.Pipeline.decode Geometries.Property
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.optional "svg" (Json.Decode.maybe Json.Decode.string) Nothing


decodeGeometries : Json.Decode.Decoder Geometries.Model
decodeGeometries =
    Json.Decode.list decodeGeometryProperty


decodeLayout : Json.Decode.Decoder (List Position.NodePosition)
decodeLayout =
    Json.Decode.list decodeNodePosition


decodeNodeLayout : Json.Decode.Decoder Layout.NodeLayout
decodeNodeLayout =
    Json.Decode.Pipeline.decode Layout.NodeLayout
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "layout" decodeLayout


decodeGeometryLayout : Json.Decode.Decoder Layout.GeometryLayout
decodeGeometryLayout =
    Json.Decode.Pipeline.decode Layout.GeometryLayout
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "layout" decodeLayout


decodeDataModel : Json.Decode.Decoder DataModel.DataModel
decodeDataModel =
    Json.Decode.Pipeline.decode DataModel.DataModel
        |> Json.Decode.Pipeline.required "nodes" decodeNodes
        |> Json.Decode.Pipeline.required "edges" decodeEdges
        |> Json.Decode.Pipeline.required "parameters" decodeParameters
        |> Json.Decode.Pipeline.required "groups" decodeGroups
        |> Json.Decode.Pipeline.optional "geometries" decodeGeometries []
        |> Json.Decode.Pipeline.optional "lightedGroup" (Json.Decode.maybe Json.Decode.int) Nothing
        |> Json.Decode.Pipeline.optional "lightedGeometry" (Json.Decode.maybe Json.Decode.int) Nothing
        |> Json.Decode.Pipeline.optional "selectedParameters" (Json.Decode.Extra.set decodeIdentifier) Set.empty
        |> Json.Decode.Pipeline.optional "layouts" (Json.Decode.list decodeNodeLayout) []
        |> Json.Decode.Pipeline.optional "geometryLayouts" (Json.Decode.list decodeGeometryLayout) []
        |> Json.Decode.Pipeline.optional "lightLayout" (Json.Decode.maybe decodeLayout) Nothing
        |> Json.Decode.Pipeline.optional "rootBubbleLayout" (Json.Decode.maybe decodeLayout) Nothing
        |> Json.Decode.Pipeline.optional "mask" (Json.Decode.Extra.set decodeIdentifier) Set.empty
        |> Json.Decode.Pipeline.optional "geometryImage" (Json.Decode.maybe Json.Decode.string) Nothing


decodeNodePosition : Json.Decode.Decoder Position.NodePosition
decodeNodePosition =
    Json.Decode.Pipeline.decode Position.NodePosition
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "position" decodePosition


decodeNodesPosition : Json.Decode.Decoder (List Position.NodePosition)
decodeNodesPosition =
    Json.Decode.list decodeNodePosition


decodeNotificationData_ : Json.Decode.Decoder Notifications.NotificationData
decodeNotificationData_ =
    Json.Decode.oneOf
        [ Json.Decode.map Notifications.BLOC decodeNode
        , Json.Decode.map Notifications.LIEN decodeEdge
        ]


decodeNotification : Json.Decode.Decoder Notifications.Model
decodeNotification =
    Json.Decode.Pipeline.decode Notifications.Model
        |> Json.Decode.Pipeline.required "header" Json.Decode.string
        |> Json.Decode.Pipeline.required "data" decodeNotificationData_
