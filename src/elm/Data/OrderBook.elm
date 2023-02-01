module Data.OrderBook exposing (OrderBook)

import Data.Pair exposing (PairId)


type alias Bid =
    { price : Float
    , amount : Float
    }


type alias Ask =
    { price : Float
    , amount : Float
    }


type alias OrderBook =
    { pairId : PairId
    , asks : List Ask
    , bids : List Bid
    , isFrozen : String
    , seq : Int
    }
