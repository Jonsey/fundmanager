module Data.AccountInfo exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)


type alias Balance =
    { asset : String
    , free : Float
    , locked : Float
    }


type alias AccountInfo =
    { balances : List Balance }


type Msg
    = NoOp
    | AccountInfoRecieved AccountInfo


mapBalances : Value -> Msg
mapBalances modelJson =
    case (decodeValue decoder modelJson) of
        Ok accountInfo ->
            AccountInfoRecieved accountInfo

        Err errorMessage ->
            let
                _ =
                    Debug.log "Error in map ticker:" errorMessage
            in
                NoOp


balanceDecoder : Decoder Balance
balanceDecoder =
    decode Balance
        |> required "asset" string
        |> required "free" float
        |> required "locked" float


decoder : Decoder AccountInfo
decoder =
    decode AccountInfo
        |> required "balances" (list balanceDecoder)
