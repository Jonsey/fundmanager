module OrderBooks.Update exposing (update)


import Http

import Exchange.RestApi exposing (getCurrencyOrderBook)
import OrderBooks.Messages exposing (Msg(..))
import OrderBooks.Models exposing (Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of

        GetOrderBook pairId depth ->
            ( model, Http.send RecieveOrderBook (getCurrencyOrderBook pairId depth))

        RecieveOrderBook (Ok result) ->
            let
                orderBook =
                  Debug.log (toString result)
            in
                ( { model | orderBook = Just result }, Cmd.none )

        RecieveOrderBook (Err err) ->
            let
                orderBook =
                  Debug.log (toString err)
            in
                ( model, Cmd.none )
