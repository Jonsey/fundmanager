module Data.Order exposing (..)

import Date exposing (Date)
import Data.Pair exposing (PairId)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Decoders exposing (dateFromTimeStamp, stringIntDecoder)


type alias OrderId =
    Int


type OrderType
    = Buy
    | Sell


type Margin
    = Loss
    | Profit


type OrderStatus
    = New
    | Filled
    | PartiallyFilled
    | Canceled
    | Rejected


type alias Order =
    { id : OrderId
    , orderType : OrderType
    , pairId : PairId
    , price : Float
    , quantity : Float
    , time : Date
    , orderStatus : OrderStatus
    }


decoder : Decoder Order
decoder =
    decode Order
        |> required "orderId" int
        |> required "orderType" orderType
        |> required "pairId" string
        |> required "price" float
        |> required "quantity" float
        |> required "time" dateFromTimeStamp
        |> required "orderStatus" orderStatus


orderStatus : Decoder OrderStatus
orderStatus =
    let
        convert : String -> Decoder OrderStatus
        convert raw =
            case raw of
                "NEW" ->
                    succeed New

                "FILLED" ->
                    succeed Filled

                "PARTIALLY_FILLED" ->
                    succeed PartiallyFilled

                "CANCELED" ->
                    succeed Canceled

                "REJECTED" ->
                    succeed Rejected

                _ ->
                    fail ""
    in
        string |> andThen convert


orderType : Decoder OrderType
orderType =
    let
        convert : String -> Decoder OrderType
        convert raw =
            case raw of
                "BUY" ->
                    succeed Buy

                "SELL" ->
                    succeed Sell

                _ ->
                    fail ""
    in
        string |> andThen convert
