module Network.WebHaskell.Config where
import Network.Wai.Handler.Warp (Port)
import Network.Wai (Request)

data Config = ConfigPort Port
            | ConfigAddress String
            -- Define middleware as something that executes on EVERY request, returns a bool whether we should continue
            -- Multiple middlewares can be added, they will be executed in arbitrary order
            | ConfigMiddleware (Request -> IO Bool)

defaultPort :: Int
defaultPort = 8080


configPort :: [Config] -> Int
configPort ((ConfigPort x):xs) = x
configPort (_:xs) = configPort xs
configPort [] = defaultPort

configMiddleware :: [Config] -> [Request -> IO Bool]
configMiddleware ((ConfigMiddleware f):xs) = f : configMiddleware xs
configMiddleware (_:xs) = configMiddleware xs
configMiddleware [] = []
