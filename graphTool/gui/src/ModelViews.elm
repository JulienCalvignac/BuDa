module ModelViews exposing (ViewType(..), getPBSView, getBullesViewFromNodeId, getPBSViewFromNodeId, getPBSViewFromNodeName)

import DataModel
import ModelManagement


type ViewType
    = PVSView
    | BullesView


getPBSView : DataModel.Model -> DataModel.Model
getPBSView model =
    ModelManagement.listNodeToPBS model.nodes


getBullesViewFromNodeId : DataModel.Model -> DataModel.Identifier -> DataModel.Model
getBullesViewFromNodeId model id =
    ModelManagement.subModelFromId model id


getBullesViewFromNodeName : DataModel.Model -> String -> DataModel.Model
getBullesViewFromNodeName model s =
    ModelManagement.subModelFromName model s


getPBSViewFromNodeId : DataModel.Model -> DataModel.Identifier -> DataModel.Model
getPBSViewFromNodeId model id =
    ModelManagement.listNodeToPBSFromNodeId model.nodes id


getPBSViewFromNodeName : DataModel.Model -> String -> DataModel.Model
getPBSViewFromNodeName model s =
    ModelManagement.listNodeToPBSFromNodeName model.nodes s
