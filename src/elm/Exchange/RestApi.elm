module Exchange.RestApi exposing (..)

import Http
import HttpBuilder exposing (RequestBuilder, withExpect, withQueryParams)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)

import Pairs.Models exposing (PairId)
import OrderBooks.Models exposing (OrderBook, Bid, Ask)




getCurrencyOrderBook : PairId -> Int -> Http.Request OrderBook
getCurrencyOrderBook pairId depth =
    let
        url = "https://poloniex.com/public?command=returnOrderBook&"
            ++ "currencyPair="
            ++ pairId
            ++ "&depth="
            ++ toString depth
    in
        url
            |> HttpBuilder.get
            |> HttpBuilder.withExpect (Http.expectJson (orderBookDecoder pairId))
            |> HttpBuilder.toRequest


orderBookDecoder : PairId -> Decoder OrderBook
orderBookDecoder pairId =
    decode OrderBook
      |> hardcoded pairId
      |> required "bids" (list bidsDecoder)
      |> required "asks" (list asksDecoder)
      |> required "isFrozen" string
      |> required "seq" int


bidsDecoder : Decoder Bid
bidsDecoder =
    map2 Bid
      (index 0 stringToFloatDecoder)
      (index 1 float)


asksDecoder : Decoder Ask
asksDecoder =
    map2 Ask
      (index 0 stringToFloatDecoder)
      (index 1 float)

stringToFloatDecoder : Decoder Float
stringToFloatDecoder =
    (string)
    |> andThen (\val ->
        case String.toFloat val of
          Ok f -> succeed f
          Err e -> fail e)
