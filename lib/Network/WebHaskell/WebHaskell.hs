module Network.WebHaskell.WebHaskell where

import Network.WebHaskell.Types (Route(Route), Method (GET, POST), Router)
import Network.WebHaskell.Lookup (formatRequest, routingLookup)
import Network.WebHaskell.Config (Config (ConfigPort), configPort)
import Network.WebHaskell.Routing (route)

import Network.Wai.Handler.Warp (run)



webHaskell :: [Config] -> [Route] -> IO ()
webHaskell configuration routes = do
    let port = configPort configuration
    putStrLn $ "Starting webhandler with: " ++ (show configuration)
    run port $ \request respond -> do 
        route request respond routes

defaultWebHaskell :: [Route] -> IO ()
defaultWebHaskell = webHaskell [
    ConfigPort 8080
    ]
