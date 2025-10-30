module Html where
import IHP.HSX.QQ (hsx)
import Text.Blaze.Html.Renderer.Pretty (renderHtml)
import Network.HTTP.Types (status200)
import Types (Route(Route), Method (GET), Path, MethodMapping (MethodMapping))
import Data.String (IsString(fromString))
import Text.Blaze.Html (Html)
import Network.Wai (Request)

htmlRouteImpure :: Path -> (Request -> IO Html) -> MethodMapping
htmlRouteImpure path response = MethodMapping GET (Route path (\r -> do
    html <- response r
    return (status200, [("Content-Type", "text/html")], fromString $ renderHtml html)
    ))

htmlRoute :: Path -> Html -> MethodMapping
htmlRoute path html = MethodMapping GET (Route path (\_ -> return (status200, [("Content-Type", "text/html")], fromString $ renderHtml html)))
