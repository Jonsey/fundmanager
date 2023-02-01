module Data.ExchangeInfo exposing (ExchangeInfo, decoder)


import Data.Pair exposing (PairId)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)


type alias ExchangeInfo =
    { pairId: PairId
    , precision: Float
    , tickSize: Float
    , minQuantity: Float
    , stepSize: Float
    }



decoder : Decoder ExchangeInfo
decoder =
      decode ExchangeInfo
        |> required "pairId" string
        |> required "precision" float
        |> required "tickSize" float
        |> required "minQuantity" float
        |> required "stepSize" float
