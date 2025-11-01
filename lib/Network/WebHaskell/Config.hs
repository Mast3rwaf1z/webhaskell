module Network.WebHaskell.Config where
import Network.Wai.Handler.Warp (Port)

data Config = ConfigPort Port
            | ConfigAddress String
            deriving Show

defaultPort :: Int
defaultPort = 8080


configPort :: [Config] -> Int
configPort (x:xs) = case x of
    (ConfigPort x) -> x
    _ -> configPort xs
configPort [] = defaultPort
