{-# LANGUAGE CPP #-}

-------------------------------------------------------------------------------
--
-- | Platform constants
--
-- (c) The University of Glasgow 2013
--
-------------------------------------------------------------------------------

module PlatformConstants (PlatformConstants(..)) where

#if STAGE==1
#include "../includes/stage1/dist-derivedconstants/header/GHCConstantsHaskellType.hs"
#elif STAGE==2
#include "../includes/stage2/dist-derivedconstants/header/GHCConstantsHaskellType.hs"
#else
#error "Invalid STAGE !!!"
#endif

