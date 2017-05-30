module Tests exposing (..)

import Test exposing (..)


-- import Test.Runner.Html

import ModelActionsTest


all : Test
all =
    describe "graphTool test suite"
        [ ModelActionsTest.tests
        ]
