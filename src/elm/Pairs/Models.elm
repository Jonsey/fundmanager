module Pairs.Models exposing (..)


type alias PairId =
    String

type alias Pair =
    { id : PairId
    , name : String
    , last : Float
    , lowestAsk : Float
    , highestBid : Float
    , percentChange : Float
    , percentVolumeChange : Float
    , baseVolume : Float
    , quoteVolume : Float
    , isFrozen : Bool
    , dayHigh : Float
    , dayLow : Float
    , colour : String
    }

type SortingCriteria
    = Name
    | Last
    | Change

type SortingDirection
    = NotSet
    | Asc
    | Desc


type alias Model =
    { pairs : List Pair
    , sortCriteria : SortingCriteria
    , sortDirection : SortingDirection
    }

initialModel : Model
initialModel =
    { pairs = []
    , sortCriteria = Change
    , sortDirection = NotSet
    }
