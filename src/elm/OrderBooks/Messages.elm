module OrderBooks.Messages exposing (..)

import Http exposing (Error)

import OrderBooks.Models exposing (OrderBook)
import Pairs.Models exposing (PairId)


type Msg
    = GetOrderBook PairId Int
    | RecieveOrderBook (Result Http.Error (OrderBook))
