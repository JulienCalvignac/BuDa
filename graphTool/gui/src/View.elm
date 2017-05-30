module View exposing (init)

-- import Decoders

import Actions
import Model


init : ( Model.Model, Cmd Actions.Msg )
init =
    let
        m1 =
            Model.defaultModel

        -- model =
        --     Decoders.decodePBS Decoders.defaultPBS Model.defaultModel
        --
        -- m1 =
        --     Debug.log "model init:"
        --         (Decoders.decodeLNK Decoders.defaultLNK model)
    in
    ( m1, Cmd.none )
