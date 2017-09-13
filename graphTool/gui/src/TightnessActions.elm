module TightnessActions exposing (addTightnessForEdgeId, removeTightnessForEdgeId, removeAllTightness)

import Tightness
import Identifier exposing (Identifier)
import Link exposing (Edge)


addTightnessForEdgeId : Identifier -> Identifier -> List Edge -> List Edge
addTightnessForEdgeId id edgeId edges =
    List.map
        (\x ->
            case x.id == edgeId of
                False ->
                    x

                True ->
                    { x | tightness = Tightness.addTightness id x.tightness }
        )
        edges


removeTightnessForEdgeId : Identifier -> Identifier -> List Edge -> List Edge
removeTightnessForEdgeId id edgeId edges =
    List.map
        (\x ->
            case x.id == edgeId of
                False ->
                    x

                True ->
                    { x | tightness = Tightness.removeTightness id x.tightness }
        )
        edges


removeAllTightness : Identifier -> List Edge -> List Edge
removeAllTightness id edges =
    List.map (\x -> { x | tightness = Tightness.removeTightness id x.tightness }) edges
