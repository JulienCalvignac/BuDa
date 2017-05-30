module ModelActions exposing (createEdge, createNode, deleteEdge, deleteNode, renameNode)

import DataModel
import Model
import ModelManagement


{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

createEdge

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
--}
{--
  createAtomicEdge_ :
  Creation lien unique src -> target
--}


createAtomicEdge_ : DataModel.Identifier -> DataModel.Identifier -> Model.Model -> Model.Model
createAtomicEdge_ src dest model =
    let
        edge =
            { id = 0, source = src, target = dest }

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


createAtomicDoubleEdge_ : DataModel.Identifier -> DataModel.Identifier -> Model.Model -> Model.Model
createAtomicDoubleEdge_ src dest model =
    let
        m1 =
            createAtomicEdge_ src dest model

        m2 =
            createAtomicEdge_ dest src m1
    in
        m2


createAtomicEdgeForList_ : List DataModel.Node -> DataModel.Identifier -> Model.Model -> Model.Model
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
  createEdge :
  Creation lien unique src -> target
  Creation lien unique target -> src
  Creation lien unique src -> ascendance target
  Creation lien unique target -> ascendance src
--}


createEdge : DataModel.Identifier -> DataModel.Identifier -> Model.Model -> Model.Model
createEdge s t model =
    let
        list =
            model.dataModel.nodes

        ns =
            (DataModel.getNodeFromId s list)

        nt =
            (DataModel.getNodeFromId t list)

        newModel =
            case ( ns, nt ) of
                ( Just ns1, Just nt1 ) ->
                    let
                        ldt1 =
                            (ModelManagement.getAscendants list nt1)

                        lds1 =
                            (ModelManagement.getAscendants list ns1)

                        m1 =
                            createAtomicEdgeForList_ lds1 nt1.id model

                        m2 =
                            createAtomicEdgeForList_ ldt1 ns1.id m1

                        z1 =
                            Debug.log "lds1" lds1

                        z2 =
                            Debug.log "ldt1" ldt1
                    in
                        m2

                ( _, _ ) ->
                    model
    in
        newModel



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

        newParent =
            case model.selection of
                x :: xs ->
                    Just x

                [] ->
                    Nothing

        newDataModel =
            DataModel.getNodeIdentifier model.dataModel

        newId =
            newDataModel.curNodeId

        n =
            { id = newId, name = newName, parent = newParent }

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


deleteEdge : DataModel.Identifier -> Model.Model -> Model.Model
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

                        model_dataModel =
                            model.dataModel

                        newModel =
                            case ( maybe_nsrc, maybe_ntarget ) of
                                ( Just nsrc, Just ntarget ) ->
                                    let
                                        src_descendants =
                                            ModelManagement.getDescendantsFromN model_dataModel.nodes nsrc

                                        target_descendants =
                                            ModelManagement.getDescendantsFromN model_dataModel.nodes ntarget

                                        target_ascendants =
                                            List.reverse (ModelManagement.getAscendants model_dataModel.nodes ntarget)

                                        src_ascendants =
                                            List.reverse (ModelManagement.getAscendants model_dataModel.nodes nsrc)

                                        z =
                                            Debug.log "target_ascendants" target_ascendants

                                        -- suppression des liens:  target ---- (descendant src)
                                        newEdges1 =
                                            delEdgeForList_ ntarget.id src_descendants model.dataModel.edges

                                        -- suppression des liens:  src ---- (descendant target)
                                        newEdges2 =
                                            delEdgeForList_ nsrc.id target_descendants newEdges1

                                        -- suppression conditionnelle des liens : src ---- a = (ascendant target)
                                        -- condition = il n'exist pas de liens src ---- a.children si a.children != target
                                        newDataModel =
                                            { model_dataModel | edges = newEdges2 }

                                        m2 =
                                            { model | dataModel = newDataModel }

                                        m3 =
                                            delEdgesAscendants_ nsrc.id target_ascendants ntarget m2

                                        m4 =
                                            delEdgesAscendants_ ntarget.id src_ascendants ntarget m3
                                    in
                                        m4

                                ( _, _ ) ->
                                    model
                    in
                        newModel
    in
        m1


linkExistanceOne_ : DataModel.Identifier -> DataModel.Node -> Model.Model -> DataModel.Node -> Bool
linkExistanceOne_ id_src target model n =
    let
        b1 =
            DataModel.isEdgePresent { id = 0, source = id_src, target = n.id } model.dataModel.edges

        z =
            Debug.log "linkExistanceOne_" b1
    in
        b1


linkExistance_ : List DataModel.Node -> DataModel.Identifier -> DataModel.Node -> Model.Model -> Bool
linkExistance_ children id_src target model =
    let
        b =
            List.any (linkExistanceOne_ id_src target model) children

        z =
            Debug.log "linkExistance_" b
    in
        b


delEdgesAscendants_ : DataModel.Identifier -> List DataModel.Node -> DataModel.Node -> Model.Model -> Model.Model
delEdgesAscendants_ id_src list target model =
    let
        newModel =
            case list of
                x :: xs ->
                    delEdgesAscendants_ id_src xs x (delEdgeAscendant_ id_src x target model)

                [] ->
                    model
    in
        newModel



{--
delEdgeAscendant_ :
    suppression conditionnelle des liens : src ---- a = (ascendant target)
    condition = il n'existe pas de liens src ---- a.children si a.children != target
--}


delEdgeAscendant_ : DataModel.Identifier -> DataModel.Node -> DataModel.Node -> Model.Model -> Model.Model
delEdgeAscendant_ id_src ascendant target model =
    let
        -- on construit la liste des enfants
        children =
            ModelManagement.getChildren model.dataModel.nodes ascendant

        children_except_target =
            List.filter (\x -> not (x.id == target.id)) children

        zzz =
            Debug.log "children except ascendant" ascendant

        zz =
            Debug.log "children except target" target

        z =
            Debug.log "children_except_target" children_except_target

        -- verification de possibilité suppression lien src ---- ascendant
        -- si b vaut False, on peut supprimer le lien id_src ---- ascendant
        b =
            linkExistance_ children_except_target id_src ascendant model

        newModel =
            case b of
                False ->
                    let
                        newEdges =
                            List.filter (\x -> not ((x.source == id_src && x.target == ascendant.id) || (x.source == ascendant.id && x.target == id_src))) model.dataModel.edges

                        model_dataModel =
                            model.dataModel

                        newDataModel =
                            { model_dataModel | edges = newEdges }

                        m1 =
                            { model | dataModel = newDataModel }
                    in
                        m1

                True ->
                    model
    in
        newModel



{--
delEdgeForList_ : delete les liens id -> x.id et x.id -> id pour x dans list
--}


delEdgeForList_ : DataModel.Identifier -> List DataModel.Node -> List DataModel.Edge -> List DataModel.Edge
delEdgeForList_ id list edges =
    case list of
        x :: xs ->
            let
                edge =
                    { id = 0, source = id, target = x.id }

                newEdges =
                    delEdge edge edges
            in
                delEdgeForList_ id xs newEdges

        [] ->
            edges


delEdge : DataModel.Edge -> List DataModel.Edge -> List DataModel.Edge
delEdge edge list =
    List.filter (\x -> not ((x.source == edge.source && x.target == edge.target) || (x.target == edge.source && x.source == edge.target))) list



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


deleteNode : DataModel.Identifier -> Model.Model -> Model.Model
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


deleteEdgesAndNodeFromListNode_ : List DataModel.Node -> Model.Model -> Model.Model
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


deleteEdgesAndNode_ : DataModel.Node -> Model.Model -> Model.Model
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


deleteEdgeFromList_ : List DataModel.Edge -> Model.Model -> Model.Model
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


renameNode_ : DataModel.Node -> String -> DataModel.Node
renameNode_ n s =
    { n | name = s }


process_ : String -> Maybe DataModel.Identifier -> DataModel.Node -> DataModel.Node
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


renameNodeInList_ : String -> Maybe DataModel.Identifier -> List DataModel.Node -> List DataModel.Node
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
