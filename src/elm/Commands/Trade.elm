module Commands.Trade exposing (closeTradeAtMarket)

import Data.Order exposing (Order)
import Data.Pair exposing (PairId)
import Data.Trade exposing (Trade)
import Http exposing (Request, toTask)
import Request.Order exposing (requestCloseOrder, requestCloseOrderMarket)
import Task exposing (Task, andThen, succeed)
import Utils.Ordering exposing (maybeGetOpenOrder)


closeTradeAtMarket : PairId -> List Data.Order.Order -> List Trade -> Task Http.Error ()
closeTradeAtMarket pairId openOrders openTrades =
    let
        closeOrderRequest =
            maybeCloseOrderRequest pairId openOrders

        openTradesForPair =
            List.filter (\trade -> trade.pairId == pairId) openTrades

        sumQuantity trade total =
            trade.quantity + total

        quantity =
            List.foldr sumQuantity 0 openTradesForPair

        closeOrderTask =
            case closeOrderRequest of
                Just request ->
                    request |> Http.toTask

                Nothing ->
                    Task.succeed ()

        closeTradeTask =
            requestCloseOrderMarket pairId quantity
                |> Http.toTask
    in
        closeOrderTask
            |> Task.andThen
                (\x -> closeTradeTask)


maybeCloseOrderRequest : Data.Pair.PairId -> List Data.Order.Order -> Maybe (Http.Request ())
maybeCloseOrderRequest pairId openOrders =
    let
        maybeOpenOrder =
            maybeGetOpenOrder pairId openOrders

        closeOrderRequest =
            case maybeOpenOrder of
                Just order ->
                    Just (requestCloseOrder order.id pairId)

                Nothing ->
                    Nothing
    in
        closeOrderRequest
