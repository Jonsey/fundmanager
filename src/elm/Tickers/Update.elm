module Tickers.Update exposing (..)

import Dict exposing (update)

import Tickers.Messages exposing (Msg(..))
import Tickers.Models exposing (Model, Ticker)



update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        NoOp ->
            ( model, Cmd.none )

        OnReceiveTicker ticker ->
            let
                tickers =
                    Dict.insert ticker.id ticker model.tickers
            in
                ( { model | tickers = tickers } , Cmd.none )
