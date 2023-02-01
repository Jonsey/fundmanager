module Tickers.Utils.Mapper exposing (mapTicker)


import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)

import Tickers.Models exposing (Ticker)
import Tickers.Messages exposing (..)


mapTicker : Value -> Tickers.Messages.Msg
mapTicker modelJson =
    case (decodeModel modelJson) of
        Ok ticker ->
            OnReceiveTicker ticker
        Err errorMessage ->
            let
                _ = Debug.log "Error in map ticker:" errorMessage
            in
                NoOp


decodeModel : Value -> Result String Ticker
decodeModel modelJson =
    decodeValue tickerDecoder modelJson


tickerDecoder : Decoder Ticker
tickerDecoder =
    decode Ticker
        |> required "id" string
        |> required "name" string
        |> required "last" float
        |> required "lowestAsk" float
        |> required "highestBid" float
        |> required "percentChange" float
        |> required "baseVolume" float
        |> required "quoteVolume" float
        |> required "isFrozen" bool
        |> required "dayHigh" float
        |> required "dayLow" float
