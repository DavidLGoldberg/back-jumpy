port module StateMachine exposing (Flags, Model, Msg(..), Position, backJumped, forwardJumped, init, initCmds, main, requestBack, requestForward, requestRegisterPosition, update)

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
    | Reset


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


delay : Float -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.perform (\_ -> msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reset ->
            ( Debug.log "reset" { model | isJumping = False }, Cmd.none )

        RequestRegisterPosition newPosition ->
            let
                m =
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
                        model.backPositions |> List.head |> Maybe.withDefault [ 0, 0 ]
                in
                ( Debug.log "RequestBack: NOT is jumping"
                    { model
                        | forwardPositions = (model.current |> Maybe.withDefault [ 0, 0 ]) :: model.forwardPositions
                        , current = Maybe.Just newCurrent
                        , backPositions = model.backPositions |> List.tail |> Maybe.withDefault []
                    }
                , Cmd.batch [ backJumped (Debug.log "maybe just newcurrent in backJumped" (Maybe.Just newCurrent)), delay 30 Reset ]
                )

        RequestForward ->
            if model.isJumping then
                ( Debug.log "isJumping, do nothing" model, Cmd.none )

            else
                -- TODO: this won't be the head
                ( Debug.log "not jumping so send back" model, Cmd.batch [ forwardJumped (head model.backPositions), delay 10 Reset ] )
