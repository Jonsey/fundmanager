module Utils.TraderUtils
    exposing
        ( calculateTradeAmount
        , getOpenLimitOrder
        , getOpenTrade
        , formatToCorrectPrecision
        , shouldPlaceStopLoss
        , stopPrice
        , limitPrice
        )

import Data.ExchangeInfo as ExchangeInfo exposing (ExchangeInfo)
import Data.Order exposing (Order)
import Data.Pair exposing (PairId)
import Data.Trade exposing (Trade)
import Tickers.Models exposing (Ticker)
import Utils.Format exposing (truncateFloat)


calculateTradeAmount : Float -> ExchangeInfo -> Float -> Ticker -> Float
calculateTradeAmount percentageOfTotalFund assetExchangeInfo currentBalance currentTicker =
    let
        precision =
            1 / assetExchangeInfo.stepSize

        tradeValue =
            (percentageOfTotalFund / 100) * currentBalance

        tradeAmount =
            tradeValue / currentTicker.lowestAsk
    in
        truncateFloat tradeAmount precision


limitPrice : Float -> Float -> Float -> Float
limitPrice tradePrice profitMargin tickSize =
    formatToCorrectPrecision (tradePrice * (1 + (profitMargin / 100))) tickSize


stopPrice : Float -> Float -> Float -> Float
stopPrice tradePrice lossMargin tickSize =
    formatToCorrectPrecision (tradePrice * (1 - (lossMargin / 100))) tickSize


formatToCorrectPrecision : Float -> Float -> Float
formatToCorrectPrecision rawNumber quantum =
    let
        precision =
            1 / quantum
    in
        truncateFloat rawNumber precision


shouldPlaceStopLoss : List Data.Order.Order -> PairId -> Float -> Float -> Float -> ( Bool, Float )
shouldPlaceStopLoss openStopOrders pairId currentPrice openingPrice lossMargin =
    let
        hasExistingStopOrder =
            List.any (\x -> x.pairId == pairId && x.price < currentPrice) openStopOrders

        stopLoss =
            openingPrice * ((100 - lossMargin) / 100)

        atLimit =
            currentPrice <= stopLoss

        result =
            hasExistingStopOrder == False && atLimit
    in
        ( result, stopLoss )


getOpenLimitOrder : List Data.Order.Order -> PairId -> Maybe Data.Order.Order
getOpenLimitOrder openOrders pairId =
    List.filter (\x -> x.pairId == pairId) openOrders |> List.head


getOpenTrade : List Trade -> PairId -> Maybe Trade
getOpenTrade openTrades pairId =
    List.filter (\x -> x.pairId == pairId) openTrades |> List.head
