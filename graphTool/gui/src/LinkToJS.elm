port module LinkToJS
    exposing
        ( -- createEdge
          -- , createNode
          -- , deleteElement
          layout
        , loadModel
        , modeltoelm
          -- , renameNode
        , reqModelfromJS
        , saveModel
        , sendDataPBSModel
        , sendDataBullesModel
        , suggestions
        )

-- communication Elm -> JS


port sendDataPBSModel : String -> Cmd msg


port sendDataBullesModel : String -> Cmd msg


port layout : String -> Cmd msg



-- port deleteElement : String -> Cmd msg
-- port createNode : String -> Cmd msg
-- port renameNode : String -> Cmd msg
-- port createEdge : String -> Cmd msg


port saveModel : String -> Cmd msg


port loadModel : String -> Cmd msg


port reqModelfromJS : String -> Cmd msg



-- communication JS -> Elm


port suggestions : (List String -> msg) -> Sub msg


port modeltoelm : (String -> msg) -> Sub msg
