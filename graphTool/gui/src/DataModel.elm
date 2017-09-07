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
        , createProperty
        , createGroupProperty
        , dataModelToModel
        , defaultModel
        , deleteProperty
        , deleteGroupProperty
        , edgeST
        , getEdgeFromId
        , getEdgeFromNodesId
        , getEdgeIdFromNodesId
        , getNodeFromId
        , getNodeFromName
        , getNodeIdFromName
        , getNodeIdentifier
        , getNodeNameFromId
        , getParentFromNodeId
        , isEdgePresent
        , isNamePresent
        , isNodePresent
        , isNodeIdPresent
        , isIdPresentInList
        , nodeHasParent
        , maximumNodeId
        , anyEdgeDoublon
        , nodeListSameParent
        )

import Identifier exposing (Identifier)
import Link exposing (Edge)
import Node exposing (Node)
import LinkParameters
import Groups
import Set exposing (Set)


type alias Model =
    { nodes : List Node
    , edges : List Edge
    , parameters : LinkParameters.Model
    , curNodeId : Identifier
    , groups : Groups.Model
    , lightedGroup : Maybe Identifier
    , selectedParameters : Set Identifier
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
    , groups : Groups.Model
    , lightedGroup : Maybe Identifier
    , selectedParameters : Set Identifier
    }


defaultModel : Model
defaultModel =
    { nodes = []
    , edges = []
    , parameters = LinkParameters.defaultModel
    , curNodeId = 0
    , groups = Groups.defaultModel
    , lightedGroup = Nothing
    , selectedParameters = Set.empty
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
        , groups = dm.groups
        , lightedGroup = dm.lightedGroup
        , selectedParameters = dm.selectedParameters
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


getParentFromNodeId : Maybe Identifier -> List Node -> Maybe Identifier
getParentFromNodeId maybe_idx nodes =
    case maybe_idx of
        Nothing ->
            Nothing

        Just idx ->
            let
                maybe_n =
                    getNodeFromId idx nodes

                parent =
                    case maybe_n of
                        Nothing ->
                            Nothing

                        Just n ->
                            n.parent
            in
                parent


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


getEdgeIdFromNodesId : Identifier -> Identifier -> List Edge -> Maybe Identifier
getEdgeIdFromNodesId ids idt list =
    case (getEdgeFromNodesId ids idt list) of
        Nothing ->
            Nothing

        Just edge ->
            Just edge.id


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


deleteProperty : String -> Model -> Model
deleteProperty s model =
    let
        maybe_param =
            LinkParameters.getPropertyIdFromName s model.parameters

        newModel =
            case maybe_param of
                Nothing ->
                    model

                Just p ->
                    let
                        newParameters =
                            List.filter (\x -> not (x.id == p)) model.parameters
                    in
                        { model | parameters = newParameters }
    in
        newModel


createGroupProperty : String -> Model -> Model
createGroupProperty s model =
    let
        newGroups =
            (Groups.property model.curNodeId s) :: model.groups

        m1 =
            { model | groups = newGroups }
    in
        getNodeIdentifier m1


deleteGroupProperty : String -> Model -> Model
deleteGroupProperty s model =
    let
        maybe_group =
            Groups.getPropertyIdFromName s model.groups

        newModel =
            case maybe_group of
                Nothing ->
                    model

                Just p ->
                    let
                        newGroups =
                            List.filter (\x -> not (x.id == p)) model.groups

                        newNodes =
                            List.map (\x -> { x | group = Set.remove p x.group }) model.nodes
                    in
                        { model | groups = newGroups, nodes = newNodes }
    in
        newModel


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


isIdPresentInList : Identifier -> List Identifier -> Bool
isIdPresentInList id list =
    case list of
        x :: xs ->
            case x == id of
                True ->
                    True

                False ->
                    isIdPresentInList id xs

        [] ->
            False


isEdgePresent : Edge -> List Edge -> Bool
isEdgePresent e list =
    case list of
        [] ->
            False

        x :: xs ->
            case Link.isEqual x e of
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


nodeListSameParent_ : List Node -> Maybe Identifier -> Bool -> ( Bool, Maybe Identifier )
nodeListSameParent_ list m_p b =
    case list of
        [] ->
            ( b, m_p )

        x :: xs ->
            let
                res =
                    case m_p == x.parent of
                        False ->
                            ( False, m_p )

                        True ->
                            nodeListSameParent_ xs m_p True
            in
                res


nodeListSameParent : List Node -> ( Bool, Maybe Identifier )
nodeListSameParent list =
    case list of
        [] ->
            ( False, Nothing )

        x :: xs ->
            nodeListSameParent_ xs x.parent True
