port module Ports exposing (..)

import Json.Decode
import Json.Encode exposing (Value)


-- PORTS
--outbound


port storeSession : Maybe String -> Cmd msg


port drawChart : String -> Cmd msg


port requestTicker : String -> Cmd msg


port requestAccountInfo : String -> Cmd msg


port exchangeRequest : String -> Cmd msg



--inbound


port onSessionChange : (Value -> msg) -> Sub msg


port tickerReceived : (Json.Decode.Value -> msg) -> Sub msg


port orderReceived : (Json.Decode.Value -> msg) -> Sub msg


port accountInfoRecieved : (Json.Decode.Value -> msg) -> Sub msg


port tradeReceived : (Json.Decode.Value -> msg) -> Sub msg


port analysisReceived : (Json.Decode.Value -> msg) -> Sub msg
