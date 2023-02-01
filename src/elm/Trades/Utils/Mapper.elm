module Trades.Utils.Mapper exposing (mapTrade)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Utils.Decoders exposing (stringIntDecoder, date, tradeType, tradeCategory)
import Trades.Messages exposing (Msg(..))
import Trades.Models exposing (Trade, TradeId, TradeType(..), TradeCategory(..))


mapTrade : Value -> Trades.Messages.Msg
mapTrade modelJson =
    case (decodeModel modelJson) of
        Ok trade ->
            OnReceiveTrade trade

        Err errorMessage ->
            let
                _ =
                    Debug.log "Error in map trade:" errorMessage
            in
                NoOp


decodeModel : Value -> Result String Trade
decodeModel modelJson =
    decodeValue tradeDecoder modelJson


tradeDecoder : Decoder Trade
tradeDecoder =
    decode Trade
        |> required "id" stringIntDecoder
        |> required "date" date
        |> required "rate" float
        |> required "amount" float
        |> required "total" float
        |> required "fee" float
        |> required "orderNumber" stringIntDecoder
        |> required "tradeType" tradeType
        |> required "category" tradeCategory
        |> required "pairId" string
