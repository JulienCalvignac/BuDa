module DataModelDecoders exposing (decodeIdentifier, decodeDataModel)

import DataModel
import Json.Decode exposing (field)
import Json.Decode.Pipeline


decodeIdentifier : Json.Decode.Decoder DataModel.Identifier
decodeIdentifier =
    Json.Decode.int


decodeNode_ : Json.Decode.Decoder DataModel.Node
decodeNode_ =
    Json.Decode.Pipeline.decode DataModel.Node
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


decodeEdge_ : Json.Decode.Decoder DataModel.Edge
decodeEdge_ =
    Json.Decode.Pipeline.decode DataModel.Edge
        |> Json.Decode.Pipeline.required "id" decodeIdentifier
        |> Json.Decode.Pipeline.required "source" decodeIdentifier
        |> Json.Decode.Pipeline.required "target" decodeIdentifier


decodeEdge : Json.Decode.Decoder DataModel.DataEdge
decodeEdge =
    Json.Decode.Pipeline.decode DataModel.DataEdge
        |> Json.Decode.Pipeline.required "data" decodeEdge_


decodeEdges : Json.Decode.Decoder (List DataModel.DataEdge)
decodeEdges =
    Json.Decode.list decodeEdge


decodeDataModel : Json.Decode.Decoder DataModel.DataModel
decodeDataModel =
    Json.Decode.Pipeline.decode DataModel.DataModel
        |> Json.Decode.Pipeline.required "nodes" decodeNodes
        |> Json.Decode.Pipeline.required "edges" decodeEdges
