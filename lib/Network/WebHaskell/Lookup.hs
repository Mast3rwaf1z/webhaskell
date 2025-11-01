module Network.WebHaskell.Lookup where

import Network.WebHaskell.Types (Method (GET, PUT, POST, DELETE), Path, LookupType, Route (PlainRoute, FileRoute))

import Network.Wai (Request (requestMethod, pathInfo))
import IHP.HSX.QQ (hsx)
import Data.Text (unpack)
import Text.Blaze.Html.Renderer.Pretty (renderHtml)
import Data.String (IsString(fromString))
import Network.HTTP.Types (status404)

import qualified Data.ByteString.Char8 as B8

formatRequest :: Request -> (Method, Path)
formatRequest request = (read method, path)
    where
        method = B8.unpack $ requestMethod request
        path = map unpack $ pathInfo request

routingLookup :: LookupType
routingLookup GET path ((PlainRoute GET path1 response):xs)
    | path == path1 = PlainRoute GET path response
    | otherwise     = routingLookup GET path xs
routingLookup GET path ((FileRoute GET path1 contentType filePath):xs)
    | path == path1 = FileRoute GET path1 contentType filePath
    | otherwise     = routingLookup GET path xs
routingLookup PUT path ((PlainRoute PUT path1 response):xs)  
    | path == path1 = PlainRoute PUT path response
    | otherwise     = routingLookup PUT path xs
routingLookup PUT path ((FileRoute PUT path1 contentType filePath):xs)
    | path == path1 = FileRoute PUT path1 contentType filePath
    | otherwise     = routingLookup PUT path xs
routingLookup POST path ((PlainRoute POST path1 response):xs)
    | path == path1 = PlainRoute POST path response
    | otherwise     = routingLookup POST path xs
routingLookup POST path ((FileRoute POST path1 contentType filePath):xs)
    | path == path1 = FileRoute POST path1 contentType filePath
    | otherwise     = routingLookup POST path xs
routingLookup DELETE path ((PlainRoute DELETE path1 response):xs)
    | path == path1 = PlainRoute DELETE path response
    | otherwise     = routingLookup DELETE path xs
routingLookup DELETE path ((FileRoute DELETE path1 contentType filePath):xs)
    | path == path1 = FileRoute DELETE path1 contentType filePath
    | otherwise     = routingLookup DELETE path xs

routingLookup method path (_:xs) = routingLookup method path xs
routingLookup method path [] = PlainRoute method path (\r -> do
    return (status404, [("Content-Type", "text/html")], fromString $ renderHtml $ [hsx|
        Error 404: Found nothing by ({method}, {path})
    |])
    )
