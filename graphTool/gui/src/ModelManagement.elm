module ModelManagement
    exposing
        ( subModelFromId
        , subModelFromName
        , subModelFromNode
        , listNodeToPBS
        , listNodeToPBSFromNodeName
        , listNodeToPBSFromNodeId
        , listNodeToPBSFromNode
        , getAscendants
        , getChildren
        , getDescendantsFromN
        )

import DataModel


filterSameParent : List DataModel.Node -> DataModel.Node -> List DataModel.Node
filterSameParent list n =
    List.filter (\x -> x.parent == n.parent) list


filterParentIsN : List DataModel.Node -> DataModel.Node -> List DataModel.Node
filterParentIsN list n =
    List.filter (\x -> x.parent == Just n.id) list


filterEdgeN : List DataModel.Edge -> DataModel.Node -> List DataModel.Edge
filterEdgeN list n =
    List.filter (\x -> x.source == n.id || x.target == n.id) list


subModelFromNode : DataModel.Model -> DataModel.Node -> DataModel.Model
subModelFromNode model n =
    { nodes = List.append (filterSameParent model.nodes n) (filterParentIsN model.nodes n)
    , edges = filterEdgeN model.edges n
    , curNodeId = 0
    }


subModelFromId : DataModel.Model -> DataModel.Identifier -> DataModel.Model
subModelFromId model id =
    case DataModel.getNodeFromId id model.nodes of
        Nothing ->
            DataModel.defaultModel

        Just n ->
            subModelFromNode model n


subModelFromName : DataModel.Model -> String -> DataModel.Model
subModelFromName model s =
    case DataModel.getNodeFromName s model.nodes of
        Nothing ->
            DataModel.defaultModel

        Just n ->
            subModelFromNode model n


parentFromNode : List DataModel.Node -> DataModel.Node -> Maybe DataModel.Node
parentFromNode list n =
    case n.parent of
        Nothing ->
            Nothing

        Just id ->
            DataModel.getNodeFromId id list



{--construction de la liste des parents de n --}


getAllParentsFromNode : List DataModel.Node -> DataModel.Node -> List DataModel.Node
getAllParentsFromNode list n =
    getAllParentsFromNode_ list [] n


getAllParentsFromNode_ : List DataModel.Node -> List DataModel.Node -> DataModel.Node -> List DataModel.Node
getAllParentsFromNode_ list tmp n =
    case DataModel.nodeHasParent n of
        False ->
            tmp

        True ->
            case parentFromNode list n of
                Nothing ->
                    tmp

                Just p ->
                    getAllParentsFromNode_ list (p :: tmp) p


extractAndstopToP_ : List a -> List a -> a -> List a
extractAndstopToP_ list tmp p =
    case list of
        x :: xs ->
            case x == p of
                True ->
                    tmp

                False ->
                    extractAndstopToP_ xs tmp p

        [] ->
            tmp


extractAndstopToP : List a -> a -> List a
extractAndstopToP list p =
    extractAndstopToP_ list [] p


getParentsFromNStopToP : List DataModel.Node -> DataModel.Node -> DataModel.Node -> List DataModel.Node
getParentsFromNStopToP list n p =
    let
        l1 =
            getAllParentsFromNode list n

        l2 =
            extractAndstopToP l1 p
    in
        l2



{--
listNodeToPBS :
    construction du model PBS . Les liens sont les relations parent -> enfant
--}


nodesToPbsLnk_ : List DataModel.Node -> List DataModel.Node -> DataModel.Model -> List DataModel.Edge -> ( List DataModel.Edge, DataModel.Model )
nodesToPbsLnk_ list treatedList model tmp =
    case treatedList of
        x :: xs ->
            case x.parent of
                Nothing ->
                    nodesToPbsLnk_ list xs model tmp

                Just pId ->
                    case DataModel.isNodeIdPresent pId list of
                        False ->
                            nodesToPbsLnk_ list xs model tmp

                        True ->
                            let
                                newModel =
                                    DataModel.getNodeIdentifier model

                                edge =
                                    { id = newModel.curNodeId, source = pId, target = x.id }

                                tp1 =
                                    edge :: tmp

                                z =
                                    -- Debug.log "new Edge"
                                    tp1
                            in
                                nodesToPbsLnk_ list xs newModel tp1

        [] ->
            ( tmp, model )


nodesToPbsLnk : List DataModel.Node -> DataModel.Model -> ( List DataModel.Edge, DataModel.Model )
nodesToPbsLnk list model =
    let
        ( e, m ) =
            Debug.log "nodesToPbsLnk" (nodesToPbsLnk_ list list model [])
    in
        ( e, m )


listNtoPBS : List DataModel.Node -> List DataModel.Node
listNtoPBS list =
    List.map (\n -> { n | parent = Nothing }) list


listNodeToPBS_ : List DataModel.Node -> DataModel.Model -> DataModel.Model
listNodeToPBS_ list model =
    let
        newNodes =
            listNtoPBS list

        newModel =
            { model | nodes = newNodes, edges = [], curNodeId = (DataModel.maximumNodeId newNodes) }

        ( newEdges, m2 ) =
            nodesToPbsLnk list newModel
    in
        { m2 | nodes = newNodes, edges = newEdges }


listNodeToPBS : List DataModel.Node -> DataModel.Model
listNodeToPBS list =
    listNodeToPBS_ list DataModel.defaultModel



{--
listNodeToPBSFromNode : List DataModel.Node -> DataModel.Node -> DataModel.Model
--}


listNodeToPBSFromNodeId : List DataModel.Node -> DataModel.Identifier -> DataModel.Model
listNodeToPBSFromNodeId list id =
    case (DataModel.getNodeFromId id list) of
        Nothing ->
            DataModel.defaultModel

        Just n ->
            listNodeToPBSFromNode list n


listNodeToPBSFromNodeName : List DataModel.Node -> String -> DataModel.Model
listNodeToPBSFromNodeName list s =
    case (DataModel.getNodeFromName s list) of
        Nothing ->
            DataModel.defaultModel

        Just n ->
            listNodeToPBSFromNode list n


listNodeToPBSFromNode : List DataModel.Node -> DataModel.Node -> DataModel.Model
listNodeToPBSFromNode list n =
    let
        n1 =
            { n | parent = Nothing }

        newList =
            -- Debug.log "getDescendantsFromN"
            (getDescendantsFromN list n1)

        newModel =
            listNodeToPBS newList
    in
        newModel


getChildren : List DataModel.Node -> DataModel.Node -> List DataModel.Node
getChildren list n =
    -- Debug.log "getChildren"
    (List.filter (\x -> (x.parent == Just n.id)) list)


getDescendants : List DataModel.Node -> List DataModel.Node -> List DataModel.Node
getDescendants list l1 =
    case l1 of
        [] ->
            []

        x :: xs ->
            -- Debug.log "List.append"
            (List.append (getDescendantsFromN list x) (getDescendants list xs))


getDescendantsFromN : List DataModel.Node -> DataModel.Node -> List DataModel.Node
getDescendantsFromN list n =
    n :: (getDescendants list (getChildren list n))


getAscendants_ : List DataModel.Node -> DataModel.Node -> List DataModel.Node -> List DataModel.Node
getAscendants_ list n tmp =
    case n.parent of
        Nothing ->
            (n :: tmp)

        Just pId ->
            let
                maybeN =
                    (DataModel.getNodeFromId pId list)

                tmp1 =
                    case maybeN of
                        Nothing ->
                            (n :: tmp)

                        Just p ->
                            getAscendants_ list p (n :: tmp)
            in
                tmp1


getAscendants : List DataModel.Node -> DataModel.Node -> List DataModel.Node
getAscendants list n =
    getAscendants_ list n []
