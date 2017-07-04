module LinkParametersActions exposing (activateParameter, unActivateParameter)

import Identifier exposing (Identifier)
import Node exposing (Node)
import Link exposing (Edge)
import Model
import DataModel
import ModelManagement


{--
////////////////////////////////////////////////////////////////////////////////
unActivateParameter
////////////////////////////////////////////////////////////////////////////////

--}


unActivateParameter : Identifier -> Edge -> Model.Model -> Model.Model
unActivateParameter idx edge model =
    let
        ns =
            (DataModel.getNodeFromId edge.source model.dataModel.nodes)

        nt =
            (DataModel.getNodeFromId edge.target model.dataModel.nodes)

        newModel =
            case ( ns, nt ) of
                ( Just ns1, Just nt1 ) ->
                    unActivateParameter_ idx ns1 nt1 model

                ( _, _ ) ->
                    model
    in
        newModel


unActivateParameter_ : Identifier -> Node -> Node -> Model.Model -> Model.Model
unActivateParameter_ idx n m model =
    let
        m1 =
            unActivateParameterDown_ idx n m model

        m2 =
            unActivateParameterUp_ idx n m m1
    in
        m2


unActivateParameterUp_ : Identifier -> Node -> Node -> Model.Model -> Model.Model
unActivateParameterUp_ idx n m model =
    let
        commonParent =
            ModelManagement.findCommonParent model.dataModel.nodes n m

        asc_n =
            ModelManagement.getAscendants model.dataModel.nodes n commonParent

        asc_m =
            ModelManagement.getAscendants model.dataModel.nodes m commonParent
    in
        unActivateParameterUpForLists_ idx asc_n asc_m model


unActivateParameterUpForLists_ : Identifier -> List Node -> List Node -> Model.Model -> Model.Model
unActivateParameterUpForLists_ idx ls lt model =
    case ls of
        [] ->
            model

        x :: xs ->
            unActivateParameterUpForLists_ idx xs lt (unActivateParameterUpForOneList_ idx lt x.id model)


unActivateParameterUpForOneList_ : Identifier -> List Node -> Identifier -> Model.Model -> Model.Model
unActivateParameterUpForOneList_ idx list nId model =
    case list of
        [] ->
            model

        x :: xs ->
            let
                m1 =
                    unActivateParameterUpForOneList_ idx xs nId (unActivateParameterUpForEdge_ idx x.id nId model)
            in
                m1


canUnactivate : Identifier -> Identifier -> Identifier -> Model.Model -> Bool
canUnactivate idx mId nId model =
    let
        maybe_n =
            DataModel.getNodeFromId nId model.dataModel.nodes

        maybe_m =
            DataModel.getNodeFromId mId model.dataModel.nodes

        newModel =
            case ( maybe_n, maybe_m ) of
                ( Just n, Just m ) ->
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
                            DataModel.anyLinksParameter idx childs_plus_m childs_n model.dataModel.edges

                        b2 =
                            DataModel.anyLinksParameter idx childs_plus_n childs_m model.dataModel.edges

                        b =
                            not (b1 || b2)
                    in
                        b

                ( _, _ ) ->
                    -- ne devrait jamais arriver
                    True
    in
        newModel


unActivateParameterUpForEdge_ : Identifier -> Identifier -> Identifier -> Model.Model -> Model.Model
unActivateParameterUpForEdge_ idx mId nId model =
    case (canUnactivate idx mId nId model) of
        False ->
            model

        True ->
            unActivateParameterUpEdge_ idx mId nId model


unActivateParameterUpEdge_ : Identifier -> Identifier -> Identifier -> Model.Model -> Model.Model
unActivateParameterUpEdge_ idx mId nId model =
    let
        edge =
            (Link.link mId nId)

        newEdges =
            updatePropertyInEdgeList_ edge idx model.dataModel.edges Link.unActivate

        model_datamodel =
            model.dataModel

        new_dataModel =
            { model_datamodel | edges = newEdges }
    in
        { model | dataModel = new_dataModel }


unActivateParameterDown_ : Identifier -> Node -> Node -> Model.Model -> Model.Model
unActivateParameterDown_ idx n m model =
    let
        model_dataModel =
            model.dataModel

        n_descendants =
            ModelManagement.getDescendantsFromN model_dataModel.nodes n

        m_descendants =
            ModelManagement.getDescendantsFromN model_dataModel.nodes m

        m1 =
            unActivateParameterDownForLists_ idx n_descendants m_descendants model
    in
        m1


unActivateParameterDownForLists_ : Identifier -> List Node -> List Node -> Model.Model -> Model.Model
unActivateParameterDownForLists_ idx ls lt model =
    case ls of
        [] ->
            model

        x :: xs ->
            unActivateParameterDownForLists_ idx xs lt (unActivateParameterDownForOneList_ idx lt x.id model)


unActivateParameterDownForOneList_ : Identifier -> List Node -> Identifier -> Model.Model -> Model.Model
unActivateParameterDownForOneList_ idx list nId model =
    case list of
        [] ->
            model

        x :: xs ->
            let
                m1 =
                    unActivateParameterDownForOneList_ idx xs nId (unActivateParameterDownForEdge_ idx x.id nId model)
            in
                m1


unActivateParameterDownForEdge_ : Identifier -> Identifier -> Identifier -> Model.Model -> Model.Model
unActivateParameterDownForEdge_ idx mId nId model =
    let
        edge =
            (Link.link mId nId)

        newEdges =
            updatePropertyInEdgeList_ edge idx model.dataModel.edges Link.unActivate

        model_datamodel =
            model.dataModel

        new_dataModel =
            { model_datamodel | edges = newEdges }
    in
        { model | dataModel = new_dataModel }



{--
////////////////////////////////////////////////////////////////////////////////
unActivateParameter
////////////////////////////////////////////////////////////////////////////////

--}


activateParameter : Identifier -> Edge -> Model.Model -> Model.Model
activateParameter idx edge model =
    let
        ns =
            (DataModel.getNodeFromId edge.source model.dataModel.nodes)

        nt =
            (DataModel.getNodeFromId edge.target model.dataModel.nodes)

        newModel =
            case ( ns, nt ) of
                ( Just ns1, Just nt1 ) ->
                    activateParameter_ idx ns1 nt1 model

                ( _, _ ) ->
                    model
    in
        newModel


activateParameter_ : Identifier -> Node -> Node -> Model.Model -> Model.Model
activateParameter_ idx n m model =
    let
        commonParent =
            ModelManagement.findCommonParent model.dataModel.nodes n m

        ln =
            (ModelManagement.getAscendants model.dataModel.nodes n commonParent)

        lm =
            (ModelManagement.getAscendants model.dataModel.nodes m commonParent)

        m2 =
            activateParameterForLists_ idx ln lm model
    in
        m2


activateParameterForLists_ : Identifier -> List Node -> List Node -> Model.Model -> Model.Model
activateParameterForLists_ idx ls lt model =
    case ls of
        [] ->
            model

        x :: xs ->
            activateParameterForLists_ idx xs lt (activateParameterForOneList_ idx lt x.id model)


activateParameterForOneList_ : Identifier -> List Node -> Identifier -> Model.Model -> Model.Model
activateParameterForOneList_ idx list nId model =
    case list of
        [] ->
            model

        x :: xs ->
            let
                m1 =
                    activateParameterForOneList_ idx xs nId (activateParameterForEdge_ idx x.id nId model)
            in
                m1


activateParameterForEdge_ : Identifier -> Identifier -> Identifier -> Model.Model -> Model.Model
activateParameterForEdge_ idx mId nId model =
    let
        edge =
            (Link.link mId nId)

        newEdges =
            updatePropertyInEdgeList_ edge idx model.dataModel.edges Link.activate

        model_datamodel =
            model.dataModel

        new_dataModel =
            { model_datamodel | edges = newEdges }
    in
        { model | dataModel = new_dataModel }


updatePropertyInEdgeList_ : Edge -> Identifier -> List Edge -> (Identifier -> Edge -> Edge) -> List Edge
updatePropertyInEdgeList_ x idx list func =
    List.map (\y -> processProperty_ x idx y func) list


processProperty_ : Edge -> Identifier -> Edge -> (Identifier -> Edge -> Edge) -> Edge
processProperty_ x idx edge func =
    case
        (x.target == edge.target && x.source == edge.source)
            || (x.source == edge.target && x.target == edge.source)
    of
        False ->
            edge

        True ->
            func idx edge
