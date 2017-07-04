module DataModel
    exposing
        ( DataEdge
        , DataModel
        , DataNode
        , ExportLink
          -- , Edge
          -- , Identifier
        , MetaModel
        , Model
          -- , Node
        , addNewNodeToModel
        , anyLink
        , anyLinks
        , anyLinksParameter
        , bros
        , childs
        , dataModelToModel
        , defaultModel
        , edgeST
        , getEdgeFromId
        , getEdgeFromNodesId
        , getNodeFromId
        , getNodeFromName
        , getNodeIdFromName
        , getNodeIdentifier
        , getNodeNameFromId
        , isEdgePresent
        , isNamePresent
        , isNodePresent
        , isNodeIdPresent
        , nodeHasParent
        , maximumNodeId
        , anyEdgeDoublon
        )

import Identifier exposing (Identifier)
import Link exposing (Edge)
import Node exposing (Node)
import LinkParameters


type alias Model =
    { nodes : List Node
    , edges : List Edge
    , parameters : LinkParameters.Model
    , curNodeId : Identifier
    }


type alias MetaModel =
    { filename : String
    , model : Model
    }


type alias ExportLink =
    { filename : String
    , model : String
    }


type alias DataNode =
    { data : Node }


type alias DataEdge =
    { data : Edge }


type alias DataModel =
    { nodes : List DataNode
    , edges : List DataEdge
    , parameters : LinkParameters.Model
    }


defaultModel : Model
defaultModel =
    { nodes = []
    , edges = []
    , parameters = LinkParameters.defaultModel
    , curNodeId = 0
    }


dataNodeToNode : DataNode -> Node
dataNodeToNode dn =
    dn.data


dataEdgeToEdge : DataEdge -> Edge
dataEdgeToEdge de =
    de.data


maximumNodeId : List Node -> Identifier
maximumNodeId ln =
    case List.maximum (List.map (\x -> x.id) ln) of
        Nothing ->
            0

        Just m ->
            m


maximumEdgeId : List Edge -> Identifier
maximumEdgeId le =
    case List.maximum (List.map (\x -> x.id) le) of
        Nothing ->
            0

        Just m ->
            m


maximumParameterId : List LinkParameters.Property -> Identifier
maximumParameterId list =
    case List.maximum (List.map (\x -> x.id) list) of
        Nothing ->
            0

        Just m ->
            m


dataModelToModel : DataModel -> Model -> Model
dataModelToModel dm model =
    let
        ln =
            List.map dataNodeToNode dm.nodes

        le =
            List.map dataEdgeToEdge dm.edges

        newId =
            case
                List.maximum [ maximumNodeId ln, maximumEdgeId le, maximumParameterId dm.parameters ]
            of
                Just m ->
                    m

                Nothing ->
                    0
    in
        { nodes = ln
        , edges = le
        , parameters = dm.parameters
        , curNodeId = newId
        }


getNodeIdentifier : Model -> Model
getNodeIdentifier model =
    let
        newId =
            model.curNodeId + 1
    in
        { model | curNodeId = newId }


getNodeFromId : Identifier -> List Node -> Maybe Node
getNodeFromId id list =
    case list of
        x :: xs ->
            case x.id == id of
                True ->
                    Just x

                False ->
                    getNodeFromId id xs

        [] ->
            Nothing


getEdgeFromId : Identifier -> List Edge -> Maybe Edge
getEdgeFromId id list =
    case list of
        x :: xs ->
            case x.id == id of
                True ->
                    Just x

                False ->
                    getEdgeFromId id xs

        [] ->
            Nothing


getEdgeFromNodesId : Identifier -> Identifier -> List Edge -> Maybe Edge
getEdgeFromNodesId ids idt list =
    case list of
        x :: xs ->
            case (x.source == ids && x.target == idt) || (x.source == idt && x.target == ids) of
                True ->
                    Just x

                False ->
                    getEdgeFromNodesId ids idt xs

        [] ->
            Nothing


getNodeFromName : String -> List Node -> Maybe Node
getNodeFromName s list =
    case list of
        x :: xs ->
            case x.name == s of
                True ->
                    Just x

                False ->
                    getNodeFromName s xs

        [] ->
            Nothing


getNodeNameFromId : Identifier -> List Node -> Maybe String
getNodeNameFromId id list =
    case list of
        x :: xs ->
            case x.id == id of
                True ->
                    Just x.name

                False ->
                    getNodeNameFromId id xs

        [] ->
            Nothing


getNodeIdFromName : String -> List Node -> Maybe Identifier
getNodeIdFromName s list =
    case list of
        x :: xs ->
            case x.name == s of
                True ->
                    Just x.id

                False ->
                    getNodeIdFromName s xs

        [] ->
            Nothing


nodeHasParent : Node -> Bool
nodeHasParent n =
    case n.parent of
        Nothing ->
            False

        _ ->
            True


createProperty : String -> Model -> Model
createProperty s model =
    let
        new_parameters =
            (LinkParameters.property model.curNodeId s) :: model.parameters

        m1 =
            { model | parameters = new_parameters }
    in
        getNodeIdentifier m1


makeNewNode : String -> String -> Model -> ( Node, Model )
makeNewNode name pname model =
    let
        m1 =
            getNodeIdentifier model

        pId =
            getNodeIdFromName pname m1.nodes

        newNode =
            --{ id = m1.curNodeId, name = name, parent = pId }
            Node.node m1.curNodeId name pId
    in
        ( newNode, m1 )


addNewNodeToModel : String -> String -> Model -> Model
addNewNodeToModel name parent model =
    let
        ( newNode, m1 ) =
            makeNewNode name parent model

        newNodes =
            (::) newNode m1.nodes
    in
        { m1 | nodes = newNodes }


isNodeIdPresent : Identifier -> List Node -> Bool
isNodeIdPresent id list =
    case list of
        x :: xs ->
            case x.id == id of
                True ->
                    True

                False ->
                    isNodeIdPresent id xs

        [] ->
            False


isNamePresent : String -> List Node -> Bool
isNamePresent s l =
    case l of
        x :: xs ->
            case x.name == s of
                True ->
                    True

                False ->
                    isNamePresent s xs

        [] ->
            False


isNodePresent : Node -> List Node -> Bool
isNodePresent n list =
    case list of
        x :: xs ->
            case x.id == n.id of
                True ->
                    True

                False ->
                    isNodePresent n xs

        [] ->
            False



-- isEdgePresent : Edge -> List Edge -> Bool
-- isEdgePresent n list =
--     case list of
--         x :: xs ->
--             case (x.source == n.source && x.target == n.target) of
--                 True ->
--                     True
--
--                 False ->
--                     isEdgePresent n xs
--
--         [] ->
--             False


isEdgePresent : Edge -> List Edge -> Bool
isEdgePresent e list =
    case list of
        [] ->
            False

        x :: xs ->
            case (x.source == e.source && x.target == e.target) || (x.source == e.target && x.target == e.source) of
                True ->
                    True

                False ->
                    isEdgePresent e xs


anyEdgeDoublon : List Edge -> Bool
anyEdgeDoublon list =
    case list of
        [] ->
            False

        x :: xs ->
            case isEdgePresent x xs of
                True ->
                    True

                False ->
                    anyEdgeDoublon xs


anyLink : List Node -> Node -> List Edge -> Bool
anyLink list n edges =
    case list of
        [] ->
            False

        x :: xs ->
            case isEdgePresent (Link.link x.id n.id) edges of
                -- { id = 0, source = x.id, target = n.id }
                True ->
                    True

                False ->
                    anyLink xs n edges


anyLinks : List Node -> List Node -> List Edge -> Bool
anyLinks l1 list edges =
    case list of
        [] ->
            False

        x :: xs ->
            case anyLink l1 x edges of
                True ->
                    True

                False ->
                    anyLinks l1 xs edges


anyLinkParameter : Identifier -> List Node -> Node -> List Edge -> Bool
anyLinkParameter idx list n edges =
    case list of
        [] ->
            False

        x :: xs ->
            let
                m_edge =
                    getEdgeFromNodesId x.id n.id edges

                b =
                    case m_edge of
                        Nothing ->
                            False

                        Just edge ->
                            Link.isActive idx edge

                b1 =
                    case b of
                        True ->
                            True

                        False ->
                            anyLinkParameter idx xs n edges
            in
                b1


anyLinksParameter : Identifier -> List Node -> List Node -> List Edge -> Bool
anyLinksParameter idx l1 list edges =
    case list of
        [] ->
            False

        x :: xs ->
            case anyLinkParameter idx l1 x edges of
                True ->
                    True

                False ->
                    anyLinksParameter idx l1 xs edges


edgeST : Node -> Node -> Edge
edgeST n m =
    --{ id = 0, source = n.id, target = m.id }
    Link.link n.id m.id


childs : Node -> List Node -> List Node
childs n list =
    List.filter (\x -> x.parent == Just n.id) list


bros : Node -> List Node -> List Node
bros n list =
    List.filter (\x -> (not (x.id == n.id)) && (x.parent == n.parent)) list
