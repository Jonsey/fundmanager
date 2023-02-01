module Request.Order
    exposing
        ( requestCloseOrder
        , requestCloseOrderMarket
        , requestOrder
        , requestLimitOrder
        , requestStopOrder
        )

import Data.Order exposing (OrderId)
import Data.Pair exposing (PairId)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Request.Helpers exposing (apiUrl, nodeApiUrl)


requestOrder : PairId -> Float -> Float -> Http.Request ()
requestOrder pairId amount price =
    let
        queryParams =
            [ ( "side", "BUY" )
            , ( "pairId", pairId )
            , ( "amount", toString amount )
            , ( "price", toString price )
            ]
    in
        apiUrl "/binance/order/"
            |> HttpBuilder.get
            |> HttpBuilder.withQueryParams queryParams
            |> HttpBuilder.toRequest


requestCloseOrderMarket : PairId -> Float -> Http.Request ()
requestCloseOrderMarket pairId quantity =
    let
        queryParams =
            [ ( "quantity", toString quantity )
            , ( "pairId", pairId )
            ]
    in
        nodeApiUrl "/binance/order/close/market"
            |> HttpBuilder.get
            |> HttpBuilder.withQueryParams queryParams
            |> HttpBuilder.toRequest


requestCloseOrder : OrderId -> PairId -> Http.Request ()
requestCloseOrder orderId pairId =
    let
        queryParams =
            [ ( "orderId", toString orderId )
            , ( "pairId", pairId )
            ]
    in
        nodeApiUrl "/binance/order/close"
            |> HttpBuilder.get
            |> HttpBuilder.withQueryParams queryParams
            |> HttpBuilder.toRequest


requestStopOrder : PairId -> Float -> Float -> Http.Request ()
requestStopOrder pairId amount price =
    let
        queryParams =
            [ ( "pairId", pairId )
            , ( "amount", toString amount )
            , ( "price", toString price )
            ]
    in
        nodeApiUrl "/binance/stop/"
            |> HttpBuilder.get
            |> HttpBuilder.withQueryParams queryParams
            |> HttpBuilder.toRequest


requestLimitOrder : PairId -> Float -> Float -> Http.Request ()
requestLimitOrder pairId amount price =
    let
        queryParams =
            [ ( "pairId", pairId )
            , ( "amount", toString amount )
            , ( "price", toString price )
            ]
    in
        nodeApiUrl "/binance/limit/"
            |> HttpBuilder.get
            |> HttpBuilder.withQueryParams queryParams
            |> HttpBuilder.toRequest
