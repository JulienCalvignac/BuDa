module DataModelDecoders exposing (decodeIdentifier, decodeDataModel)

import Identifier exposing (Identifier)
import Node exposing (Node)
import Link exposing (Edge)
import DataModel
import Set exposing (Set)
import Json.Decode exposing (field)
import Json.Decode.Pipeline
import Json.Decode.Extra
import LinkParameters


decodeIdentifier : Json.Decode.Decoder Identifier
decodeIdentifier =
    Json.Decode.int


decodeNode_ : Json.Decode.Decoder Node
decodeNode_ =
    Json.Decode.Pipeline.decode Node
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "parent" (Json.Decode.maybe decodeIdentifier)


decodeNode : Json.Decode.Decoder DataModel.DataNode
decodeNode =
    Json.Decode.Pipeline.decode DataModel.DataNode
        |> Json.Decode.Pipeline.required "data" decodeNode_


decodeNodes : Json.Decode.Decoder (List DataModel.DataNode)
decodeNodes =
    Json.Decode.list decodeNode


decodeActiveProperties : Json.Decode.Decoder Link.ActivePoperties
decodeActiveProperties =
    -- (Set.fromList (Json.Decode.list decodeIdentifier))
    (Json.Decode.Extra.set decodeIdentifier)


decodeEdge_ : Json.Decode.Decoder Edge
decodeEdge_ =
    Json.Decode.Pipeline.decode Edge
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "source" decodeIdentifier
        |> Json.Decode.Pipeline.required "target" decodeIdentifier
        |> Json.Decode.Pipeline.required "parameters" (Json.Decode.Extra.set decodeIdentifier)


decodeEdge : Json.Decode.Decoder DataModel.DataEdge
decodeEdge =
    Json.Decode.Pipeline.decode DataModel.DataEdge
        |> Json.Decode.Pipeline.required "data" decodeEdge_


decodeEdges : Json.Decode.Decoder (List DataModel.DataEdge)
decodeEdges =
    Json.Decode.list decodeEdge


decodeProperty : Json.Decode.Decoder LinkParameters.Property
decodeProperty =
    Json.Decode.Pipeline.decode LinkParameters.Property
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "name" Json.Decode.string


decodeParameters : Json.Decode.Decoder (List LinkParameters.Property)
decodeParameters =
    Json.Decode.list decodeProperty


decodeDataModel : Json.Decode.Decoder DataModel.DataModel
decodeDataModel =
    Json.Decode.Pipeline.decode DataModel.DataModel
        |> Json.Decode.Pipeline.required "nodes" decodeNodes
        |> Json.Decode.Pipeline.required "edges" decodeEdges
        |> Json.Decode.Pipeline.required "parameters" decodeParameters
