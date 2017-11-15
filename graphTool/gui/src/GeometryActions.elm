module GeometryActions exposing (addGeometryToNode, deleteGeometryFromNode)

import Identifier exposing (Identifier)
import Node exposing (Node)
import DataModel exposing (Model, childs)
import ModelManagement


addGeometryToNode : Identifier -> Node -> Model -> Model
addGeometryToNode id n model =
    let
        asc_n =
            ModelManagement.getAscendants model.nodes n Nothing
    in
        addGeometryToListNode_ id asc_n model


addGeometryToListNode_ : Identifier -> List Node -> Model -> Model
addGeometryToListNode_ id list model =
    case list of
        [] ->
            model

        x :: xs ->
            addGeometryToListNode_ id xs (addGeometryToOneNode_ id x model)


addGeometryToOneNode_ : Identifier -> Node -> Model -> Model
addGeometryToOneNode_ id n model =
    let
        newNodes =
            List.map
                (\x ->
                    case x.id == n.id of
                        True ->
                            { x | geometry = Just id }

                        False ->
                            x
                )
                model.nodes
    in
        { model | nodes = newNodes }



{--
////////////////////////////////////////////////////////////////////////////////
deleteGeometryFromNode
////////////////////////////////////////////////////////////////////////////////
--}


deleteGeometryFromNode : Identifier -> Node -> Model -> Model
deleteGeometryFromNode id n model =
    let
        asc_n =
            ModelManagement.getAscendants model.nodes n Nothing
    in
        deleteGeometryFromListNode_ id asc_n model


deleteGeometryFromListNode_ : Identifier -> List Node -> Model -> Model
deleteGeometryFromListNode_ id list model =
    case list of
        [] ->
            model

        x :: xs ->
            deleteGeometryFromListNode_ id xs (deleteGeometryFromOneNode_ id x model)


deleteGeometryFromOneNode_ : Identifier -> Node -> Model -> Model
deleteGeometryFromOneNode_ id n model =
    case (canDeleteGeometryFromNode id n model) of
        False ->
            model

        True ->
            let
                newNodes =
                    List.map
                        (\x ->
                            case x.id == n.id of
                                True ->
                                    { x | geometry = Nothing }

                                False ->
                                    x
                        )
                        model.nodes
            in
                { model | nodes = newNodes }


canDeleteGeometryFromNode : Identifier -> Node -> Model -> Bool
canDeleteGeometryFromNode id n model =
    True
