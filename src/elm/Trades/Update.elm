module Trades.Update exposing (update)

import Data.Session exposing (Session)
import Trades.Commands exposing (getTradeHistory, getAllTradeHistory)
import Trades.Messages exposing (Msg(..))
import Trades.Models exposing (Model, Trade, TradeType(..))
import Utils.IntegerModelUtils exposing (insertOrUpdateById, removeById)


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetTradeHistory pairId start end limit ->
            ( model, getTradeHistory pairId start end limit )

        GetAllTradeHistory start end limit ->
            ( model, getAllTradeHistory start end limit )

        OnReceiveTrade trade ->
            let
                updatedModel =
                    case trade.tradeType of
                        Buy ->
                            let
                                openTrades =
                                    insertOrUpdateById trade model.openTrades

                                openedTrades =
                                    insertOrUpdateById trade model.openedTrades

                                totalProfit =
                                    calcTotalProfit openTrades openedTrades model.closedTrades
                            in
                                { model | totalProfit = totalProfit, openTrades = openTrades, openedTrades = openedTrades }

                        Sell ->
                            let
                                closedTrades =
                                    insertOrUpdateById trade model.closedTrades

                                openTrades =
                                    List.filter (\n -> (n.pairId /= trade.pairId)) model.openTrades

                                totalProfit =
                                    calcTotalProfit openTrades model.openedTrades closedTrades
                            in
                                { model | totalProfit = totalProfit, closedTrades = closedTrades, openTrades = openTrades }
            in
                ( updatedModel, Cmd.none )


calcTotalProfit : List Trade -> List Trade -> List Trade -> Float
calcTotalProfit openTrades openedTrades closedTrades =
    let
        openValue =
            List.foldr (\trade total -> total + trade.total) 0 openTrades

        openedValue =
            List.foldr (\trade total -> total + trade.total) 0 openedTrades

        closedValue =
            List.foldr (\trade total -> total + trade.total) 0 closedTrades
    in
        closedValue - openedValue
