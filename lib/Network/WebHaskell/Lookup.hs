module Network.WebHaskell.Lookup where

import Network.WebHaskell.Types (Method (GET, PUT, POST, DELETE), Path, LookupType, Route (Route, FileRoute))

import Network.Wai (Request (requestMethod, pathInfo))
import IHP.HSX.QQ (hsx)
import Data.Text (unpack)
import Text.Blaze.Html.Renderer.Pretty (renderHtml)
import Data.String (IsString(fromString))
import Network.HTTP.Types (status404)
import Data.List (intercalate)

import qualified Data.ByteString.Char8 as B8
import Text.Regex (matchRegex, mkRegex)

formatRequest :: Request -> (Method, String)
formatRequest request = (read method, matchablePath)
    where
        method = B8.unpack $ requestMethod request
        path = map unpack $ pathInfo request
        matchablePath = "/" ++ intercalate "/" path


class Lookup l t where
    lookupMatch :: l -> t -> Bool

instance Lookup (Method, String) Route where
    lookupMatch (method, path) (Route method1 regex _) = method == method1 && case matchRegex regex path of
        Nothing -> False
        _ -> True
    lookupMatch (method, path) (FileRoute method1 regex _ _) = method == method1 && case matchRegex regex path of
        Nothing -> False
        _ -> True


fallback :: Method -> String -> [Route] -> Route
fallback method path [] = Route method (mkRegex path) (\r -> do
    return (status404, [("Content-Type", "text/html")], fromString $ renderHtml $ [hsx|
        Error 404: Found nothing by ({method}, {path})
    |]))
fallback _ _ (x:_) = x

routingLookup :: LookupType
routingLookup method path routing = fallback method path $ filter (lookupMatch (method, path)) routing
