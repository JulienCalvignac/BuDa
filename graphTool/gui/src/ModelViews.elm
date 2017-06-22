module ModelViews
    exposing
        ( getPBSView
        , getBullesViewFromNodeId
        , getBullesView
        , getPBSViewFromNodeId
        , getPBSViewFromNodeName
        )

import Identifier exposing (Identifier)
import DataModel
import ModelManagement


getPBSView : DataModel.Model -> DataModel.Model
getPBSView model =
    ModelManagement.listNodeToPBS model.nodes


getBullesViewFromNodeId : DataModel.Model -> Identifier -> DataModel.Model
getBullesViewFromNodeId model id =
    ModelManagement.subBullesModelFromId model id


getBullesView : DataModel.Model -> DataModel.Model
getBullesView model =
    ModelManagement.subBullesFromUniverse model


getBullesViewFromNodeName : DataModel.Model -> String -> DataModel.Model
getBullesViewFromNodeName model s =
    ModelManagement.subBullesModelFromName model s


getPBSViewFromNodeId : DataModel.Model -> Identifier -> DataModel.Model
getPBSViewFromNodeId model id =
    ModelManagement.listNodeToPBSFromNodeId model.nodes id


getPBSViewFromNodeName : DataModel.Model -> String -> DataModel.Model
getPBSViewFromNodeName model s =
    ModelManagement.listNodeToPBSFromNodeName model.nodes s
