module Exchange.TradeHistory exposing (..)


import Crypto.HMAC exposing (sha256, sha512)
import Word.Bytes as Bytes
import Word.Hex as Hex

import Http
import HttpBuilder exposing (RequestBuilder, withBody, withHeader, withExpect, withQueryParams)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Json.Encode as Encode
import Time exposing (Time)

import Pairs.Model exposing (PairId)
import Trades.Models exposing (Trade, TradeType(..), TradeCategory(..))


getAllTradeHistory : String -> String -> Int -> Http.Request (List Trade)
getAllTradeHistory start end limit =
    let
        url = "https://poloniex.com/tradingApi"

        body =
            Encode.object
                  [ ("command", Encode.string "returnTradeHistory")
                  , ("currencyPair", Encode.string "all")
                  , ("nonce", Encode.string end)
                  ]

        stringBody =
            Encode.encode 0 body

        jsonBody =
            body |> Http.jsonBody

        sign =
            Crypto.HMAC.digest sha512
                "dgfdgd"
                stringBody
    in
        url
            |> HttpBuilder.post
            |> withHeader "Key" "dgdgd"
            |> withHeader "Sign" sign
            |> withBody jsonBody
            |> HttpBuilder.withExpect (Http.expectJson allMarketsTradeListDecoder)
            |> HttpBuilder.toRequest


getTradeHistory : PairId -> String -> String -> Int -> Http.Request (List Trade)
getTradeHistory pairId start end limit =
    let
        url = "https://poloniex.com/tradingApi"

        body =
            Encode.object
                  [ ("command", Encode.string "returnTradeHistory")
                  , ("currencyPair", Encode.string "all")
                  , ("start", Encode.string start)
                  , ("end", Encode.string end)
                  , ("limit", Encode.int limit)
                  ]
    in
        url
            |> HttpBuilder.post
            |> HttpBuilder.withExpect (Http.expectJson (tradeListDecoder pairId))
            |> HttpBuilder.toRequest


allMarketsTradeListDecoder : Decoder (List Trade)
allMarketsTradeListDecoder =
    decode Trade
      |> required "id" int
      |> required "name" string
      |> required "date" string
      |> required "rate" float
      |> required "amount" float
      |> required "total" float
      |> required "fee" float
      |> required "orderNumber" int
      |> required "tradeType" tradeTypeDecoder
      |> required "category" tradeCategoryDecoder
      |> keyValuePairs
      |> map (\a -> List.map (uncurry (|>)) a)


tradeListDecoder : PairId -> Decoder (List Trade)
tradeListDecoder pairId =
    list (tradeDecoder pairId)


tradeDecoder : PairId -> Decoder Trade
tradeDecoder pairId =
    decode Trade
      |> required "id" int
      |> required "name" string
      |> required "date" string
      |> required "rate" float
      |> required "amount" float
      |> required "total" float
      |> required "fee" float
      |> required "orderNumber" int
      |> required "tradeType" tradeTypeDecoder
      |> required "category" tradeCategoryDecoder
      |> hardcoded pairId


tradeTypeDecoder : Decoder TradeType
tradeTypeDecoder =
    string
        |> andThen (\str ->
           case str of
                "buy" ->
                    decode Buy
                "sell" ->
                    decode Sell
                somethingElse ->
                    fail <| "Unknown trade type: " ++ somethingElse
        )


tradeCategoryDecoder : Decoder TradeCategory
tradeCategoryDecoder =
    string
        |> andThen (\str ->
           case str of
                "exchange" ->
                    decode Exchange
                "margin" ->
                    decode Margin
                somethingElse ->
                    fail <| "Unknown trade category: " ++ somethingElse
        )
