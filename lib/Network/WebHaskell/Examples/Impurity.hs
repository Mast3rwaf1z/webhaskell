module Network.WebHaskell.Examples.Impurity where

import Network.WebHaskell.WebHaskell (defaultWebHaskell)
import Network.WebHaskell.Helpers.Html (htmlRouteImpure, htmlRoute)
import Network.WebHaskell.Helpers.Json (jsonRequest, jsonRequestImpure, jsonRequestJsonBody)

import IHP.HSX.QQ (hsx)
import System.Process (readProcess)
import Network.HTTP.Types (status200)
import Network.WebHaskell.Types (Route(Route), Method (POST, GET))
import Data.Aeson.QQ (aesonQQ)
import Network.WebHaskell.Helpers.File (fileRequest)

impurity :: IO ()
impurity = defaultWebHaskell [
    htmlRoute [] [hsx|
        Hello WebHaskell!<br>
        What it means to be pure, is for the data to be deterministic, this means that this page can never change<br>
        <a href="/impure">Go to the impure page!</a>
    |],
    htmlRouteImpure ["impure"] (\r -> do
        uptime <- readProcess "uptime" [] ""
        date <- readProcess "date" [] ""
        free <- readProcess "free" [] ""
        systemctl <- readProcess "systemctl" ["status"] ""
        return [hsx|
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
    jsonRequest GET ["api", "hello"] [aesonQQ|{
        "value":"Hello World!"
    }|],
    jsonRequestImpure GET ["api", "impure"] (\r -> do
        uptime <- readProcess "uptime" [] ""
        return [aesonQQ|{
            "value":"Hello impure!",
            "uptime": #{uptime}
        }|]
    ),
    jsonRequestJsonBody POST ["api", "echo"] return,
    fileRequest GET ["api", "cabalfile"] "text/plain" "webhaskell.cabal"
    ]
