module Pairs.Messages exposing (..)


import Pairs.Models exposing (Pair, PairId, SortingCriteria)
import Tickers.Models exposing (Ticker)



type Msg
    = NoOp
    | OnReceiveTicker Ticker
    | SortPairsBy SortingCriteria
