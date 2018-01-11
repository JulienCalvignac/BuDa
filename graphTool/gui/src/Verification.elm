module Verification exposing (verification)

import DataModel exposing (Model)
import Link exposing (Edge)
import ModelManagement


verification : Model -> Model
verification model =
    filterLinkNodeWithAscendant_ model



-- verification des liens du modele
-- 1. on supprime les liens entre n et ascendant(n)


filterLinkNodeWithAscendant_ : Model -> Model
filterLinkNodeWithAscendant_ model =
    let
        filterEdges =
            List.filter
                (\x ->
                    not (isLinkNodeWithAscendant_ x model)
                )
                model.edges
    in
        { model | edges = filterEdges }


isLinkNodeWithAscendant_ : Edge -> Model -> Bool
isLinkNodeWithAscendant_ edge model =
    -- on teste si (src est ascendant de target) ou si (target est ascendant de src)
    let
        m_nsrc =
            DataModel.getNodeFromId edge.source model.nodes

        m_ntarget =
            DataModel.getNodeFromId edge.target model.nodes

        b =
            case ( m_nsrc, m_ntarget ) of
                ( Just nsrc, Just ntarget ) ->
                    let
                        src_ascendants =
                            ModelManagement.getAscendants model.nodes nsrc Nothing

                        target_ascendants =
                            ModelManagement.getAscendants model.nodes ntarget Nothing

                        b1 =
                            (List.member nsrc target_ascendants) || (List.member ntarget src_ascendants)

                        z =
                            if b1 == True then
                                Debug.log "delete link" [ ( nsrc, ntarget ) ]
                            else
                                []
                    in
                        b1

                _ ->
                    False
    in
        b
