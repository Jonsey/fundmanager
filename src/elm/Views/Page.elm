module Views.Page exposing (ActivePage(..), frame)

import Data.User as User exposing (User, Username)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)


type ActivePage
    = Other
    | Home
    | Login
    | Register
    | Settings
    | Profile Username
    | Trades


frame : Bool -> Maybe User -> ActivePage -> Html msg -> Html msg
frame isLoading user page content =
    div []
        [ top page user
        , drawer
        , main_ [ class "page__main" ]
            [ content
            ]
        ]


top : ActivePage -> Maybe User -> Html msg
top page user =
    header [ class "header" ]
        [ div [ class "header__container" ]
            [ section [ class "header__container__account" ]
                [ a [ class "material-icons ", href "#" ]
                    [ text "menu" ]
                , ul [ class "nav" ] (viewSignIn page user)
                ]
            , section [ class "header__container__nav", attribute "role" "toolbar" ]
                [ a [ alt "Download", attribute "aria-label" "Download", class "material-icons ", href "#/trades" ]
                    [ text "trending_up" ]
                , a [ alt "Print this page", attribute "aria-label" "Print this page", class "material-icons ", href "#/analysis" ]
                    [ text "notifications" ]
                , a [ alt "Bookmark this page", attribute "aria-label" "Bookmark this page", class "material-icons ", href "#" ]
                    [ text "event_note" ]
                ]
            ]
        ]


drawer : Html msg
drawer =
    div [ class "demo-drawer mdl-layout__drawer mdl-color--blue-grey-900 mdl-color-text--blue-grey-50" ]
        [ nav [ class "demo-navigation mdl-navigation mdl-color--blue-grey-800" ]
            [ a [ class "mdl-navigation__link", href "#/analysis" ] [ text "Analysis" ]
            , a [ class "mdl-navigation__link", href "#/trades" ] [ text "Trades" ]
            , a [ class "mdl-navigation__link", href "#/" ] [ text "Home" ]
            ]
        ]


viewSignIn : ActivePage -> Maybe User -> List (Html msg)
viewSignIn page user =
    let
        linkTo =
            navbarLink page
    in
        case user of
            Nothing ->
                [ linkTo Route.Login [ text "Sign in" ]
                , linkTo Route.Register [ text "Sign up" ]
                ]

            Just user ->
                [ linkTo
                    (Route.Profile user.username)
                    [ User.usernameToHtml user.username
                    ]
                , linkTo Route.Logout [ text "Sign out" ]
                ]


navbarLink : ActivePage -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", isActive page route ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]


isActive : ActivePage -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Login, Route.Login ) ->
            True

        ( Register, Route.Register ) ->
            True

        ( Profile pageUsername, Route.Profile routeUsername ) ->
            pageUsername == routeUsername

        _ ->
            False
