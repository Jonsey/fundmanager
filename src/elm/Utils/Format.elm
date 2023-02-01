module Utils.Format exposing (truncateFloat)


import Round exposing (round)


truncateFloat : Float -> Float -> Float
truncateFloat value precision =
    let
      var1 = Round.round 0 (value * precision)
    in
      case String.toFloat var1 of
        Ok n -> n / precision
        Err _ -> 0
