module DataModelTest exposing (tests)

import DataModel exposing (..)
import Test exposing (..)
import Expect


test_nodes : List Node
test_nodes =
    [ { id = 0, name = "system", parent = Nothing }
    , { id = 1, name = "b1", parent = Just 0 }
    , { id = 2, name = "a1", parent = Just 0 }
    , { id = 3, name = "b11", parent = Just 1 }
    , { id = 4, name = "b12", parent = Just 1 }
    , { id = 5, name = "a11", parent = Just 2 }
    , { id = 6, name = "a12", parent = Just 2 }
    , { id = 7, name = "ext1", parent = Nothing }
    , { id = 8, name = "e1", parent = Just 7 }
    , { id = 9, name = "e2", parent = Just 7 }
    ]


test_links : List Edge
test_links =
    [ { id = 11, source = 4, target = 8 }
    , { id = 12, source = 1, target = 8 }
    , { id = 13, source = 0, target = 8 }
    , { id = 14, source = 4, target = 7 }
    , { id = 15, source = 1, target = 7 }
    , { id = 16, source = 0, target = 7 }
      -- exemple 3
      -- , { id = 17, source = 9, target = 0 }
      -- exemple 2
    , { id = 17, source = 3, target = 8 }
    , { id = 18, source = 3, target = 7 }
      -- example 1
      -- , { id = 17, source = 3, target = 7 }
    ]



--
--
-- test_datamodel : Model
-- test_datamodel =
--     { nodes =
--         test_nodes
--     , edges =
--         test_links
--     , curNodeId = 30
--     }
--
--
-- test_model : Model.Model
-- test_model =
--     let
--         m0 =
--             Model.defaultModel
--     in
--         { m0 | dataModel = test_datamodel }
--
--


n : Node
n =
    { id = 4, name = "b12", parent = Just 1 }


list_n : List Node
list_n =
    [ { id = 0, name = "system", parent = Nothing }
    , { id = 4, name = "b12", parent = Just 1 }
    , { id = 8, name = "e1", parent = Just 7 }
    , { id = 9, name = "e2", parent = Just 7 }
    ]


list_n2 : List Node
list_n2 =
    [ { id = 0, name = "system", parent = Nothing }
    , { id = 1, name = "b1", parent = Just 0 }
    , { id = 2, name = "a1", parent = Just 0 }
    , { id = 3, name = "b11", parent = Just 1 }
    ]


m : Node
m =
    { id = 8, name = "e1", parent = Just 7 }



--
--
-- asc_n : List Node
-- asc_n =
--     [ { id = 1, name = "b1", parent = Just 0 }, { id = 0, name = "system", parent = Nothing } ]
--
--
-- asc_m : List Node
-- asc_m =
--     [ { id = 7, name = "ext1", parent = Nothing } ]


edges_doublons : List Edge
edges_doublons =
    [ { id = 11, source = 4, target = 8 }
    , { id = 12, source = 1, target = 8 }
    , { id = 13, source = 0, target = 8 }
    , { id = 14, source = 4, target = 7 }
    , { id = 15, source = 1, target = 8 }
    ]


edges_no_doublon : List Edge
edges_no_doublon =
    [ { id = 11, source = 4, target = 8 }
    , { id = 12, source = 1, target = 8 }
    , { id = 13, source = 0, target = 8 }
    , { id = 14, source = 4, target = 7 }
    ]



-- , addNewNodeToModel
-- , anyLink
-- , anyLinks
-- , bros
-- , childs
-- , dataModelToModel
-- , defaultModel
-- , edgeST
-- , getEdgeFromId
-- , getNodeFromId
-- , getNodeFromName
-- , getNodeIdFromName
-- , getNodeIdentifier
-- , getNodeNameFromId
-- , isEdgePresent
-- , isNamePresent
-- , isNodePresent
-- , isNodeIdPresent
-- , nodeHasParent
-- , maximumNodeId
-- , anyEdgeDoublon


tests : Test
tests =
    describe "DataModel"
        [ test "anyEdgeDoublon edges_doublons is True" <|
            \_ ->
                anyEdgeDoublon edges_doublons
                    |> Expect.equal True
        , test "anyEdgeDoublon edges_no_doublon is False" <|
            \_ ->
                anyEdgeDoublon edges_no_doublon
                    |> Expect.equal False
        , test "anyLink list_n n test_links is True" <|
            \_ ->
                anyLink list_n n test_links
                    |> Expect.equal True
        , test "anyLink list_n2 n test_links is False" <|
            \_ ->
                anyLink list_n2 n test_links
                    |> Expect.equal False
        , test "bros n test_nodes is [{ id = 3, name = 'b11', parent = Just 1 }]" <|
            \_ ->
                bros n test_nodes
                    |> Expect.equal [ { id = 3, name = "b11", parent = Just 1 } ]
        , test "childs  { id = 1, name = \"b1\", parent = Just 0 } test_nodes is [{ id = 3, name = \"b11\", parent = Just 1 }, { id = 4, name = \"b12\", parent = Just 1 }]" <|
            \_ ->
                childs { id = 1, name = "b1", parent = Just 0 } test_nodes
                    |> Expect.equal [ { id = 3, name = "b11", parent = Just 1 }, { id = 4, name = "b12", parent = Just 1 } ]
        ]
