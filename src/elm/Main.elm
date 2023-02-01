module Main exposing (..)

import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Task exposing (..)
import Time exposing (Time)
import Navigation exposing (Location)
import Route exposing (Route(..))
import Ports exposing (tickerReceived, tradeReceived, analysisReceived, requestAccountInfo)
import Trades.Utils.Mapper exposing (mapTrade)
import Trades.Update exposing (update)
import OrderBooks.Messages
import Pairs.Messages
import Trades.Messages exposing (Msg)
import Tickers.Messages
import Trades.Models
import Views.Page as Page exposing (ActivePage)
import Page.Errored as Errored exposing (PageLoadError)
import Page.Login as Login
import Page.Profile as Profile
import Page.Register as Register
import Page.Home as Home
import Trades.View exposing (view)
import Data.Session exposing (Session)
import Data.User as User exposing (User, Username)


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Home Home.Model
    | Trades Trades.Models.Model
    | Login Login.Model
    | Register Register.Model
    | Profile Username Profile.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- Model


type alias Model =
    { time : Time
    , session : Session
    , pageState : PageState
    }


init : Value -> Location -> ( Model, Cmd Msg )
init val location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded initialPage
        , session = { user = decodeUserFromJson val }
        , time = 0.0
        }


decodeUserFromJson : Value -> Maybe User
decodeUserFromJson json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString User.decoder >> Result.toMaybe)


initialPage : Page
initialPage =
    Blank



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every Time.second SetTime
        , Sub.map HomeMsg (Home.subscriptions)
        , Sub.map TradesMsg (tradeReceived mapTrade)
        ]


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page



-- Update


type Msg
    = SetRoute (Maybe Route)
    | SetTime Time
    | HomeLoaded (Result PageLoadError Home.Model)
    | ProfileLoaded Username (Result PageLoadError Profile.Model)
    | TickersMsg Tickers.Messages.Msg
    | HomeMsg Home.Msg
    | PairsMsg Pairs.Messages.Msg
    | OrderBooksMsg OrderBooks.Messages.Msg
    | TradesMsg Trades.Messages.Msg
    | SetUser (Maybe User)
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg
    | ProfileMsg Profile.Msg
    | NoOp


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            ( { model | pageState = TransitioningFrom (getPage model.pageState) }
            , Task.attempt toMsg task
            )

        errored =
            pageErrored model
    in
        case maybeRoute of
            Nothing ->
                ( { model | pageState = Loaded NotFound }, Cmd.none )

            Just Route.Trades ->
                case model.session.user of
                    Just user ->
                        ( { model | pageState = Loaded (Trades Trades.Models.initialModel) }, Cmd.none )

                    Nothing ->
                        errored Page.Trades "You must be signed in to view trades."

            Just Route.Home ->
                transition HomeLoaded (Home.init model.session)

            Just Route.Root ->
                ( model, Route.modifyUrl Route.Home )

            Just Route.Login ->
                ( { model | pageState = Loaded (Login Login.initialModel) }, Cmd.none )

            Just Route.Logout ->
                let
                    session =
                        model.session
                in
                    ( { model | session = { session | user = Nothing } }
                    , Cmd.batch
                        [ Ports.storeSession Nothing
                        , Route.modifyUrl Route.Home
                        ]
                    )

            Just Route.Register ->
                ( { model | pageState = Loaded (Register Register.initialModel) }, Cmd.none )

            Just (Route.Profile username) ->
                transition (ProfileLoaded username) (Profile.init model.session username)


pageErrored : Model -> ActivePage -> String -> ( Model, Cmd msg )
pageErrored model activePage errorMessage =
    let
        error =
            Errored.pageLoadError activePage errorMessage
    in
        ( { model | pageState = Loaded (Errored error) }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        session =
            model.session

        time =
            model.time

        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
                ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )

        errored =
            pageErrored model
    in
        case ( msg, page ) of
            ( SetTime time, _ ) ->
                ( { model | time = time }, Cmd.none )

            ( SetRoute route, _ ) ->
                setRoute route model

            ( HomeLoaded (Ok subModel), _ ) ->
                ( { model | pageState = Loaded (Home subModel) }, requestAccountInfo "" )

            ( HomeLoaded (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }, Cmd.none )

            ( ProfileLoaded username (Ok subModel), _ ) ->
                ( { model | pageState = Loaded (Profile username subModel) }, Cmd.none )

            ( ProfileLoaded username (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }, Cmd.none )

            ( SetUser user, _ ) ->
                let
                    cmd =
                        -- If we just signed out, then redirect to Home.
                        if session.user /= Nothing && user == Nothing then
                            Route.modifyUrl Route.Home
                        else
                            Cmd.none
                in
                    ( { model | session = { session | user = user } }
                    , cmd
                    )

            ( LoginMsg subMsg, Login subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Login.update subMsg subModel

                    newModel =
                        case msgFromPage of
                            Login.NoOp ->
                                model

                            Login.SetUser user ->
                                { model | session = { user = Just user } }
                in
                    ( { newModel | pageState = Loaded (Login pageModel) }
                    , Cmd.map LoginMsg cmd
                    )

            ( RegisterMsg subMsg, Register subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Register.update subMsg subModel

                    newModel =
                        case msgFromPage of
                            Register.NoOp ->
                                model

                            Register.SetUser user ->
                                { model | session = { user = Just user } }
                in
                    ( { newModel | pageState = Loaded (Register pageModel) }
                    , Cmd.map RegisterMsg cmd
                    )

            ( HomeMsg subMsg, Home subModel ) ->
                toPage Home HomeMsg (Home.update session time) subMsg subModel

            ( TradesMsg subMsg, Trades subModel ) ->
                toPage Trades TradesMsg (Trades.Update.update session) subMsg subModel

            ( ProfileMsg subMsg, Profile username subModel ) ->
                toPage (Profile username) ProfileMsg (Profile.update model.session) subMsg subModel

            ( _, NotFound ) ->
                -- Disregard incoming messages when we're on the
                -- NotFound page.
                ( model, Cmd.none )

            ( _, _ ) ->
                -- Disregard incoming messages that arrived for the wrong page
                ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage model.session False page

        TransitioningFrom page ->
            viewPage model.session True page


viewPage : Session -> Bool -> Page -> Html Msg
viewPage session isLoading page =
    let
        frame =
            Page.frame isLoading session.user
    in
        case page of
            Home subModel ->
                Home.view subModel
                    |> frame Page.Home
                    |> Html.map HomeMsg

            Login subModel ->
                Login.view session subModel
                    |> frame Page.Other
                    |> Html.map LoginMsg

            Register subModel ->
                Register.view session subModel
                    |> frame Page.Other
                    |> Html.map RegisterMsg

            Profile username subModel ->
                Profile.view session subModel
                    |> frame (Page.Profile username)
                    |> Html.map ProfileMsg

            Trades subModel ->
                Trades.View.view subModel
                    |> frame Page.Trades
                    |> Html.map TradesMsg

            Blank ->
                -- This is for the very initial page load, while we are loading
                -- data via HTTP. We could also render a spinner here.
                Html.text ""
                    |> frame Page.Other

            Errored subModel ->
                Errored.view session subModel
                    |> frame Page.Other

            NotFound ->
                notFoundView


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]



-- CSS STYLES


styles : { img : List ( String, String ) }
styles =
    { img =
        [ ( "width", "33%" )
        , ( "border", "4px solid #337AB7" )
        ]
    }



-- Main


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
