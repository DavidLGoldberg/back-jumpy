module Example exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import StateMachine exposing (Model, Msg(..), Position, update)
import Test exposing (..)


suite : Test
suite =
    let
        initial : Model
        initial =
            { backPositions = []
            , forwardPositions = []
            , current = Nothing
            }

        pos1 : Position
        pos1 =
            { row = 1, column = 1, path = "a" }

        pos2 : Position
        pos2 =
            { row = 2, column = 2, path = "b" }

        pos3 : Position
        pos3 =
            -- Let's test same path/file for this
            { row = 3, column = 3, path = "a" }
    in
    describe "Back-jumpy"
        [ describe "register a new position"
            [ test "from clear state" <|
                \_ ->
                    initial
                        |> update (RequestRegisterPosition pos1)
                        |> Tuple.first
                        |> Expect.equal
                            { initial
                                | backPositions = []
                                , current = Just pos1
                            }
            , test "from 1 registered" <|
                \_ ->
                    { initial | current = Just pos1 }
                        |> update (RequestRegisterPosition pos2)
                        |> Tuple.first
                        |> Expect.equal
                            { initial
                                | backPositions = [ pos1 ]
                                , current = Just pos2
                            }
            ]
        , describe "requesting back"
            [ test "does nothing when no where to go" <|
                \_ ->
                    initial
                        |> update RequestBack
                        |> Tuple.first
                        |> Expect.equal initial
            , test "goes back" <|
                \_ ->
                    { initial
                        | backPositions = [ pos2, pos1 ]
                        , current = Just pos3
                    }
                        |> update RequestBack
                        |> Tuple.first
                        |> Expect.equal
                            { initial
                                | backPositions = [ pos1 ]
                                , forwardPositions = [ pos3 ]
                                , current = Just pos2
                            }
            , test "does nothing when no more back left" <|
                \_ ->
                    let
                        noMoreBacks =
                            { initial
                                | backPositions = []
                                , current = Just pos1
                                , forwardPositions = [ pos3, pos2 ]
                            }
                    in
                    noMoreBacks
                        |> update RequestBack
                        |> Tuple.first
                        |> Expect.equal noMoreBacks
            ]
        , describe "requesting forward"
            [ test "does nothing when no where to go" <|
                \_ ->
                    initial
                        |> update RequestForward
                        |> Tuple.first
                        |> Expect.equal initial
            , test "goes forward" <|
                \_ ->
                    { initial
                        | backPositions = []
                        , forwardPositions = [ pos2, pos3 ]
                        , current = Just pos1
                    }
                        |> update RequestForward
                        |> Tuple.first
                        |> Expect.equal
                            { initial
                                | backPositions = [ pos1 ]
                                , forwardPositions = [ pos3 ]
                                , current = Just pos2
                            }
            , test "does nothing when no more forward left" <|
                \_ ->
                    let
                        noMoreForwards =
                            { initial
                                | backPositions = [ pos1 ]
                                , current = Just pos2
                                , forwardPositions = []
                            }
                    in
                    noMoreForwards
                        |> update RequestForward
                        |> Tuple.first
                        |> Expect.equal noMoreForwards
            ]
        ]
