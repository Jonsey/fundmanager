module Utils.Decoders exposing (..)

import Date exposing (Date)
import Json.Decode exposing (..)
import Trades.Models exposing (TradeType(..), TradeCategory(..))


-- import Analysis.Models exposing (FlagType(..))


stringIntDecoder : Decoder Int
stringIntDecoder =
    map (\str -> String.toInt (str) |> Result.withDefault 0) string


dateFromTimeStamp : Decoder Date
dateFromTimeStamp =
    let
        convert : Float -> Decoder Date
        convert raw =
            succeed (Date.fromTime raw)
    in
        float |> andThen convert


date : Decoder Date
date =
    let
        convert : String -> Decoder Date
        convert raw =
            case Date.fromString raw of
                Ok date ->
                    succeed date

                Err error ->
                    fail error
    in
        string |> andThen convert


tradeType : Decoder TradeType
tradeType =
    let
        convert : String -> Decoder TradeType
        convert raw =
            case raw of
                "buy" ->
                    succeed Buy

                "sell" ->
                    succeed Sell

                _ ->
                    fail ""
    in
        string |> andThen convert


tradeCategory : Decoder TradeCategory
tradeCategory =
    let
        convert : String -> Decoder TradeCategory
        convert raw =
            case raw of
                "exchange" ->
                    succeed Exchange

                "margin" ->
                    succeed Margin

                _ ->
                    fail ""
    in
        string |> andThen convert



-- flagType : Decoder FlagType
-- flagType =
--     let
--         convert : String -> Decoder FlagType
--         convert raw =
--             case raw of
--                 "morning_star" ->
--                     succeed MorningStar
--                 "doji_star" ->
--                     succeed DojiStar
--                 "bullish_engulfing" ->
--                     succeed BullishEngulfing
--                 "bullish_marubozu" ->
--                     succeed BullishMarubozu
--                 "break_out" ->
--                     succeed Breakout
--                 "oversold" ->
--                     succeed Oversold
--                 _ ->
--                     fail ""
--     in
--         string |> andThen convert
