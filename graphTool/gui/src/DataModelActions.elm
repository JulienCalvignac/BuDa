module DataModelActions
    exposing
        ( createNode
        , createLink
        , createParameter
        , createGroup
        , deleteEdge
        , deleteNode
        , deleteParameter
        , deleteGroup
        , renameNode
        , updateAttribute
        , lowestLevelEdges
        , updateProperty
        , groupNodes
        , updateNodeGroupProperty
        , highLightGroup
        , selectedParameters
        )

import DataModel exposing (Model, isNodeIdPresent)
import Identifier exposing (Identifier)
import Node exposing (Node)
import Link exposing (Edge)
import ModelManagement
import LinkParametersActions
import LinkParameters
import Groups
import Set
import GroupsActions


{--
  createNode :
--}


createNode : String -> Maybe Identifier -> Model -> Model
createNode s m_parent model =
    let
        newDataModel =
            DataModel.getNodeIdentifier model

        newId =
            newDataModel.curNodeId

        n =
            (Node.node newId s m_parent)

        newNodes =
            n :: newDataModel.nodes
    in
        { newDataModel | nodes = newNodes }



{--
  createLink :
    asc ( src ) = [x1, x2, x3, ..., xn, Pcommun]
    asc ( target ) = [ y1, y2, .. , ym, Pcommun]

    avec PCommun peut valoir Nothing

    links = [ (x1,y1), (x1,y2), .., (x1,ym), (x2,y1), .., (x2,ym), .., (xn,x1), ..,(xn,ym)]
    On trouve m * n liens
--}


createLink : Identifier -> Identifier -> Model -> Model
createLink s t model =
    let
        ns =
            (DataModel.getNodeFromId s model.nodes)

        nt =
            (DataModel.getNodeFromId t model.nodes)

        newModel =
            case ( ns, nt ) of
                ( Just ns1, Just nt1 ) ->
                    createLink_ ns1 nt1 model

                ( _, _ ) ->
                    model
    in
        newModel


createLink_ : Node -> Node -> Model -> Model
createLink_ ns1 nt1 model =
    let
        commonParent =
            ModelManagement.findCommonParent model.nodes ns1 nt1

        ldt1 =
            (ModelManagement.getAscendants model.nodes nt1 commonParent)

        lds1 =
            (ModelManagement.getAscendants model.nodes ns1 commonParent)

        m2 =
            createLinkEdgeForLists_ lds1 ldt1 model
    in
        m2


createLinkEdgeForLists_ : List Node -> List Node -> Model -> Model
createLinkEdgeForLists_ ls lt model =
    case ls of
        [] ->
            model

        x :: xs ->
            createLinkEdgeForLists_ xs lt (createAtomicEdgeForList_ lt x.id model)


createAtomicEdge_ : Identifier -> Identifier -> Model -> Model
createAtomicEdge_ src dest model =
    let
        edge =
            --{ id = 0, source = src, target = dest }
            (Link.link src dest)

        dataModelNewId =
            case (DataModel.isEdgePresent edge model.edges) of
                True ->
                    model

                False ->
                    let
                        dm1 =
                            DataModel.getNodeIdentifier model

                        newEdges =
                            { edge | id = dm1.curNodeId } :: dm1.edges

                        dm11 =
                            { dm1 | edges = newEdges }
                    in
                        dm11
    in
        dataModelNewId


createAtomicDoubleEdge_ : Identifier -> Identifier -> Model -> Model
createAtomicDoubleEdge_ src dest model =
    let
        m1 =
            createAtomicEdge_ src dest model

        m2 =
            -- createAtomicEdge_ dest src m1
            m1
    in
        m2


createAtomicEdgeForList_ : List Node -> Identifier -> Model -> Model
createAtomicEdgeForList_ list dest model =
    case list of
        x :: xs ->
            let
                m1 =
                    createAtomicDoubleEdge_ x.id dest model
            in
                createAtomicEdgeForList_ xs dest m1

        [] ->
            model



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

renameNode:
rename node select dans le Model.dataModel

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


renameNode_ : Node -> String -> Node
renameNode_ n s =
    { n | name = s }


process_ : String -> Maybe Identifier -> Node -> Node
process_ s id n =
    let
        n1 =
            case id of
                Nothing ->
                    n

                Just i ->
                    case n.id == i of
                        True ->
                            { n | name = s }

                        False ->
                            n
    in
        n1


renameNodeInList_ : String -> Maybe Identifier -> List Node -> List Node
renameNodeInList_ s id list =
    List.map (process_ s id) list


renameNode : String -> Maybe Identifier -> Model -> Model
renameNode s nId model =
    let
        newNodes =
            (renameNodeInList_ s nId model.nodes)
    in
        { model | nodes = newNodes }



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

deleteEdge : id model
id : identifier du edge a supprimer


deletEdge: src -> dest
delteEdge : dest -> src

deleteDown
deleteAllEdges src (descendants dest)
on delete dans les 2 sens src -> d[i], et d[i] -> src


deleteUp
deleteAllEdges src (ascendants dest) si pas de lien (asc enfant) et src
on delete dans les 2 sens src -> a[i], et a[i] -> src


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
--}


deleteEdge : Identifier -> Model -> Model
deleteEdge id model =
    let
        -- recherche edge associé a id
        edge =
            DataModel.getEdgeFromId id model.edges

        m1 =
            case edge of
                Nothing ->
                    model

                Just edge1 ->
                    let
                        -- recherche noeud source
                        maybe_nsrc =
                            DataModel.getNodeFromId edge1.source model.nodes

                        -- recherche noeud target
                        maybe_ntarget =
                            DataModel.getNodeFromId edge1.target model.nodes

                        -- unActivate all parameters for edge
                        m20 =
                            LinkParametersActions.unActivateAllParameters edge1 model

                        m2 =
                            case ( maybe_nsrc, maybe_ntarget ) of
                                ( Just nsrc, Just ntarget ) ->
                                    let
                                        m3 =
                                            deleteEdge_ nsrc ntarget m20

                                        -- m4 =
                                        --     deleteEdge_ ntarget nsrc m3
                                    in
                                        m3

                                ( _, _ ) ->
                                    m20
                    in
                        m2
    in
        m1


deleteEdge_ : Node -> Node -> Model -> Model
deleteEdge_ n ext model =
    let
        m1 =
            deleteEdgeDown n ext model

        m2 =
            deleteEdgeUp n ext m1
    in
        m2


deleteEdgeDown : Node -> Node -> Model -> Model
deleteEdgeDown n m model =
    let
        n_descendants =
            ModelManagement.getDescendantsFromN model.nodes n

        m_descendants =
            ModelManagement.getDescendantsFromN model.nodes m

        m1 =
            delEdgeDownForLists_ n_descendants m_descendants model
    in
        m1


delEdgeDownForLists_ : List Node -> List Node -> Model -> Model
delEdgeDownForLists_ lx ly model =
    case lx of
        [] ->
            model

        x :: xs ->
            delEdgeDownForLists_ xs ly (delEdgeDownForList_ x ly model)


delEdgeDownForList_ : Node -> List Node -> Model -> Model
delEdgeDownForList_ n list model =
    case list of
        [] ->
            model

        x :: xs ->
            delEdgeDownForList_ n xs (delEdgeFromModel_ n x model)


delEdgeFromModel_ : Node -> Node -> Model -> Model
delEdgeFromModel_ n m model =
    let
        newEdges =
            delEdge
                --{ id = 0, source = n.id, target = m.id }
                (Link.link n.id m.id)
                model.edges
    in
        { model | edges = newEdges }


delEdge : Edge -> List Edge -> List Edge
delEdge edge list =
    List.filter (\x -> not ((x.source == edge.source && x.target == edge.target) || (x.target == edge.source && x.source == edge.target))) list



{--
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


--}


deleteAscN : Node -> List Node -> Model -> Model
deleteAscN n asc_m model =
    case asc_m of
        [] ->
            model

        x :: xs ->
            let
                m1 =
                    case canDelete n x model of
                        True ->
                            delJustEdge (DataModel.edgeST n x) model

                        False ->
                            model
            in
                deleteAscN n xs m1


delJustEdge : Edge -> Model -> Model
delJustEdge edge model =
    let
        newEdges =
            (delEdge edge model.edges)
    in
        { model | edges = newEdges }


deleteAsc : List Node -> List Node -> Model -> Model
deleteAsc asc_n asc_m model =
    case asc_n of
        [] ->
            model

        x :: xs ->
            deleteAsc xs asc_m (deleteAscN x asc_m model)


deleteEdgeWithAsc : Node -> Node -> Model -> Model
deleteEdgeWithAsc n m model =
    let
        commonParent =
            ModelManagement.findCommonParent model.nodes n m

        asc_n =
            ModelManagement.getAscendants model.nodes n commonParent

        asc_m =
            ModelManagement.getAscendants model.nodes m commonParent
    in
        deleteAsc asc_n asc_m model


canDelete : Node -> Node -> Model -> Bool
canDelete n m model =
    let
        childs_n =
            DataModel.childs n model.nodes

        childs_plus_n =
            n :: childs_n

        childs_m =
            DataModel.childs m model.nodes

        childs_plus_m =
            m :: childs_m

        b1 =
            DataModel.anyLinks childs_plus_m childs_n model.edges

        b2 =
            DataModel.anyLinks childs_plus_n childs_m model.edges

        b =
            not (b1 || b2)
    in
        b



{--
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////




--}


deleteEdgeUp : Node -> Node -> Model -> Model
deleteEdgeUp n m model =
    let
        m0 =
            delJustEdge (DataModel.edgeST n m) model

        m2 =
            deleteEdgeWithAsc n m m0
    in
        m2



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

deleteNode :
rechercher tous les descendants de n dans la liste des nodes
pour chaque element, appeler deleteNode_

deleteNode_ :
pour tous les liens / source == n ou dest == n, appeler deleteEdge
supprimer n de la liste

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
--}


deleteNode : Identifier -> Model -> Model
deleteNode id model =
    let
        maybe_n =
            DataModel.getNodeFromId id model.nodes

        m1 =
            case maybe_n of
                Just n ->
                    let
                        descendants =
                            ModelManagement.getDescendantsFromN model.nodes n

                        m2 =
                            deleteEdgesAndNodeFromListNode_ descendants model
                    in
                        m2

                Nothing ->
                    model
    in
        m1


deleteEdgesAndNodeFromListNode_ : List Node -> Model -> Model
deleteEdgesAndNodeFromListNode_ list model =
    case list of
        x :: xs ->
            let
                m1 =
                    deleteEdgesAndNode_ x model
            in
                deleteEdgesAndNodeFromListNode_ xs m1

        [] ->
            model


deleteEdgesAndNode_ : Node -> Model -> Model
deleteEdgesAndNode_ n model =
    let
        edgesToDelete =
            List.filter (\x -> ((x.source == n.id) || (x.target == n.id))) model.edges

        m1 =
            deleteEdgeFromList_ edgesToDelete model

        newNodes =
            List.filter (\x -> not (n.id == x.id)) m1.nodes

        m2 =
            { m1 | nodes = newNodes }
    in
        m2


deleteEdgeFromList_ : List Edge -> Model -> Model
deleteEdgeFromList_ list model =
    case list of
        x :: xs ->
            deleteEdge x.id model

        [] ->
            model



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

lowestLevelEdges :

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
--}


isLowestLevel : Edge -> Model -> Bool
isLowestLevel edge model =
    let
        m_n =
            DataModel.getNodeFromId edge.source model.nodes

        m_p =
            DataModel.getNodeFromId edge.target model.nodes

        b =
            case ( m_n, m_p ) of
                ( Just n, Just p ) ->
                    canDelete n p model

                ( _, _ ) ->
                    False
    in
        b


lowestLevelEdges : Model -> List Edge
lowestLevelEdges model =
    List.filter (\x -> isLowestLevel x model) model.edges



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

updateAttribute :

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
--}


fnode_ : Identifier -> String -> Node -> Node
fnode_ id s n =
    let
        newNode =
            case n.id == id of
                True ->
                    case String.length s of
                        0 ->
                            { n | attribut = Nothing }

                        _ ->
                            { n | attribut = Just s }

                False ->
                    n
    in
        newNode


fedge_ : Identifier -> String -> Edge -> Edge
fedge_ id s e =
    let
        newEdge =
            case e.id == id of
                True ->
                    case String.length s of
                        0 ->
                            { e | attribut = Nothing }

                        _ ->
                            { e | attribut = Just s }

                False ->
                    e
    in
        newEdge


updateAttribute : Maybe Identifier -> String -> Model -> Model
updateAttribute m_id s dataModel =
    case m_id of
        Nothing ->
            dataModel

        Just id ->
            let
                newNodes =
                    List.map (\x -> (fnode_ id s x)) dataModel.nodes

                newEdges =
                    List.map (\x -> fedge_ id s x) dataModel.edges
            in
                { dataModel | nodes = newNodes, edges = newEdges }



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

updateProperty :

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
--}


updateProperty : Edge -> String -> Model -> Model
updateProperty edge s model =
    let
        maybe_propId =
            LinkParameters.getPropertyIdFromName s model.parameters

        newModel =
            case maybe_propId of
                Nothing ->
                    model

                Just propId ->
                    case Link.isActive propId edge of
                        False ->
                            LinkParametersActions.activateParameter propId edge model

                        True ->
                            LinkParametersActions.unActivateParameter propId edge model
    in
        newModel



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

createGroup:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


createGroup : String -> Model -> Model
createGroup s model =
    DataModel.createGroupProperty s model



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

deleteGroup:


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


deleteGroup : String -> Model -> Model
deleteGroup s model =
    DataModel.deleteGroupProperty s model



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

createParameter:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


createParameter : String -> Model -> Model
createParameter s model =
    DataModel.createProperty s model



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

deleteParameter:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


desactivateParameterOnAllLinks : Identifier -> Model -> Model
desactivateParameterOnAllLinks idx model =
    let
        newEdges =
            List.map (\x -> Link.unActivate idx x) model.edges
    in
        { model | edges = newEdges }


deleteParameter : String -> Model -> Model
deleteParameter s model =
    let
        maybe_parameter =
            (LinkParameters.getPropertyIdFromName s model.parameters)

        m1 =
            case maybe_parameter of
                Nothing ->
                    model

                Just p ->
                    let
                        m2 =
                            desactivateParameterOnAllLinks p model

                        newDataModel =
                            (DataModel.deleteProperty s m2)
                    in
                        newDataModel
    in
        m1



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

groupNodes:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


updateParameters_ : Edge -> Model -> Model
updateParameters_ edge model =
    -- on ajoute les parametres actifs de edge aux parametres des edges égaux du modele
    let
        newEdges =
            List.map
                (\x ->
                    case Link.isEqual x edge of
                        True ->
                            Link.updateActivePoperties edge.parameters x

                        False ->
                            x
                )
                model.edges
    in
        { model | edges = newEdges }


cloneEdge_ : Edge -> Model -> Model
cloneEdge_ edge model =
    -- si edge existe dans le modele, on concatene ses parametres avec ceux de edge
    -- sinon on construit un nouveau lien dans le modele avec les caracteristiques de edge
    -- (source, target, parameters, attribut=Nothing)
    -- cette fonction differe de createAtomicEdge_ a cause des parametres
    let
        dataModelNewId =
            case (DataModel.isEdgePresent edge model.edges) of
                True ->
                    updateParameters_ edge model

                False ->
                    let
                        dm1 =
                            DataModel.getNodeIdentifier model

                        newEdges =
                            { edge | id = dm1.curNodeId, attribut = Nothing } :: dm1.edges

                        dm11 =
                            { dm1 | edges = newEdges }
                    in
                        dm11
    in
        dataModelNewId


makeGroupNodes_ : List Node -> String -> Maybe Identifier -> Model -> Model
makeGroupNodes_ list s m_p model =
    let
        -- create un father for all nodes in list
        -- id for new father is model.curNodeId
        m1 =
            createNode s m_p model

        fatherId =
            m1.curNodeId

        -- modify father to new father for all nodes in list
        newNodes =
            List.map
                (\x ->
                    case (DataModel.isNodePresent x list) of
                        True ->
                            { x | parent = Just fatherId }

                        False ->
                            x
                )
                m1.nodes

        edges1 =
            List.filter
                (\x ->
                    (DataModel.isNodeIdPresent x.source list)
                        && not (DataModel.isNodeIdPresent x.target list)
                )
                m1.edges

        edges11 =
            List.map (\x -> { x | source = fatherId }) edges1

        edges2 =
            List.filter
                (\x ->
                    (DataModel.isNodeIdPresent x.target list)
                        && not (DataModel.isNodeIdPresent x.source list)
                )
                m1.edges

        edges21 =
            List.map (\x -> { x | target = fatherId }) edges2

        edgesTocreate =
            List.append edges11 edges21

        m2 =
            { m1 | nodes = newNodes }

        m3 =
            duplicateEdgesFromList edgesTocreate m2
    in
        m3


groupNodes : List Node -> String -> Model -> Model
groupNodes list s model =
    let
        ( condition, parent ) =
            DataModel.nodeListSameParent list

        m1 =
            case condition of
                False ->
                    model

                True ->
                    makeGroupNodes_ list s parent model
    in
        m1


duplicateEdgesFromList : List Edge -> Model -> Model
duplicateEdgesFromList list model =
    case list of
        [] ->
            model

        x :: xs ->
            let
                m1 =
                    cloneEdge_ x model
            in
                duplicateEdgesFromList xs m1


updateNodeGroupProperty : Node -> String -> Model -> Model
updateNodeGroupProperty n s model =
    let
        m_id =
            Groups.getPropertyIdFromName s model.groups

        m1 =
            case m_id of
                Nothing ->
                    model

                Just id ->
                    let
                        newModel =
                            case Node.inGroup id n of
                                False ->
                                    GroupsActions.addGroupToNode id n model

                                True ->
                                    GroupsActions.deleteGroupFromNode id n model
                    in
                        newModel
    in
        m1


highLightGroup : String -> Model -> Model
highLightGroup s model =
    let
        m_id =
            Groups.getPropertyIdFromName s model.groups

        newModel =
            case m_id of
                Nothing ->
                    model

                Just id ->
                    let
                        -- update du champ model.lightedGroup
                        newLightedGroup =
                            case model.lightedGroup == Just id of
                                True ->
                                    Nothing

                                False ->
                                    Just id

                        filterNodes =
                            List.filter
                                (\x ->
                                    case newLightedGroup of
                                        Nothing ->
                                            False

                                        Just id ->
                                            Set.member id x.group
                                )
                                model.nodes

                        newNodes =
                            List.map
                                (\x ->
                                    case newLightedGroup of
                                        Nothing ->
                                            { x | highLighted = False }

                                        Just id ->
                                            case Set.member id x.group of
                                                True ->
                                                    { x | highLighted = True }

                                                False ->
                                                    { x | highLighted = False }
                                )
                                model.nodes

                        newEdges =
                            List.map
                                (\x ->
                                    case ( DataModel.isNodeIdPresent x.source filterNodes, DataModel.isNodeIdPresent x.target filterNodes ) of
                                        ( True, True ) ->
                                            { x | highLighted = 1 }

                                        ( False, True ) ->
                                            { x | highLighted = 2 }

                                        ( True, False ) ->
                                            { x | highLighted = 2 }

                                        ( False, False ) ->
                                            { x | highLighted = 0 }
                                )
                                model.edges
                    in
                        { model
                            | nodes = newNodes
                            , edges = newEdges
                            , lightedGroup = newLightedGroup
                        }
    in
        newModel


selectedParameters : String -> Model -> Model
selectedParameters s model =
    let
        m_id =
            LinkParameters.getPropertyIdFromName s model.parameters

        newModel =
            case m_id of
                Nothing ->
                    model

                Just id ->
                    let
                        newSelectedParameters =
                            case (Set.member id model.selectedParameters) of
                                True ->
                                    Set.remove id model.selectedParameters

                                False ->
                                    Set.insert id model.selectedParameters

                        z =
                            Debug.log "selectedParameters" newSelectedParameters
                    in
                        { model
                            | selectedParameters = newSelectedParameters
                        }
    in
        newModel
