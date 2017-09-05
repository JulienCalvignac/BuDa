module ModelActions
    exposing
        ( createLink
        , createNode
        , dataModelToModel
        , deleteEdge
        , deleteNode
        , renameNode
        , exportLink
        , updateSelectedFlux
        , createParameter
        , deleteParameter
        , updateAttribute
        , updateProperty
        , undo
        , groupNodes
        )

import Identifier exposing (Identifier)
import Link exposing (Edge)
import Node exposing (Node)
import DataModel
import Model exposing (Model)
import LinkParameters
import Set exposing (Set)
import LinkParameters
import DataModelActions
import Scenario
import Player
import DataModelDecoders
import Json.Decode


{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

createLink

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
--}
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
        newDataModel =
            DataModelActions.createLink s t model.dataModel

        newUndo =
            Scenario.addMsg (Scenario.CreateLink s t) model.undo

        m1 =
            { model
                | selectionType = Model.LINK (DataModel.getEdgeIdFromNodesId s t newDataModel.edges)
                , dataModel = newDataModel
                , undo = newUndo
            }
    in
        m1



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

        newDataModel1 =
            DataModelActions.createNode newName newParent model.dataModel

        newUndo =
            Scenario.addMsg (Scenario.CreateNode newName newParent) model.undo
    in
        { model | dataModel = newDataModel1, undo = newUndo }



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
        newDataModel =
            DataModelActions.deleteEdge id model.dataModel

        newUndo =
            Scenario.addMsg (Scenario.DeleteLink id) model.undo
    in
        { model
            | dataModel = newDataModel
            , undo = newUndo
        }



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
        newDataModel =
            DataModelActions.deleteNode id model.dataModel

        newUndo =
            Scenario.addMsg (Scenario.DeleteNode id) model.undo
    in
        { model | dataModel = newDataModel, undo = newUndo }



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

renameNode:
rename node select dans le Model.dataModel

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


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

        newDataModel =
            DataModelActions.renameNode newName nId model.dataModel

        newUndo =
            Scenario.addMsg (Scenario.RenameNode newName nId) model.undo
    in
        { model
            | dataModel = newDataModel
            , undo = newUndo
        }



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

updateSelectedFlux:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


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
    in
        { model | exportFlux = newExportFlux }



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

exportLink:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


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



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

createParameter:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


createParameter : Model.Model -> Model.Model
createParameter model =
    let
        newDataModel =
            (DataModelActions.createParameter model.input model.dataModel)

        newUndo =
            Scenario.addMsg (Scenario.CreateParameter model.input) model.undo
    in
        { model
            | dataModel = newDataModel
            , undo = newUndo
        }



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

deleteParameter:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


deleteParameter : Model.Model -> Model.Model
deleteParameter model =
    let
        newDataModel =
            DataModelActions.deleteParameter model.input model.dataModel

        newUndo =
            Scenario.addMsg (Scenario.DeleteParameter model.input) model.undo
    in
        { model
            | dataModel = newDataModel
            , undo = newUndo
        }



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

updateAttribute:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


updateAttribute : Model.Model -> String -> Model.Model
updateAttribute model s =
    let
        m_id =
            case model.selection of
                x :: xs ->
                    Just x

                [] ->
                    Nothing

        newDataModel =
            DataModelActions.updateAttribute m_id s model.dataModel

        newUndo =
            Scenario.addMsg (Scenario.UpdateAttribute s m_id) model.undo
    in
        { model
            | dataModel = newDataModel
            , undo = newUndo
        }



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

updateProperty:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


updateProperty : Edge -> String -> Model.Model -> Model.Model
updateProperty edge s model =
    let
        newDataModel =
            DataModelActions.updateProperty edge s model.dataModel

        newUndo =
            Scenario.addMsg (Scenario.UpdateProperty edge s) model.undo
    in
        { model
            | dataModel = newDataModel
            , undo = newUndo
        }



{--
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

dataModelToModel:

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

--}


dataModelToModel : String -> Model.Model -> Model.Model
dataModelToModel s model =
    let
        res_elts =
            Json.Decode.decodeString DataModelDecoders.decodeDataModel s

        m1 =
            case res_elts of
                Ok elements ->
                    let
                        newDataModel =
                            DataModel.dataModelToModel elements model.dataModel

                        newUndo =
                            Scenario.addMsg (Scenario.LoadModel elements) model.undo
                    in
                        { model
                            | dataModel = newDataModel
                            , undo = newUndo
                        }

                Err _ ->
                    model
    in
        m1


undo : Model.Model -> Model.Model
undo model =
    let
        ( newDataModel, newUndo ) =
            case model.undo of
                x :: xs ->
                    ( Player.play (List.reverse xs) DataModel.defaultModel, xs )

                [] ->
                    ( model.dataModel, [] )
    in
        { model | dataModel = newDataModel, undo = newUndo }


nodesInSelection : Model.Model -> List Node
nodesInSelection model =
    List.filter (\x -> (DataModel.isIdPresentInList x.id model.selection)) model.dataModel.nodes


groupNodes : Model.Model -> Model.Model
groupNodes model =
    let
        list =
            nodesInSelection model

        s =
            model.input

        newDataModel =
            DataModelActions.groupNodes list s model.dataModel

        newUndo =
            Scenario.addMsg (Scenario.GroupNodes list s) model.undo
    in
        { model | dataModel = newDataModel, undo = newUndo }
