module Utils.Ordering exposing (..)

import Http
import Data.Order exposing (Order, OrderStatus(..))
import Data.Pair exposing (PairId)
import Data.Trade exposing (Trade)
import Request.Order exposing (requestLimitOrder)
import Utils.TraderUtils exposing (formatToCorrectPrecision)


placeLimitOrder : Trade -> Float -> Http.Request ()
placeLimitOrder trade tickSize =
    requestLimitOrder
        trade.pairId
        trade.quantity
        (formatToCorrectPrecision (trade.price * 1.01) tickSize)


maybeGetOpenOrder : PairId -> List Data.Order.Order -> Maybe Data.Order.Order
maybeGetOpenOrder pairId openOrders =
    List.filter (\x -> x.pairId == pairId) openOrders
        |> List.head


orderReceived : Data.Order.Order -> List Data.Order.Order -> List Data.Order.Order
orderReceived order openOrders =
    case order.orderStatus of
        Filled ->
            order :: openOrders

        PartiallyFilled ->
            order :: openOrders

        Canceled ->
            List.filter (\x -> x.id /= order.id) openOrders

        New ->
            order :: openOrders

        _ ->
            openOrders


removeFromOpenOrders : Data.Order.OrderId -> List Data.Order.Order -> List Data.Order.Order
removeFromOpenOrders orderId openOrders =
    List.filter (\x -> x.id /= orderId) openOrders
