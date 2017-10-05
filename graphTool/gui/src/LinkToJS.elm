port module LinkToJS
    exposing
        ( exportLNK
        , layout
        , loadModel
        , modeltoelm
        , doubleclick
        , saveModel
        , sendDataPBSModel
        , sendDataBullesModel
        , sendParentSelection
        , selection
        , nodesPositionToElm
        , requestpositions
        , nodesPositionRequest
        )

{--
//////////////////////////////////////////////////////////////////////////////
-- communication Elm -> JS
//////////////////////////////////////////////////////////////////////////////
--}
-- sendDataPBSModel: envoi du modele PBS vers javascript


port sendDataPBSModel : String -> Cmd msg



-- sendDataBullesModel: envoi du modele Bulles vers javascript


port sendDataBullesModel : String -> Cmd msg



-- sendParentSelection: envoi du node parent vers javascript, pour conserver la selection du parent


port sendParentSelection : String -> Cmd msg


port layout : String -> Cmd msg


port saveModel : String -> Cmd msg


port loadModel : String -> Cmd msg


port exportLNK : String -> Cmd msg


port requestpositions : String -> Cmd msg



{--
//////////////////////////////////////////////////////////////////////////////
-- communication JS -> Elm
//////////////////////////////////////////////////////////////////////////////
--}
-- selection : recuperation de la selection js dans elm


port selection : (List String -> msg) -> Sub msg



-- recuperation du modele charge en js dans elm


port modeltoelm : (String -> msg) -> Sub msg



-- recuperation du double click dans elm


port doubleclick : (String -> msg) -> Sub msg



-- recuperation des positions des blocs


port nodesPositionToElm : (String -> msg) -> Sub msg



-- demande de sauvegarde des positions


port nodesPositionRequest : (String -> msg) -> Sub msg
