module DataModelEncoders exposing (encodeModel, encodeMetaModel)

import DataModel
import Json.Encode exposing (Value, array, bool, encode, float, int, list, null, object, string)


encodeIdentifier : DataModel.Identifier -> Value
encodeIdentifier identifier =
    Json.Encode.int identifier


maybe : (a -> Json.Encode.Value) -> Maybe a -> Json.Encode.Value
maybe encoder maybeVal =
    case maybeVal of
        Nothing ->
            Json.Encode.null

        Just val ->
            encoder val


encodeNode_ : DataModel.Node -> Value
encodeNode_ n =
    object
        [ ( "id", encodeIdentifier n.id )
        , ( "name", Json.Encode.string n.name )
        , ( "parent", maybe encodeIdentifier n.parent )
        ]


encodeNode : DataModel.Node -> Value
encodeNode n =
    object
        [ ( "data", encodeNode_ n ) ]


encodeNodes : List DataModel.Node -> Value
encodeNodes l =
    Json.Encode.list <| List.map encodeNode l


encodeEdge_ : DataModel.Edge -> Value
encodeEdge_ je =
    object
        [ ( "id", encodeIdentifier je.id )
        , ( "source", encodeIdentifier je.source )
        , ( "target", encodeIdentifier je.target )
        ]


encodeEdge : DataModel.Edge -> Value
encodeEdge je =
    object
        [ ( "data", encodeEdge_ je ) ]


encodeEdges : List DataModel.Edge -> Value
encodeEdges l =
    Json.Encode.list <| List.map encodeEdge l


encodeModel_ : DataModel.Model -> Value
encodeModel_ jsmodel =
    object
        [ ( "nodes", encodeNodes jsmodel.nodes )
        , ( "edges", encodeEdges jsmodel.edges )
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
