module Data.Analysis exposing (..)

import Tickers.Models exposing (TickerId)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)


type FlagType
    = MorningStar
    | DojiStar
    | BullishEngulfing
    | BullishMarubozu
    | BullishDoji
    | Breakout
    | Oversold
    | VolumeBreakout
    | BreakoutPullback
    | TopRiser


type alias Analysis =
    { pairId : TickerId
    , date : Int
    , flagType : FlagType
    , candlePeriod : Int
    }



-- Serialization


flagType : Decoder FlagType
flagType =
    let
        convert : String -> Decoder FlagType
        convert raw =
            case raw of
                "morning_star" ->
                    succeed MorningStar

                "doji_star" ->
                    succeed DojiStar

                "bullish_engulfing" ->
                    succeed BullishEngulfing

                "bullish_marubozu" ->
                    succeed BullishMarubozu

                "break_out" ->
                    succeed Breakout

                "volume_breakout" ->
                    succeed VolumeBreakout

                "breakout_pullback" ->
                    succeed BreakoutPullback

                "oversold" ->
                    succeed Oversold

                "top_riser" ->
                    succeed TopRiser

                "bullish_doji" ->
                    succeed BullishDoji

                _ ->
                    fail ""
    in
        string |> andThen convert


decodeModel : Value -> Result String Analysis
decodeModel modelJson =
    decodeValue analysisDecoder modelJson


analysisDecoder : Decoder Analysis
analysisDecoder =
    decode Analysis
        |> required "currency" string
        |> required "date" int
        |> required "flagType" flagType
        |> required "candlePeriod" int
