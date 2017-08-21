module ModelActions
    exposing
        ( createLink
        , createNode
        , deleteEdge
        , deleteNode
        , renameNode
        , updateProperty
        , exportLink
        , updateSelectedFlux
        , createParameter
        , deleteParameter
        , updateAttribute
        )

import Identifier exposing (Identifier)
import Node exposing (Node)
import Link exposing (Edge)
import DataModel
import Model
import ModelManagement
import LinkParameters
import Set exposing (Set)
import LinkParametersActions
import LinkParameters


{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

createLink

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
--}
{--
  createAtomicEdge_ :
  Creation lien unique src -> target
--}


createAtomicEdge_ : Identifier -> Identifier -> Model.Model -> Model.Model
createAtomicEdge_ src dest model =
    let
        edge =
            --{ id = 0, source = src, target = dest }
            (Link.link src dest)

        dataModelNewId =
            case (DataModel.isEdgePresent edge model.dataModel.edges) of
                True ->
                    model.dataModel

                False ->
                    let
                        dm1 =
                            DataModel.getNodeIdentifier model.dataModel

                        newEdges =
                            { edge | id = dm1.curNodeId } :: dm1.edges

                        dm11 =
                            { dm1 | edges = newEdges }
                    in
                        dm11
    in
        { model | dataModel = dataModelNewId }


createAtomicDoubleEdge_ : Identifier -> Identifier -> Model.Model -> Model.Model
createAtomicDoubleEdge_ src dest model =
    let
        m1 =
            createAtomicEdge_ src dest model

        m2 =
            -- createAtomicEdge_ dest src m1
            m1
    in
        m2


createAtomicEdgeForList_ : List Node -> Identifier -> Model.Model -> Model.Model
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
  createLink :
    asc ( src ) = [x1, x2, x3, ..., xn, Pcommun]
    asc ( target ) = [ y1, y2, .. , ym, Pcommun]

    avec PCommun peut valoir Nothing

    links = [ (x1,y1), (x1,y2), .., (x1,ym), (x2,y1), .., (x2,ym), .., (xn,x1), ..,(xn,ym)]
    On trouve m * n liens
--}


createLink : Identifier -> Identifier -> Model.Model -> Model.Model
createLink s t model =
    let
        ns =
            (DataModel.getNodeFromId s model.dataModel.nodes)

        nt =
            (DataModel.getNodeFromId t model.dataModel.nodes)

        newModel =
            case ( ns, nt ) of
                ( Just ns1, Just nt1 ) ->
                    createLink_ ns1 nt1 model

                ( _, _ ) ->
                    model
    in
        newModel


createLink_ : Node -> Node -> Model.Model -> Model.Model
createLink_ ns1 nt1 model =
    let
        commonParent =
            ModelManagement.findCommonParent model.dataModel.nodes ns1 nt1

        ldt1 =
            (ModelManagement.getAscendants model.dataModel.nodes nt1 commonParent)

        lds1 =
            (ModelManagement.getAscendants model.dataModel.nodes ns1 commonParent)

        m2 =
            createLinkEdgeForLists_ lds1 ldt1 model
    in
        m2


createLinkEdgeForLists_ : List Node -> List Node -> Model.Model -> Model.Model
createLinkEdgeForLists_ ls lt model =
    case ls of
        [] ->
            model

        x :: xs ->
            createLinkEdgeForLists_ xs lt (createAtomicEdgeForList_ lt x.id model)



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

createNode :
creation node et ajout a la liste des nodes dans model.dataModel

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
--}


createNode : Model.Model -> Model.Model
createNode model =
    let
        newName =
            model.input

        -- on prend le parent de nodeViewId
        useParent =
            case model.nodeViewId of
                Nothing ->
                    Nothing

                Just idx ->
                    DataModel.getParentFromNodeId model.nodeViewId model.dataModel.nodes

        -- on corrige le bug de la selection renvoyee par js
        newParent =
            case List.length model.selection > 1 of
                True ->
                    useParent

                False ->
                    case model.selection of
                        x :: xs ->
                            Just x

                        [] ->
                            useParent

        newDataModel =
            DataModel.getNodeIdentifier model.dataModel

        newId =
            newDataModel.curNodeId

        n =
            (Node.node newId newName newParent)

        newNodes =
            n :: newDataModel.nodes

        newDataModel1 =
            { newDataModel | nodes = newNodes }
    in
        { model | dataModel = newDataModel1 }



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


deleteEdge : Identifier -> Model.Model -> Model.Model
deleteEdge id model =
    let
        -- recherche edge associé a id
        edge =
            DataModel.getEdgeFromId id model.dataModel.edges

        m1 =
            case edge of
                Nothing ->
                    model

                Just edge1 ->
                    let
                        -- recherche noeud source
                        maybe_nsrc =
                            DataModel.getNodeFromId edge1.source model.dataModel.nodes

                        -- recherche noeud target
                        maybe_ntarget =
                            DataModel.getNodeFromId edge1.target model.dataModel.nodes

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


deleteEdge_ : Node -> Node -> Model.Model -> Model.Model
deleteEdge_ n ext model =
    let
        m1 =
            deleteEdgeDown n ext model

        m2 =
            deleteEdgeUp n ext m1

        -- m2 =
        --     deleteEdgeUp n ext model
    in
        m2


deleteEdgeDown : Node -> Node -> Model.Model -> Model.Model
deleteEdgeDown n m model =
    let
        model_dataModel =
            model.dataModel

        n_descendants =
            ModelManagement.getDescendantsFromN model_dataModel.nodes n

        m_descendants =
            ModelManagement.getDescendantsFromN model_dataModel.nodes m

        m1 =
            delEdgeDownForLists_ n_descendants m_descendants model
    in
        m1


delEdgeDownForLists_ : List Node -> List Node -> Model.Model -> Model.Model
delEdgeDownForLists_ lx ly model =
    case lx of
        [] ->
            model

        x :: xs ->
            delEdgeDownForLists_ xs ly (delEdgeDownForList_ x ly model)


delEdgeDownForList_ : Node -> List Node -> Model.Model -> Model.Model
delEdgeDownForList_ n list model =
    case list of
        [] ->
            model

        x :: xs ->
            delEdgeDownForList_ n xs (delEdgeFromModel_ n x model)


delEdgeFromModel_ : Node -> Node -> Model.Model -> Model.Model
delEdgeFromModel_ n m model =
    let
        data_model =
            model.dataModel

        newEdges =
            delEdge
                --{ id = 0, source = n.id, target = m.id }
                (Link.link n.id m.id)
                data_model.edges

        new_data_model =
            { data_model | edges = newEdges }

        m1 =
            { model | dataModel = new_data_model }
    in
        m1


delEdge : Edge -> List Edge -> List Edge
delEdge edge list =
    List.filter (\x -> not ((x.source == edge.source && x.target == edge.target) || (x.target == edge.source && x.source == edge.target))) list


delJustEdge : Edge -> Model.Model -> Model.Model
delJustEdge edge model =
    let
        z =
            Debug.log "delJustEdge" edge

        newEdges =
            (delEdge edge model.dataModel.edges)

        datamodel =
            model.dataModel

        newDataModel =
            { datamodel | edges = newEdges }
    in
        { model | dataModel = newDataModel }



{--
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


--}


deleteAscN : Node -> List Node -> Model.Model -> Model.Model
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


deleteAsc : List Node -> List Node -> Model.Model -> Model.Model
deleteAsc asc_n asc_m model =
    case asc_n of
        [] ->
            model

        x :: xs ->
            deleteAsc xs asc_m (deleteAscN x asc_m model)


deleteEdgeWithAsc : Node -> Node -> Model.Model -> Model.Model
deleteEdgeWithAsc n m model =
    let
        commonParent =
            ModelManagement.findCommonParent model.dataModel.nodes n m

        asc_n =
            ModelManagement.getAscendants model.dataModel.nodes n commonParent

        asc_m =
            ModelManagement.getAscendants model.dataModel.nodes m commonParent

        z =
            Debug.log "asc_n" asc_n
    in
        deleteAsc asc_n asc_m model


canDelete : Node -> Node -> Model.Model -> Bool
canDelete n m model =
    let
        childs_n =
            DataModel.childs n model.dataModel.nodes

        childs_plus_n =
            n :: childs_n

        childs_m =
            DataModel.childs m model.dataModel.nodes

        childs_plus_m =
            m :: childs_m

        b1 =
            DataModel.anyLinks childs_plus_m childs_n model.dataModel.edges

        b2 =
            DataModel.anyLinks childs_plus_n childs_m model.dataModel.edges

        b =
            not (b1 || b2)

        -- zb1 =
        --     Debug.log "anyLinks" ( childs_plus_m, childs_n )
        --
        -- zb2 =
        --     Debug.log "anyLinks" ( childs_plus_n, childs_m )
        z =
            Debug.log "canDelete" ( n.name, m.name, b )
    in
        b



{--
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////




--}


deleteEdgeUp : Node -> Node -> Model.Model -> Model.Model
deleteEdgeUp n m model =
    let
        m0 =
            delJustEdge (DataModel.edgeST n m) model

        m2 =
            deleteEdgeWithAsc n m m0
    in
        m2


linkExistanceOne_ : Node -> Model.Model -> Node -> Bool
linkExistanceOne_ ext model n =
    let
        b1 =
            DataModel.isEdgePresent
                --{ id = 0, source = n.id, target = ext.id }
                (Link.link n.id ext.id)
                model.dataModel.edges

        -- z =
        --     Debug.log "linkExistanceOne_" b1
    in
        b1


linkExistance_ : List Node -> Node -> Model.Model -> Bool
linkExistance_ children ext model =
    let
        b =
            List.any (linkExistanceOne_ ext model) children

        -- z =
        --     Debug.log "linkExistance_" b
    in
        b



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


deleteNode : Identifier -> Model.Model -> Model.Model
deleteNode id model =
    let
        maybe_n =
            DataModel.getNodeFromId id model.dataModel.nodes

        m1 =
            case maybe_n of
                Just n ->
                    let
                        descendants =
                            ModelManagement.getDescendantsFromN model.dataModel.nodes n

                        m2 =
                            deleteEdgesAndNodeFromListNode_ descendants model
                    in
                        m2

                Nothing ->
                    model
    in
        m1


deleteEdgesAndNodeFromListNode_ : List Node -> Model.Model -> Model.Model
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


deleteEdgesAndNode_ : Node -> Model.Model -> Model.Model
deleteEdgesAndNode_ n model =
    let
        edgesToDelete =
            List.filter (\x -> ((x.source == n.id) || (x.target == n.id))) model.dataModel.edges

        m1 =
            deleteEdgeFromList_ edgesToDelete model

        newNodes =
            List.filter (\x -> not (n.id == x.id)) m1.dataModel.nodes

        m1_dataModel =
            m1.dataModel

        newDataModel =
            { m1_dataModel | nodes = newNodes }

        m2 =
            { m1 | dataModel = newDataModel }
    in
        m2


deleteEdgeFromList_ : List Edge -> Model.Model -> Model.Model
deleteEdgeFromList_ list model =
    case list of
        x :: xs ->
            deleteEdge x.id model

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


renameNode : Model.Model -> Model.Model
renameNode model =
    let
        newName =
            model.input

        nId =
            case model.selection of
                x :: xs ->
                    Just x

                [] ->
                    Nothing

        newNodes =
            (renameNodeInList_ newName nId model.dataModel.nodes)

        nd1 =
            model.dataModel

        newDataModel =
            { nd1 | nodes = newNodes }
    in
        { model | dataModel = newDataModel }


updateProperty : Edge -> String -> Model.Model -> Model.Model
updateProperty edge s model =
    let
        maybe_propId =
            LinkParameters.getPropertyIdFromName s model.dataModel.parameters

        z =
            Debug.log "updateProperty" ( maybe_propId, s )

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


updateSelectedFlux : String -> Model.Model -> Model.Model
updateSelectedFlux s model =
    let
        maybe_propId =
            LinkParameters.getPropertyIdFromName s model.dataModel.parameters

        newExportFlux =
            case maybe_propId of
                Nothing ->
                    model.exportFlux

                Just propId ->
                    Link.changeActiveProperty propId model.exportFlux

        z =
            Debug.log "newExportFlux" newExportFlux
    in
        { model | exportFlux = newExportFlux }


isIn_ : List Identifier -> Set Identifier -> Bool
isIn_ list set =
    case list of
        [] ->
            True

        x :: xs ->
            (Set.member x set) && (isIn_ xs set)


filterLinks_ : Set Identifier -> List Edge -> List Edge
filterLinks_ set list =
    -- on garde les edge tels que edge.parameters contient set
    List.filter (\x -> (isIn_ (Set.toList set) x.parameters)) list


exportLink : Model.Model -> Model.Model
exportLink model =
    let
        m1 =
            Model.defaultModel

        newEdges =
            -- [ { id = 11, source = 8, target = 10, parameters = Set.fromList [ 0, 1 ] } ]
            filterLinks_ model.exportFlux model.dataModel.edges

        dataModel =
            model.dataModel

        newDataModel =
            { dataModel | edges = newEdges }
    in
        { m1 | dataModel = newDataModel }


createParameter : Model.Model -> Model.Model
createParameter model =
    let
        newDataModel =
            (DataModel.createProperty model.input model.dataModel)
    in
        { model | dataModel = newDataModel }


desactivateParameterOnAllLinks : Identifier -> Model.Model -> Model.Model
desactivateParameterOnAllLinks idx model =
    let
        dataModel =
            model.dataModel

        newEdges =
            List.map (\x -> Link.unActivate idx x) model.dataModel.edges

        z =
            Debug.log "desactivateParameterOnAllLinks" newEdges

        newDataModel =
            { dataModel | edges = newEdges }
    in
        { model | dataModel = newDataModel }


deleteParameter : Model.Model -> Model.Model
deleteParameter model =
    let
        maybe_parameter =
            (LinkParameters.getPropertyIdFromName model.input model.dataModel.parameters)

        m1 =
            case maybe_parameter of
                Nothing ->
                    let
                        z =
                            Debug.log "Cannot Find Id for Parameter" model.input
                    in
                        model

                Just p ->
                    let
                        m2 =
                            desactivateParameterOnAllLinks p model

                        newDataModel =
                            (DataModel.deleteProperty m2.input m2.dataModel)
                    in
                        { m2 | dataModel = newDataModel }
    in
        m1


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


updateDataModelAttribute_ : Maybe Identifier -> String -> DataModel.Model -> DataModel.Model
updateDataModelAttribute_ m_id s dataModel =
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


updateAttribute : Model.Model -> String -> Model.Model
updateAttribute model s =
    let
        m_id =
            case model.selection of
                x :: xs ->
                    Just x

                [] ->
                    Nothing

        newDatamodel =
            updateDataModelAttribute_ m_id s model.dataModel
    in
        { model | dataModel = newDatamodel }
