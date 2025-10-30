module Webhandler where

import Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Char8 as B8
import Network.HTTP.Types (Status, ResponseHeaders, status200, status404)
import Network.Wai (ResponseReceived, Request (pathInfo, requestMethod), responseBuilder, Application, Response, responseLBS)
import IHP.HSX.QQ (hsx)
import Data.Text (unpack, intercalate)
import Blaze.ByteString.Builder (copyByteString)
import Network.Wai.Handler.Warp (run)
import Text.Blaze.Html.Renderer.Pretty (renderHtml)
import Data.String (IsString(fromString))
import Types (Route(Route), Method (GET), Router, MethodMapping (MethodMapping), formatRequest, mappingLookup)
import Html (htmlRoute, htmlRouteImpure)

route :: Router b
route request respond mapping = do
    let (method, path) = formatRequest request
    putStrLn $ "Method: " ++ (show method) ++ " Path: " ++ (show path)
    let (Route path response) = mappingLookup method path mapping
    (status, headers, body) <- response request
    respond $ responseLBS status headers $ body

webhandler :: [MethodMapping] -> IO ()
webhandler routes = run 8080 $ \request respond -> do
    route request respond routes


test :: IO ()
test = webhandler [
    htmlRoute [] [hsx|
        Hello Webhandler!<br>
        <a href="/impure">Go to the impure page!</a>
    |],
    htmlRouteImpure ["impure"] (\r -> return [hsx|
        Hello Impure Webhandler!<br>
        <a href="/">Go back to purity!</a>
    |])
    ]
