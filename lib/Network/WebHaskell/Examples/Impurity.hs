module Network.WebHaskell.Examples.Impurity where

import Network.WebHaskell.WebHaskell (webHaskell)
import Network.WebHaskell.Helpers.Html (htmlRouteImpure, htmlRoute)
import Network.WebHaskell.Helpers.Json (jsonRequest, jsonRequestImpure, jsonRequestJsonBody)

import IHP.HSX.QQ (hsx)
import System.Process (readProcess)
import Network.HTTP.Types (status200)
import Network.WebHaskell.Types (Route(Route), Method (POST, GET))
import Data.Aeson.QQ (aesonQQ)
import Network.WebHaskell.Helpers.File (fileRequest)
import Network.Wai (Request (requestHeaderUserAgent), responseStatus)
import Data.ByteString (isInfixOf, pack, ByteString)
import Network.WebHaskell.Config (Config (ConfigPreLogger, ConfigPrecondition, ConfigPort, ConfigPostLogger))
import Network.WebHaskell.Lookup (formatRequest)
import Text.Blaze.Html (Html)

checkUserAgent :: Request -> [ByteString] -> Bool
checkUserAgent request xs = case requestHeaderUserAgent request of
    (Just userAgent) -> any (\x -> isInfixOf x userAgent) xs
    Nothing -> False


configuration :: [Config]
configuration = [
    ConfigPort 8080,
    ConfigPrecondition (\r -> do
        return $ checkUserAgent r ["Firefox", "curl"]
    ),
    ConfigPreLogger (\r -> do 
        let (method, path) = formatRequest r
        return $ "Requested: Method: " ++ (show method) ++ " Path: " ++ (show path)
    ),
    ConfigPostLogger (\r -> do
        let status = responseStatus r
        return $ "Responding: " ++ (show status)
    )
    ]

format :: Html -> Html
format html = [hsx|
    <!DOCTYPE html>
    <meta charset="UTF-8">
    <style>
        * {
            font-family: sans-serif;
        }
    </style>
    <html>
        {html}
    </html>
|]

routes :: [Route]
routes = [
    htmlRoute "/" $ format [hsx|
        Hello WebHaskell!<br>
        What it means to be pure, is for the data to be deterministic, this means that this page can never change<br>
        <a href="/impure">Go to the impure page!</a>
    |],
    htmlRouteImpure "/impure" (\r -> do
        uptime <- readProcess "uptime" [] ""
        date <- readProcess "date" [] ""
        free <- readProcess "free" ["-h"] ""
        systemctl <- readProcess "systemctl" ["status"] ""
        return $ format [hsx|
            Hello Impure WebHaskell!<br>
            Likewise, impurity means to not be deterministic, and have variable data as you can see below:
            <a href="/">Go back to purity!</a>

            <pre>
                Data:
                {uptime}
                {date}
                {free}
                {systemctl}
            </pre>
        |]
    ),
    jsonRequest GET "/api/hello" [aesonQQ|{
        "value":"Hello World!"
    }|],
    jsonRequestImpure GET "/api/impure" (\r -> do
        uptime <- readProcess "uptime" [] ""
        return [aesonQQ|{
            "value":"Hello impure!",
            "uptime": #{uptime}
        }|]
    ),
    jsonRequestJsonBody POST "/api/echo" return,
    fileRequest GET "/api/cabalfile" "text/plain" "webhaskell.cabal"
    ]


impurity :: IO ()
impurity = webHaskell configuration routes
