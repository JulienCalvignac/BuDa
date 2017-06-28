module ScigraphEncoders exposing (encodeLNK, encodePBS)

import DataModel
import Node exposing (Node)
import Link exposing (Edge)


encodePBS : DataModel.Model -> String
encodePBS model =
    "graph app_graph {\noverlap=false\n" ++ encodeNodes model.nodes ++ "}\n"


encodeLNK : DataModel.Model -> String
encodeLNK model =
    "graph app_graph {\noverlap=false\n" ++ encodeLinks model model.edges ++ "}\n"


nodeParentToString : Node -> List Node -> String
nodeParentToString n l =
    case n.parent of
        Nothing ->
            ""

        Just pname ->
            case DataModel.getNodeNameFromId pname l of
                Nothing ->
                    ""

                Just s ->
                    s


encodeNode : Node -> List Node -> String
encodeNode n l =
    case DataModel.nodeHasParent n of
        True ->
            nodeParentToString n l ++ " -- " ++ n.name ++ ";\n"

        False ->
            ""


encodeNodes : List Node -> String
encodeNodes list =
    case list of
        x :: xs ->
            encodeNode x list ++ encodeNodes xs

        [] ->
            ""


encodeLink : DataModel.Model -> Edge -> String
encodeLink model edge =
    let
        from_name =
            DataModel.getNodeNameFromId edge.source model.nodes

        to_name =
            DataModel.getNodeNameFromId edge.target model.nodes

        result =
            case from_name of
                Just fn ->
                    case to_name of
                        Just tn ->
                            fn ++ " -- " ++ tn ++ ";\n"

                        Nothing ->
                            fn ++ " -- " ++ "Undefined" ++ ";\n"

                Nothing ->
                    "Undefined" ++ " -- " ++ "Undefined" ++ ";\n"
    in
        result


encodeLinks : DataModel.Model -> List Edge -> String
encodeLinks model list =
    case list of
        x :: xs ->
            encodeLink model x ++ encodeLinks model xs

        [] ->
            ""
