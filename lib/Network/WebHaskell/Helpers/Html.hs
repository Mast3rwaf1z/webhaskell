module Network.WebHaskell.Helpers.Html where

import Network.WebHaskell.Types (Route(Route), Method (GET), Path, Impure)

import IHP.HSX.QQ (hsx)
import Text.Blaze.Html.Renderer.Pretty (renderHtml)
import Network.HTTP.Types (status200)
import Data.String (IsString(fromString))
import Text.Blaze.Html (Html)
import Network.Wai (Request)

htmlRoute :: Path -> Html -> Route
htmlRoute path html = Route GET path (\_ -> return (status200, [("Content-Type", "text/html")], fromString $ renderHtml html))

htmlRouteImpure :: Path -> Impure Html -> Route
htmlRouteImpure path response = Route GET path (\r -> do
    html <- response r
    return (status200, [("Content-Type", "text/html")], fromString $ renderHtml html))
