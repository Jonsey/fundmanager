module Request.Home exposing (getExchangeInfo, getAccountInfo)

import Data.AccountInfo as AccountInfo exposing (AccountInfo)
import Data.ExchangeInfo as ExchangeInfo exposing (ExchangeInfo, decoder)
import Request.Helpers exposing (apiUrl)
import Dict exposing (Dict)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Json.Decode as Decode


getExchangeInfo : Http.Request (List ExchangeInfo)
getExchangeInfo =
    let
        itemsDecoder : Decode.Decoder (List ExchangeInfo)
        itemsDecoder =
            Decode.list ExchangeInfo.decoder
    in
        apiUrl "/binance/exchange-info/"
            |> HttpBuilder.get
            |> HttpBuilder.withExpect (Http.expectJson itemsDecoder)
            |> HttpBuilder.toRequest


getAccountInfo : Http.Request AccountInfo
getAccountInfo =
    let
        itemsDecoder : Decode.Decoder AccountInfo
        itemsDecoder =
            AccountInfo.decoder
    in
        apiUrl "/binance/account-info/"
            |> HttpBuilder.get
            |> HttpBuilder.withExpect (Http.expectJson itemsDecoder)
            |> HttpBuilder.toRequest
