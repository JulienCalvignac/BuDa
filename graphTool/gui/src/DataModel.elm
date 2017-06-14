module DataModel
    exposing
        ( DataEdge
        , DataModel
        , DataNode
        , Edge
        , Identifier
        , MetaModel
        , Model
        , Node
        , addNewNodeToModel
        , dataModelToModel
        , defaultModel
        , getEdgeFromId
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


type alias Identifier =
    Int


type alias Node =
    { id : Identifier, name : String, parent : Maybe Identifier }


type alias Edge =
    { id : Identifier, source : Identifier, target : Identifier }


type alias Model =
    { nodes : List Node
    , edges : List Edge
    , curNodeId : Identifier
    }


type alias MetaModel =
    { filename : String
    , model : Model
    }


type alias DataNode =
    { data : Node }


type alias DataEdge =
    { data : Edge }


type alias DataModel =
    { nodes : List DataNode
    , edges : List DataEdge
    }


defaultModel : Model
defaultModel =
    { nodes = []
    , edges = []
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


dataModelToModel : DataModel -> Model -> Model
dataModelToModel dm model =
    let
        ln =
            List.map dataNodeToNode dm.nodes

        le =
            List.map dataEdgeToEdge dm.edges

        newId =
            case
                List.maximum [ maximumNodeId ln, maximumEdgeId le ]
            of
                Just m ->
                    m

                Nothing ->
                    0
    in
        { nodes = ln
        , edges = le
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


makeNewNode : String -> String -> Model -> ( Node, Model )
makeNewNode name pname model =
    let
        m1 =
            getNodeIdentifier model

        pId =
            getNodeIdFromName pname m1.nodes

        newNode =
            { id = m1.curNodeId, name = name, parent = pId }
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


isEdgePresent : Edge -> List Edge -> Bool
isEdgePresent n list =
    case list of
        x :: xs ->
            case (x.source == n.source && x.target == n.target) of
                True ->
                    True

                False ->
                    isEdgePresent n xs

        [] ->
            False


anyEdgeDoublon : List Edge -> Bool
anyEdgeDoublon list =
    case list of
        [] ->
            False

        x :: xs ->
            isEdgePresent { id = 0, source = x.source, target = x.target } xs
                || isEdgePresent { id = 0, source = x.target, target = x.source } xs
