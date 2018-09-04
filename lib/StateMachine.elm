port module StateMachine exposing (Flags, Model, Msg(..), Position, backJumped, forwardJumped, init, initCmds, main, requestBack, requestForward, requestRegisterPosition, reset, update)

import Html as Html exposing (..)
import Html.Events as Events exposing (..)
import Json.Decode as Json
import List exposing (any, head)
import Maybe exposing (..)
import Process
import Task
import Time


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions =
            \model ->
                Sub.batch
                    [ requestRegisterPosition RequestRegisterPosition
                    , requestBack (Basics.always RequestBack)
                    , requestForward (Basics.always RequestForward)
                    ]
        }


type alias Position =
    List Int



-- Outbound


port backJumped : Maybe Position -> Cmd msg


port forwardJumped : Maybe Position -> Cmd msg



-- Inbound


port requestRegisterPosition : (Position -> msg) -> Sub msg


port requestBack : (() -> msg) -> Sub msg


port requestForward : (() -> msg) -> Sub msg


type Msg
    = RequestRegisterPosition Position
    | RequestBack
    | RequestForward


type alias Model =
    { isJumping : Bool
    , backPositions : List Position
    , forwardPositions : List Position
    , current : Maybe Position
    }


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { isJumping = False
      , backPositions = []
      , forwardPositions = []
      , current = Nothing
      }
    , initCmds
    )


initCmds : Cmd Msg
initCmds =
    Cmd.none


reset : Model -> Model
reset model =
    { model | isJumping = False }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestRegisterPosition newPosition ->
            let
                m =
                    if newPosition == (model.current |> withDefault [ 0, 0 ]) then
                        model

                    else
                        case model.current of
                            Nothing ->
                                Debug.log "RequestRegisterPosition: Nothing"
                                    { model
                                        | current = Just newPosition
                                    }

                            Just current ->
                                Debug.log "RequestRegisterPosition: Just current"
                                    { model
                                        | current = Just newPosition
                                        , backPositions = current :: model.backPositions
                                    }
            in
            ( m, Cmd.none )

        RequestBack ->
            if model.isJumping then
                ( Debug.log "RequestBack: is jumping so no change" model, Cmd.none )

            else
                let
                    newCurrent =
                        case List.head model.backPositions of
                            Just position ->
                                Just position

                            Nothing ->
                                model.current

                    newForwardPositions =
                        case model.current of
                            Just position ->
                                position :: model.forwardPositions

                            Nothing ->
                                model.forwardPositions
                in
                ( Debug.log "RequestBack: NOT is jumping"
                    { model
                        | forwardPositions = newForwardPositions
                        , current = newCurrent
                        , backPositions = model.backPositions |> List.tail |> withDefault []
                    }
                    |> reset
                , Cmd.batch [ backJumped (Debug.log "maybe just newcurrent in backJumped" newCurrent) ]
                )

        RequestForward ->
            if model.isJumping then
                ( Debug.log "isJumping, do nothing" model, Cmd.none )

            else
                let
                    newCurrent =
                        case List.head model.forwardPositions of
                            Just position ->
                                Just position

                            Nothing ->
                                model.current

                    newBackPositions =
                        case model.current of
                            Just position ->
                                position :: model.backPositions

                            Nothing ->
                                model.backPositions
                in
                ( Debug.log "RequestForward: NOT is jumping"
                    { model
                        | backPositions = newBackPositions
                        , current = newCurrent
                        , forwardPositions = model.forwardPositions |> List.tail |> withDefault []
                    }
                    |> reset
                , Cmd.batch [ forwardJumped (Debug.log "maybe just newcurrent in forwardJumped" newCurrent) ]
                )
