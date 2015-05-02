{-# LANGUAGE OverloadedStrings #-}

module Network.Bitcoin.Rpc.Wallet where

import           Data.Aeson
import           Data.Aeson.Types

import qualified Data.HashMap.Strict                          as HM
import qualified Data.Text                                    as T

import qualified Data.Bitcoin.Types                           as BT
import qualified Network.Bitcoin.Rpc.Internal                 as I
import qualified Network.Bitcoin.Rpc.Types                    as T
import           Network.Bitcoin.Rpc.Types.UnspentTransaction (UnspentTransaction)

-- | Lists unspent transaction with default parameters
listUnspent :: T.Client
            -> IO [UnspentTransaction]
listUnspent client = listUnspentWith client 1 9999999

-- | Lists unspent transactions with configurable parameters
listUnspentWith :: T.Client -- ^ Our client context
                -> Integer  -- ^ Minimum amount of confirmations needed. Defaults to 1.
                -> Integer  -- ^ Maximum amount of confirmations. Defaults to 9999999.
                -> IO [UnspentTransaction]
listUnspentWith client confMin confMax =
  let configuration = [toJSON confMin, toJSON confMax, emptyArray]

  in I.call client "listunspent" configuration

-- | Lists all accounts currently known by the wallet with default parameters
listAccounts :: T.Client
             -> IO [(BT.Account, BT.Btc)]
listAccounts client = listAccountsWith client 1 False

-- | Lists all accounts currently known by the wallet with configurable parameters
listAccountsWith :: T.Client -- ^ Our client context
                 -> Integer  -- ^ Minimum amount of confirmations a transaction needs
                 -> Bool     -- ^ Whether or not to include watch-only addresses
                 -> IO [(BT.Account, BT.Btc)]
listAccountsWith client confirmations watchOnly =
  let configuration        = [toJSON confirmations, toJSON watchOnly]

  in
    return . HM.toList =<< I.call client "listaccounts" configuration

-- | Provides access to a new receiving address filed under the default account.
--   Intended to be published to another party that wishes to send you money.
newAddress :: T.Client         -- ^ Our client context
           -> IO BT.Address    -- ^ The address created
newAddress client =
  I.call client "getnewaddress" emptyArray

-- | Provides access to a new receiving address filed under a specific account.
--   Intended to be published to another party that wishes to send you money.
newAddressWith :: T.Client      -- ^ Our client context
               -> BT.Account    -- ^ The account to create the address under
               -> IO BT.Address -- ^ The address created
newAddressWith client account =
  let configuration = [account]

  in I.call client "getnewaddress" configuration

-- | Provides access to a new change address, which will not appear in the UI.
--   This is to be used with raw transactions only.
newChangeAddress :: T.Client         -- ^ Our client context
                 -> IO BT.Address    -- ^ The address created
newChangeAddress client =
  I.call client "getrawchangeaddress" emptyArray

-- | Provides access to the 'BT.Account' an 'BT.Address' belongs to.
getAddressAccount :: T.Client
                  -> BT.Address
                  -> IO BT.Account
getAddressAccount client address =
  let configuration = [address]
  in I.call client "getaccount" configuration