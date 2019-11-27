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

data Opts = Opts
  { ldapHost :: String
  , ldapUpn :: Text
  , ldapPassword :: ByteString
  } deriving Generic

instance ParseRecord Opts

main :: IO ()
main = do
  Opts{..} <- getRecord "Test program"
  tlsSettings <- either error id <$> getTlsSettings
  errorOrSuccess <- Ldap.with (Tls ldapHost tlsSettings) 636 $ \l -> do
    bindEither l (Dn ldapUpn) (Password ldapPassword)
  print errorOrSuccess

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
