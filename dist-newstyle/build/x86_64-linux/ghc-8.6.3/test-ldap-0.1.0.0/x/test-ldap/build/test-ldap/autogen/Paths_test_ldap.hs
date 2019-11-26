{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_test_ldap (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/zach/.cabal/bin"
libdir     = "/home/zach/.cabal/lib/x86_64-linux-ghc-8.6.3/test-ldap-0.1.0.0-inplace-test-ldap"
dynlibdir  = "/home/zach/.cabal/lib/x86_64-linux-ghc-8.6.3"
datadir    = "/home/zach/.cabal/share/x86_64-linux-ghc-8.6.3/test-ldap-0.1.0.0"
libexecdir = "/home/zach/.cabal/libexec/x86_64-linux-ghc-8.6.3/test-ldap-0.1.0.0"
sysconfdir = "/home/zach/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "test_ldap_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "test_ldap_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "test_ldap_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "test_ldap_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "test_ldap_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "test_ldap_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
