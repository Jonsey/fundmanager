module Request.Trade exposing (..)

import Data.Order exposing (OrderId)
import Data.Pair exposing (PairId)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Request.Helpers exposing (apiUrl, nodeApiUrl)


requestTradeHistory : PairId -> Int -> Http.Request ()
requestTradeHistory pairId limit =
    let
        queryParams =
            [ ( "pairId", pairId )
            , ( "limit", toString limit )
            , ( "price", toString price )
            ]
    in
        apiUrl "/binance/order/"
            |> HttpBuilder.get
            |> HttpBuilder.withQueryParams queryParams
            |> HttpBuilder.toRequest
