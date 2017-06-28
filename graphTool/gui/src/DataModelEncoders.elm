module DataModelEncoders exposing (encodeModel, encodeMetaModel, encodeExport)

import Identifier exposing (Identifier)
import Node exposing (Node)
import Link exposing (Edge)
import DataModel
import Json.Encode exposing (Value, array, bool, encode, float, int, list, null, object, string)
import Set exposing (Set)
import LinkParameters


encodeIdentifier : Identifier -> Value
encodeIdentifier identifier =
    Json.Encode.int identifier


maybe : (a -> Json.Encode.Value) -> Maybe a -> Json.Encode.Value
maybe encoder maybeVal =
    case maybeVal of
        Nothing ->
            Json.Encode.null

        Just val ->
            encoder val


encodeNode_ : Node -> Value
encodeNode_ n =
    object
        [ ( "id", encodeIdentifier n.id )
        , ( "name", Json.Encode.string n.name )
        , ( "parent", maybe encodeIdentifier n.parent )
        ]


encodeNode : Node -> Value
encodeNode n =
    object
        [ ( "data", encodeNode_ n ) ]


encodeNodes : List Node -> Value
encodeNodes l =
    Json.Encode.list <| List.map encodeNode l


encodeEdge_ : Edge -> Value
encodeEdge_ je =
    object
        [ ( "id", encodeIdentifier je.id )
        , ( "source", encodeIdentifier je.source )
        , ( "target", encodeIdentifier je.target )
        , ( "parameters", (Json.Encode.list <| List.map encodeIdentifier (Set.toList je.parameters)) )
        ]


encodeEdge : Edge -> Value
encodeEdge je =
    object
        [ ( "data", encodeEdge_ je ) ]


encodeEdges : List Edge -> Value
encodeEdges l =
    Json.Encode.list <| List.map encodeEdge l


encodeProperty : LinkParameters.Property -> Value
encodeProperty property =
    object
        [ ( "id", encodeIdentifier property.id )
        , ( "name", Json.Encode.string property.name )
        ]


encodeParameters : LinkParameters.Model -> Value
encodeParameters parameters =
    (Json.Encode.list <| List.map encodeProperty parameters)


encodeModel_ : DataModel.Model -> Value
encodeModel_ jsmodel =
    object
        [ ( "nodes", encodeNodes jsmodel.nodes )
        , ( "edges", encodeEdges jsmodel.edges )
        , ( "parameters", encodeParameters jsmodel.parameters )
        ]


encodeModel : DataModel.Model -> String
encodeModel =
    encode 0 << encodeModel_


encodeMetaModel_ : DataModel.MetaModel -> Value
encodeMetaModel_ meta =
    object
        [ ( "filename", string meta.filename )
        , ( "model", encodeModel_ meta.model )
        ]


encodeMetaModel : DataModel.MetaModel -> String
encodeMetaModel =
    encode 0 << encodeMetaModel_


encodeExport_ : DataModel.ExportLink -> Value
encodeExport_ meta =
    object
        [ ( "filename", string meta.filename )
        , ( "model", string meta.model )
        ]


encodeExport : DataModel.ExportLink -> String
encodeExport =
    encode 0 << encodeExport_
