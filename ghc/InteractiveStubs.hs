{-# LANGUAGE CPP, MagicHash, NondecreasingIndentation, TupleSections #-}

-----------------------------------------------------------------------------
--
-- GHC Interactive User Interface Stubs
--
-----------------------------------------------------------------------------

module InteractiveStubs (
	CompletionFunc,
	Completion(..),
	noCompletion,
	InputT,
	runInputT,
	liftInputT
    ) where

#include "HsVersions.h"

import Control.Monad.Trans.Identity

type CompletionFunc m = (String,String) -> m (String, [Completion])

data Completion = Completion {}
                    deriving (Eq, Ord, Show)

-- | Disable completion altogether.
noCompletion :: Monad m => CompletionFunc m
noCompletion (s,_) = return (s,[])

type InputT = IdentityT

runInputT :: InputT f a -> f a
runInputT = runIdentityT

liftInputT :: Monad m => m a -> InputT m a
liftInputT = IdentityT

