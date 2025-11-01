module Network.WebHaskell.Helpers.File where
import Network.WebHaskell.Types (Method, Path, Route (FileRoute))
import Network.HTTP.Types (status200, status500)
import Data.ByteString (ByteString)
import qualified Data.ByteString.Lazy as BS
import System.Directory (doesFileExist)
import Data.Aeson.QQ (aesonQQ)
import Data.Aeson (encode)

fileRequest :: Method -> Path -> ByteString -> String -> Route
fileRequest method path contentType filePath = FileRoute method path contentType filePath
