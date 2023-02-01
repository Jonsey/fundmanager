module Data.Trade exposing (Trade, TradeType(..), decoder)

import Date exposing (Date)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Decoders exposing (dateFromTimeStamp, stringIntDecoder)
import Data.Pair exposing (PairId)


type alias TradeId =
    Int


type TradeType
    = Buy
    | Sell


type alias Trade =
    { id : TradeId
    , tradeType : TradeType
    , orderId : Int
    , pairId : PairId
    , price : Float
    , quantity : Float
    , commission : Float
    , commisionAsset : String
    , time : Date
    }


decoder : Decoder Trade
decoder =
    decode Trade
        |> required "id" int
        |> required "side" tradeType
        |> required "orderId" int
        |> required "pairId" string
        |> required "price" float
        |> required "qty" float
        |> required "commission" float
        |> required "commissionAsset" string
        |> required "time" dateFromTimeStamp


tradeType : Decoder TradeType
tradeType =
    let
        convert : String -> Decoder TradeType
        convert raw =
            case raw of
                "BUY" ->
                    succeed Buy

                "SELL" ->
                    succeed Sell

                _ ->
                    fail ""
    in
        string |> andThen convert
