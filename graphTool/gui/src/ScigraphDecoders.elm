module ScigraphDecoders exposing (decodeLNK, decodePBS)

import Array
import DataModel
import Regex
import String.Extra


begin : String
begin =
    "graph app_graph {overlap=false"


end : String
end =
    "}"


extractUtilFields : String -> String
extractUtilFields s =
    String.Extra.replace end "" (String.Extra.replace begin "" (String.Extra.replace "\n" "" s))


decodeOneField : String -> ( Maybe String, Maybe String )
decodeOneField s =
    let
        tab =
            Array.fromList (Regex.split Regex.All (Regex.regex " -- ") s)
    in
        ( Array.get 0 tab, Array.get 1 tab )


decodeFields : List String -> List ( Maybe String, Maybe String )
decodeFields lst =
    List.map decodeOneField lst


decodeOneLine : String -> List String
decodeOneLine s =
    Regex.split Regex.All (Regex.regex ";") s


decodePBS : String -> DataModel.Model -> DataModel.Model
decodePBS s model =
    let
        s1 =
            extractUtilFields s

        lst =
            decodeOneLine s1

        ls2 =
            decodeFields lst
    in
        decodePBSToModel ls2 model


decodeLNK : String -> DataModel.Model -> DataModel.Model
decodeLNK s model =
    let
        s1 =
            extractUtilFields s

        lst =
            decodeOneLine s1

        ls2 =
            decodeFields lst

        -- z =
        --     Debug.log "ls2:" ls2
    in
        decodeLNKToModel ls2 model


addOneNodeToModel : String -> String -> DataModel.Model -> DataModel.Model
addOneNodeToModel s pname model =
    let
        b =
            DataModel.isNamePresent s model.nodes

        newModel =
            case b of
                True ->
                    model

                False ->
                    DataModel.addNewNodeToModel s pname model
    in
        newModel


add2SNodeToModel : ( String, String ) -> DataModel.Model -> DataModel.Model
add2SNodeToModel ( parent, child ) model =
    let
        model1 =
            addOneNodeToModel parent "" model

        model2 =
            addOneNodeToModel child parent model1
    in
        model2


add2SLNKToModel : ( String, String ) -> DataModel.Model -> DataModel.Model
add2SLNKToModel ( parent, child ) model =
    let
        nparent =
            DataModel.getNodeIdFromName parent model.nodes

        nchild =
            DataModel.getNodeIdFromName child model.nodes

        m1 =
            DataModel.getNodeIdentifier model

        newEdges =
            case nparent of
                Just np ->
                    case nchild of
                        Just nc ->
                            --{ id = m1.curNodeId, source = np, target = nc }
                            (Link.makeLink m1.curNodeId np nc)
                                :: m1.edges

                        Nothing ->
                            m1.edges

                Nothing ->
                    m1.edges
    in
        { m1 | edges = newEdges }


addNodetoModel : ( Maybe String, Maybe String ) -> DataModel.Model -> DataModel.Model
addNodetoModel res model =
    case res of
        ( Just s1, Just s2 ) ->
            add2SNodeToModel ( s1, s2 ) model

        ( _, _ ) ->
            model


decodePBSToModel : List ( Maybe String, Maybe String ) -> DataModel.Model -> DataModel.Model
decodePBSToModel list model =
    case list of
        x :: xs ->
            let
                m1 =
                    addNodetoModel x model
            in
                decodePBSToModel xs m1

        [] ->
            model


addLNKtoModel : ( Maybe String, Maybe String ) -> DataModel.Model -> DataModel.Model
addLNKtoModel res model =
    case res of
        ( Just s1, Just s2 ) ->
            add2SLNKToModel ( s1, s2 ) model

        ( _, _ ) ->
            model


decodeLNKToModel : List ( Maybe String, Maybe String ) -> DataModel.Model -> DataModel.Model
decodeLNKToModel list model =
    case list of
        x :: xs ->
            let
                m1 =
                    addLNKtoModel x model
            in
                decodeLNKToModel xs m1

        [] ->
            model
