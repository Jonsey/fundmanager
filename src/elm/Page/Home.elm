module Page.Home exposing (Model, Msg, view, update, init, subscriptions)

import Commands.Trade exposing (closeTradeAtMarket)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (Error, getString, send)
import Json.Decode as Decode exposing (Value)
import Round exposing (round)
import Time exposing (Time)
import Task exposing (Task)
import Ports
    exposing
        ( drawChart
        , analysisReceived
        , requestTicker
        , requestAccountInfo
        , tickerReceived
        , tradeReceived
        , orderReceived
        , accountInfoRecieved
        )
import Tickers.Utils.Mapper exposing (mapTicker)
import Request.Home exposing (getExchangeInfo)
import Request.Order exposing (requestCloseOrder, requestOrder, requestLimitOrder, requestStopOrder)
import Data.Analysis exposing (Analysis, FlagType(..), decodeModel)
import Data.AccountInfo as AccountInfo exposing (Msg(..), AccountInfo, Balance, mapBalances)
import Data.ExchangeInfo as ExchangeInfo exposing (ExchangeInfo)
import Data.Order exposing (Order, OrderId, Margin(..), decoder)
import Data.Pair exposing (Pair, PairId)
import Data.Session exposing (Session)
import Data.Trade as Trade exposing (Trade, TradeType(..), decoder)
import OrderBooks.Messages exposing (Msg)
import Tickers.Messages exposing (Msg)
import Views.Analysis as Analysis exposing (view)
import Views.Trader as Trader exposing (view)
import OrderBooks.Models exposing (Model, initialModel)
import Tickers.Models exposing (Ticker, Model, initialModel)
import Trades.Messages exposing (Msg(..))
import Views.Analysis as Analysis
import Views.Analysis.CurrencySelector as CurrencySelector
import Views.Page as Page
import OrderBooks.Messages exposing (Msg(..))
import OrderBooks.Update exposing (update)
import Tickers.Update exposing (update)
import Page.Errored exposing (PageLoadError, pageLoadError)
import Utils.Analysis
    exposing
        ( breakouts
        , volumeBreakouts
        , bullishMarubozus
        , bullishEngulfings
        , clearOldItems
        , insertOrUpdate
        , isBreakout
        , isBullishEngulfing
        , isVolumeBreakout
        , handleAnalysisReceived
        , triggersForPair
        )
import Utils.Analysis.ChartData exposing (getChartDataCommands)
import Utils.Balances exposing (currentAssetBalance)
import Utils.TraderUtils
    exposing
        ( calculateTradeAmount
        , getOpenLimitOrder
        , getOpenTrade
        , formatToCorrectPrecision
        , shouldPlaceStopLoss
        , limitPrice
        , stopPrice
        )
import Utils.Ordering exposing (orderReceived)
import Utils.Format exposing (truncateFloat)


type Msg
    = NoOp
    | GetChartData String
    | ChartDataResult (Result Http.Error String)
    | ToggleFavourite PairId
    | SelectCurrency String
    | SetOrderAmount Float
    | SetMargin Data.Order.Margin Float
    | PlaceOrder
    | PlaceOrderResult (Result Http.Error Trade)
    | PlaceLimitOrderResult (Result Http.Error ())
    | PlaceStopOrderResult (Result Http.Error ())
    | CancelOrder Data.Order.Order
    | CancelOrderResult (Result Http.Error ())
    | CloseTradeAtMarket PairId
    | CloseTradeAtMarketResult (Result Http.Error ())
    | OnReceiveAnalysis Analysis
    | OnReceiveTrade Trade
    | OnReceiveOrder Data.Order.Order
    | OrderBooksMsg OrderBooks.Messages.Msg
    | TickersMsg Tickers.Messages.Msg
    | TradesMsg Trades.Messages.Msg
    | AccountInfoMsg AccountInfo.Msg


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Sub.map TickersMsg (tickerReceived mapTicker)
        , Sub.map AccountInfoMsg (accountInfoRecieved mapBalances)
        , Ports.analysisReceived decodeAnalysis
        , Ports.tradeReceived decodeTrade
        , Ports.orderReceived decodeOrder
        ]


decodeAnalysis : Value -> Msg
decodeAnalysis modelJson =
    case (Data.Analysis.decodeModel modelJson) of
        Ok analysis ->
            OnReceiveAnalysis analysis

        Err errorMessage ->
            let
                _ =
                    Debug.log "Error in map analysis:" errorMessage
            in
                NoOp


decodeTrade : Value -> Msg
decodeTrade modelJson =
    case (Decode.decodeValue Trade.decoder modelJson) of
        Ok trade ->
            OnReceiveTrade trade

        Err errorMessage ->
            let
                _ =
                    Debug.log "Error in map trade:" errorMessage
            in
                NoOp


decodeOrder : Value -> Msg
decodeOrder modelJson =
    case (Decode.decodeValue Data.Order.decoder modelJson) of
        Ok trade ->
            OnReceiveOrder trade

        Err errorMessage ->
            let
                _ =
                    Debug.log "Error in map order:" errorMessage
            in
                NoOp



-- Model


type alias TradesModel =
    { openTrades : List Trade
    , closedTrades : List Trade
    , daysAccProfit : Float
    }


type alias Model =
    { selectedCurrency : String
    , infoText : String
    , orderAmountPercentage : Float
    , profitMargin : Float
    , lossMargin : Float
    , orderBooksModel : OrderBooks.Models.Model
    , exchangeAnalysis : List Data.Analysis.Analysis
    , tickersModel : Tickers.Models.Model
    , trades : TradesModel
    , orders : List Data.Order.Order
    , favourites : Dict PairId String
    , exchangeInfo : List ExchangeInfo
    , accountInfo : AccountInfo
    }


initTradesModel : TradesModel
initTradesModel =
    { openTrades = []
    , closedTrades = []
    , daysAccProfit = 0.0
    }


init : Session -> Task PageLoadError Model
init session =
    let
        loadExchangeInfo =
            Request.Home.getExchangeInfo
                |> Http.toTask

        loadAccountInfo =
            Request.Home.getAccountInfo
                |> Http.toTask

        loadAnalysis =
            []

        loadTicker =
            Tickers.Models.initialModel

        loadOrderBooks =
            OrderBooks.Models.initialModel

        trades =
            initTradesModel

        orders =
            []

        defaultOrderPercentage =
            25

        defaultProfitMargin =
            0.25

        defaultLossMargin =
            2

        favourites =
            Dict.empty

        initialStaticModel =
            Model
                ""
                ""
                defaultOrderPercentage
                defaultProfitMargin
                defaultLossMargin
                loadOrderBooks
                loadAnalysis
                loadTicker
                trades
                orders
                favourites

        handleLoadError err =
            pageLoadError Page.Home ("Homepage is currently unavailable." ++ (toString err))
    in
        Task.map2 initialStaticModel loadExchangeInfo loadAccountInfo
            |> Task.mapError handleLoadError



-- VIEW


listToDict : (a -> comparable) -> List a -> Dict.Dict comparable a
listToDict getKey values =
    Dict.fromList (List.map (\v -> ( getKey v, v )) values)


view : Model -> Html Msg
view model =
    let
        currentTicker =
            Dict.get model.selectedCurrency model.tickersModel.tickers

        exchangeInfoDict =
            listToDict .pairId model.exchangeInfo

        currentTickerExchangeInfo =
            Dict.get model.selectedCurrency exchangeInfoDict

        btcBalance =
            currentAssetBalance model.accountInfo.balances "BTC"

        bnbBalance =
            currentAssetBalance model.accountInfo.balances "BNB"

        tradeAmount =
            case currentTickerExchangeInfo of
                Just exchangeInfo ->
                    case currentTicker of
                        Just ticker ->
                            calculateTradeAmount model.orderAmountPercentage exchangeInfo btcBalance ticker

                        Nothing ->
                            0.0

                Nothing ->
                    0

        openTrades =
            model.trades.openTrades
    in
        div [ class "home-page" ]
            [ div [ class "home-page__content" ]
                [ div [ class "home-page__content__analysis" ]
                    [ CurrencySelector.view model.selectedCurrency GetChartData SelectCurrency
                    , Analysis.view GetChartData ToggleFavourite model.exchangeAnalysis model.favourites
                    ]
                , div [ class "home-page__content__charts" ]
                    [ currentPrice currentTicker model.accountInfo
                    , div [ class "" ]
                        [ div [ class "", id "chart-1m" ]
                            [ text "" ]
                        , div [ class "", id "chart-5m" ]
                            [ text "" ]
                        , div [ class "", id "chart-15m" ]
                            [ text "" ]
                        , div [ class "", id "chart-1h" ]
                            [ text "" ]
                        ]
                    ]
                , div [ class "home-page__content__trade" ]
                    [ balances btcBalance bnbBalance
                    , Trader.view tradeAmount SetMargin model.lossMargin model.profitMargin model.orderAmountPercentage SetOrderAmount PlaceOrder
                    , openTradesList openTrades model.tickersModel.tickers
                    , openOrdersView model.orders
                    ]
                ]
            ]


openOrdersView : List Data.Order.Order -> Html Msg
openOrdersView orders =
    section [ class "" ]
        [ openOrdersList (List.map (\order -> orderItemView order) orders)
        ]


openOrdersList : List (Html Msg) -> Html Msg
openOrdersList body =
    section [ class "" ]
        [ table
            [ class ""
            ]
            [ thead []
                [ tr []
                    [ th [ class "" ] [ text "Pair" ]
                    , th [ class "" ] [ text "Qty" ]
                    , th [ class "" ] [ text "Price" ]
                    , th [] []
                    ]
                ]
            , tbody [] body
            ]
        ]


orderItemView : Data.Order.Order -> Html Msg
orderItemView order =
    tr []
        [ td [ class "" ] [ text order.pairId ]
        , td [ class "" ] [ text (toString order.quantity) ]
        , td [ class "" ] [ text (toString order.price) ]
        , td [] [ a [ onClick (CancelOrder order) ] [ text "X" ] ]
        ]


openTradesList : List Trade -> Dict Tickers.Models.TickerId Ticker -> Html Msg
openTradesList trades tickers =
    let
        highestBid : String -> Float
        highestBid pairId =
            case Dict.get pairId tickers of
                Just ticker ->
                    ticker.highestBid

                Nothing ->
                    0
    in
        section [ class "" ]
            [ table
                [ class ""
                ]
                [ thead []
                    [ tr []
                        [ th [ class "" ] [ text "Pair" ]
                        , th [ class "" ] [ text "Open" ]
                        , th [ class "" ] [ text "Profit" ]
                        ]
                    ]
                , tbody [] (List.map (\x -> tradeItemView x (highestBid x.pairId)) trades)
                ]
            ]


tradeItemView : Trade -> Float -> Html Msg
tradeItemView trade currentPrice =
    let
        profit =
            calculateUnrealisedProfit trade currentPrice

        percentProfit =
            truncateFloat (((currentPrice - trade.price) / trade.price) * 100) (1 / 0.01)
    in
        tr []
            [ td [ class "" ] [ text trade.pairId ]
            , td [ class "" ] [ text (toString trade.price) ]
            , td [ class "" ] [ text ((toString percentProfit) ++ "%") ]
            , td [] [ a [ onClick (CloseTradeAtMarket trade.pairId) ] [ text "X" ] ]
            ]


calculateUnrealisedProfit : Trade -> Float -> Float
calculateUnrealisedProfit trade currentPrice =
    trade.quantity * (currentPrice - trade.price)


currentPrice : Maybe Ticker -> AccountInfo -> Html msg
currentPrice currentTicker accountInfo =
    let
        spread low high =
            Round.round 2 (((high - low) / ((low + high) / 2)) * 100)
    in
        case currentTicker of
            Just t ->
                div [ class "" ]
                    [ div [ class "" ] [ text ("ASK: " ++ (toString t.lowestAsk)) ]
                    , div [ class "" ] [ text ("BID: " ++ (toString t.highestBid)) ]
                    , div [ class "" ] [ text ("Spread: " ++ (spread t.highestBid t.lowestAsk) ++ "%") ]
                    ]

            Nothing ->
                div [] []


balances : Float -> Float -> Html Msg
balances btcBalance bnbBalance =
    div [ class "account-balances" ]
        [ div []
            [ text ("Available BTC: " ++ (toString btcBalance)) ]
        , div []
            [ text ("Available BNB: " ++ (toString bnbBalance)) ]
        ]


list : List Pair -> Html Msg
list pairs =
    ul [ class "" ] (List.map pairRow pairs)


pairRow : Pair -> Html Msg
pairRow pair =
    li [ class "" ] [ a [ onClick (GetChartData pair.id) ] [ text pair.name ] ]



-- UPDATE


update : Session -> Time -> Msg -> Model -> ( Model, Cmd Msg )
update session time msg model =
    case msg of
        GetChartData id ->
            let
                chartDataCommands =
                    getChartDataCommands id ChartDataResult

                cmd6 =
                    requestTicker id
            in
                ( { model | selectedCurrency = id }, Cmd.batch <| chartDataCommands ++ [ cmd6 ] )

        ChartDataResult (Ok result) ->
            ( model, drawChart result )

        ChartDataResult (Err err) ->
            ( model, Cmd.none )

        ToggleFavourite pairId ->
            let
                updateFavourites =
                    Dict.insert pairId "" model.favourites
            in
                ( { model | favourites = updateFavourites }, Cmd.none )

        SelectCurrency currency ->
            let
                pairId =
                    (String.toUpper currency) ++ "BTC"
            in
                ( { model | selectedCurrency = pairId }, Cmd.none )

        SetOrderAmount percentage ->
            ( { model | orderAmountPercentage = percentage }, Cmd.none )

        SetMargin marginType margin ->
            let
                updatedModel =
                    case marginType of
                        Profit ->
                            { model | profitMargin = margin }

                        Loss ->
                            { model | lossMargin = margin }
            in
                ( updatedModel, Cmd.none )

        PlaceOrder ->
            let
                currentTicker =
                    Dict.get model.selectedCurrency model.tickersModel.tickers

                btcBalance =
                    currentAssetBalance model.accountInfo.balances "BTC"

                exchangeInfoDict =
                    listToDict .pairId model.exchangeInfo

                currentTickerExchangeInfo =
                    Dict.get model.selectedCurrency exchangeInfoDict

                amount =
                    case currentTickerExchangeInfo of
                        Just exchangeInfo ->
                            case currentTicker of
                                Just ticker ->
                                    calculateTradeAmount model.orderAmountPercentage exchangeInfo btcBalance ticker

                                Nothing ->
                                    0.0

                        Nothing ->
                            0

                price =
                    case currentTicker of
                        Just ticker ->
                            ticker.lowestAsk

                        Nothing ->
                            0.0

                url =
                    "http://localhost:3000/binance/order?"
                        ++ "side="
                        ++ "BUY"
                        ++ "&pairId="
                        ++ model.selectedCurrency
                        ++ "&amount="
                        ++ (toString amount)
                        ++ "&price="
                        ++ (toString price)

                request =
                    Http.get url Trade.decoder

                cmd =
                    Http.send PlaceOrderResult request
            in
                ( model, cmd )

        PlaceOrderResult (Ok result) ->
            let
                resp =
                    "Place order result: " ++ result.pairId
            in
                ( { model | infoText = resp }, Cmd.none )

        PlaceOrderResult (Err err) ->
            ( model, Cmd.none )

        PlaceStopOrderResult (Ok result) ->
            let
                _ =
                    Debug.log "Place stop order result: " result
            in
                ( model, Cmd.none )

        PlaceStopOrderResult (Err err) ->
            ( model, Cmd.none )

        CloseTradeAtMarket pairId ->
            let
                orders =
                    model.orders

                trades =
                    model.trades.openTrades

                cmd =
                    closeTradeAtMarket pairId orders trades
                        |> Task.attempt CloseTradeAtMarketResult
            in
                ( model, cmd )

        CloseTradeAtMarketResult (Ok result) ->
            let
                updatedModel =
                    { model | infoText = "Close trade at market request sent" }
            in
                ( updatedModel, Cmd.none )

        CloseTradeAtMarketResult (Err err) ->
            let
                updatedModel =
                    { model | infoText = "Close trade at market request failed" }
            in
                ( updatedModel, Cmd.none )

        OnReceiveOrder order ->
            let
                updatedOrders =
                    Utils.Ordering.orderReceived order model.orders
            in
                ( { model | orders = updatedOrders }, Cmd.none )

        OnReceiveTrade trade ->
            let
                addToOpenTrades trade openTrades =
                    trade :: openTrades

                removeFromOpenTrades trade openTrades =
                    List.filter (\n -> (n.pairId /= trade.pairId)) openTrades

                openTrades =
                    case trade.tradeType of
                        Buy ->
                            addToOpenTrades trade model.trades.openTrades

                        Sell ->
                            removeFromOpenTrades trade model.trades.openTrades

                setOpenTrades : List Trade -> TradesModel -> TradesModel
                setOpenTrades openTrades tradesModel =
                    { tradesModel | openTrades = openTrades }

                asOpenTradesIn : TradesModel -> List Trade -> TradesModel
                asOpenTradesIn =
                    flip setOpenTrades

                updatedTrades =
                    openTrades
                        |> asOpenTradesIn model.trades

                updatedOrders =
                    Utils.Ordering.removeFromOpenOrders trade.orderId model.orders

                cmd =
                    case trade.tradeType of
                        Buy ->
                            let
                                exchangeInfoDict =
                                    listToDict .pairId model.exchangeInfo

                                currentTickerExchangeInfo =
                                    Dict.get model.selectedCurrency exchangeInfoDict
                            in
                                case currentTickerExchangeInfo of
                                    Just exchangeInfo ->
                                        placeLimitOrder trade exchangeInfo.tickSize model.profitMargin
                                            |> Http.send PlaceLimitOrderResult

                                    Nothing ->
                                        Cmd.none

                        Sell ->
                            Cmd.none
            in
                ( { model | trades = updatedTrades, orders = updatedOrders }, cmd )

        CancelOrder order ->
            let
                cmd =
                    requestCloseOrder order.id order.pairId
                        |> Http.send CancelOrderResult
            in
                ( model, cmd )

        CancelOrderResult (Ok result) ->
            let
                updatedModel =
                    { model | infoText = "Close order request sent" }
            in
                ( updatedModel, Cmd.none )

        CancelOrderResult (Err err) ->
            let
                updatedModel =
                    { model | infoText = "Cancel order request failed" }
            in
                ( updatedModel, Cmd.none )

        PlaceLimitOrderResult (Ok order) ->
            let
                _ =
                    Debug.log "Place order result: " order
            in
                ( model, Cmd.none )

        PlaceLimitOrderResult (Err err) ->
            ( model, Cmd.none )

        OrderBooksMsg subMsg ->
            let
                ( updatedOrderBooksModel, cmd ) =
                    OrderBooks.Update.update subMsg model.orderBooksModel
            in
                ( { model | orderBooksModel = updatedOrderBooksModel }, Cmd.map OrderBooksMsg cmd )

        OnReceiveAnalysis analysis ->
            let
                sortedAnalysis =
                    handleAnalysisReceived analysis time model.exchangeAnalysis

                updatedModel =
                    { model | exchangeAnalysis = sortedAnalysis }
            in
                ( updatedModel, Cmd.none )

        TickersMsg subMsg ->
            let
                ( updatedTickersModel, cmd ) =
                    Tickers.Update.update subMsg model.tickersModel

                cmd1 =
                    case subMsg of
                        Tickers.Messages.OnReceiveTicker ticker ->
                            let
                                maybeOpenTrade =
                                    getOpenTrade model.trades.openTrades ticker.id
                            in
                                case maybeOpenTrade of
                                    Just openTrade ->
                                        checkClosingOrders ticker.highestBid model.lossMargin ticker.id model.orders openTrade model.exchangeInfo

                                    Nothing ->
                                        Cmd.none

                        _ ->
                            Cmd.none
            in
                ( { model | tickersModel = updatedTickersModel }, cmd1 )

        AccountInfoMsg subMsg ->
            case subMsg of
                AccountInfoRecieved accountInfo ->
                    ( { model | accountInfo = accountInfo }, Cmd.none )

                AccountInfo.NoOp ->
                    ( model, Cmd.none )

        TradesMsg subMsg ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


closeLosingTrade : List Data.Order.Order -> Trade -> Float -> Float -> Cmd Msg
closeLosingTrade openLimitOrders trade tickSize lossMargin =
    let
        closeLimitOrderRequest =
            closeOrderRequest openLimitOrders trade.pairId

        closeLimitOrderTask =
            case closeLimitOrderRequest of
                Just request ->
                    request |> Http.toTask

                Nothing ->
                    Task.succeed ()

        requestStopLossTask =
            placeStopLossOrder trade tickSize lossMargin
                |> Http.toTask
    in
        closeLimitOrderTask
            |> Task.andThen
                (\x -> requestStopLossTask)
            |> Task.attempt PlaceStopOrderResult


checkClosingOrders : Float -> Float -> Data.Pair.PairId -> List Data.Order.Order -> Trade -> List ExchangeInfo -> Cmd Msg
checkClosingOrders currentPrice lossMargin selectedCurrency openOrders openTrade exchangeInfoList =
    let
        pairId =
            openTrade.pairId

        exchangeInfoDict =
            listToDict .pairId exchangeInfoList

        currentTickerExchangeInfo =
            Dict.get pairId exchangeInfoDict

        checkShouldCloseLosing =
            shouldPlaceStopLoss
                openOrders
                pairId
                currentPrice
                openTrade.price
                lossMargin
    in
        case currentTickerExchangeInfo of
            Just exchangeInfo ->
                case (checkShouldCloseLosing) of
                    ( True, stopLoss ) ->
                        closeLosingTrade
                            openOrders
                            openTrade
                            exchangeInfo.tickSize
                            lossMargin

                    ( _, _ ) ->
                        Cmd.none

            Nothing ->
                Cmd.none


placeLimitOrder : Trade -> Float -> Float -> Http.Request ()
placeLimitOrder trade tickSize profitMargin =
    let
        price =
            limitPrice trade.price profitMargin tickSize
    in
        requestLimitOrder
            trade.pairId
            trade.quantity
            price


closeOrderRequest : List Data.Order.Order -> Data.Pair.PairId -> Maybe (Http.Request ())
closeOrderRequest openOrders pairId =
    let
        openLimitOrder =
            List.filter (\x -> x.pairId == pairId) openOrders |> List.head

        closeExisitingLimitOrderRequest =
            case openLimitOrder of
                Just order ->
                    Just (requestCloseOrder order.id pairId)

                Nothing ->
                    Nothing
    in
        closeExisitingLimitOrderRequest


placeStopLossOrder : Trade -> Float -> Float -> Http.Request ()
placeStopLossOrder trade tickSize lossMargin =
    let
        price =
            stopPrice trade.price lossMargin tickSize

        stopOrderRequest =
            requestStopOrder
                trade.pairId
                trade.quantity
                price
    in
        stopOrderRequest
