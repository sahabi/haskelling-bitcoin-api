module Network.Bitcoin.Api.TestUtil (testClient, isStatusCodeException) where

import qualified Data.Text                                    as T (pack)
import           Control.Lens                                 ((^.))
import           Network.HTTP.Client                          ( HttpException (..)
                                                              , HttpExceptionContent (..)
                                                              , responseStatus )
import           Network.Wreq.Lens                            (statusCode)

import           Network.Bitcoin.Api.Client

testClient :: (Client -> IO a) -> IO a
testClient = withClient "127.0.0.1" 8332 (T.pack "sahabi") (T.pack "5555")

isStatusCodeException :: Int -> HttpExceptionContent -> Bool
isStatusCodeException code (StatusCodeException s _ ) = (responseStatus s) ^. statusCode == code
isStatusCodeException _ _ = False
