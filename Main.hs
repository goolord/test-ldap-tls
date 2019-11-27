{-# LANGUAGE
    OverloadedStrings
  , DeriveGeneric
  , RecordWildCards
#-}

module Main where

import Ldap.Client as Ldap
import Ldap.Client.Bind
import GHC.Generics
import Options.Generic
import Network.TLS
import Network.Connection (TLSSettings(..))
import Data.Default.Class
import Data.ByteString (ByteString)
import Network.Connection
import qualified Data.ByteString as B

data Opts = Opts
  { ldapHost :: String
  , ldapUpn :: Text
  , ldapPassword :: ByteString
  } deriving Generic

instance ParseRecord Opts

main :: IO ()
main = do
  opts <- getRecord "Test program"
  tlsSettings <- either error id <$> getTlsSettings
  testConnection opts tlsSettings
  testLdapClient opts tlsSettings
  
testLdapClient :: Opts -> TLSSettings -> IO ()
testLdapClient Opts{..} tlsSettings = do
  errorOrSuccess <- Ldap.with (Tls ldapHost tlsSettings) 636 $ \l -> do
    bindEither l (Dn ldapUpn) (Password ldapPassword)
  print errorOrSuccess

testConnection :: Opts -> TLSSettings -> IO ()
testConnection Opts{..} tlsSettings = do
  ctx <- initConnectionContext
  con <- connectTo ctx $ ConnectionParams
    { connectionHostname  = ldapHost
    , connectionPort      = 636
    , connectionUseSecure = Just tlsSettings
    , connectionUseSocks  = Nothing
    }
  connectionPut con (B.singleton 0xa)
  r <- connectionGet con 1024
  putStrLn $ show r
  connectionClose con

getTlsSettings :: IO (Either String TLSSettings)
getTlsSettings = do
  ecreds <- credentialLoadX509 "./cert.pem" "./key.pem"
  case ecreds of
    Left e -> pure $ Left e
    Right cert -> 
      pure $ Right $ TLSSettings $ (defaultParamsClient "" "")
        { clientShared = def 
          { sharedCredentials = Credentials [cert]
          }
        }
