module OrderBooks.Models exposing (..)


import Pairs.Models exposing (PairId)


type alias Model =
  { orderBook : Maybe OrderBook
  }

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

initialModel : Model
initialModel =
    { orderBook = Nothing
    }
