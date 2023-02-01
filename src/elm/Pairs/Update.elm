module Pairs.Update exposing (..)



import Pairs.Messages exposing (Msg(..))
import Pairs.Models exposing (Model, Pair, SortingCriteria(..), SortingDirection(..))
import Pairs.Utils.Sorter exposing (sortBy)
import Pairs.Utils.TickerMapper exposing (insertOrUpdateById)




update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        NoOp ->
            ( model, Cmd.none )

        OnReceiveTicker ticker ->
            let
                pairs =
                    Pairs.Utils.TickerMapper.insertOrUpdateById ticker model.pairs
            in
                ( { model | pairs = pairs } , Cmd.none )

        SortPairsBy sortingCriteria ->
          let
              updatedModel sortFun =
                  case model.sortDirection of
                      NotSet ->
                          { model | pairs = sortFun, sortDirection = Asc }
                      Asc ->
                          { model | pairs = sortFun, sortDirection = Desc }
                      Desc ->
                          { model | pairs = List.reverse sortFun, sortDirection = Asc }

          in
              ( updatedModel (sortBy sortingCriteria model.pairs), Cmd.none )
