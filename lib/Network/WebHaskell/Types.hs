module Network.WebHaskell.Types where

import Data.ByteString.Lazy (ByteString)
import Network.HTTP.Types (Status, ResponseHeaders)
import Network.Wai (ResponseReceived, Request, Response)
import Data.Aeson (Value)
import qualified Data.ByteString as BS

type Path = [String]

type ResponseFunction = Request -> IO (Status, ResponseHeaders, ByteString)

data Method = GET | POST | PUT | DELETE
    deriving (Show, Read)

data Route = PlainRoute Method Path ResponseFunction
           | FileRoute  Method Path BS.ByteString FilePath


type Router b = Request -> (Response -> IO b) -> [Route] -> IO b
type Impure b = (Request -> IO b)
type ImpureJson b = (Value -> IO b)
type LookupType = Method -> Path -> [Route] -> Route

