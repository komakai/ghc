-- -----------------------------------------------------------------------------
--
-- (c) The University of Glasgow 1993-2004
-- 
-- This is the top-level module in the native code generator.
--
-- -----------------------------------------------------------------------------
module AsmCodeGen ( nativeCodeGen ) where

import DynFlags
import UniqSupply
import System.IO
import Outputable
import Cmm
import Module
import Stream (Stream)
import qualified Stream

nativeCodeGen :: DynFlags -> Module -> ModLocation -> Handle -> UniqSupply
              -> Stream IO RawCmmGroup ()
              -> IO UniqSupply
nativeCodeGen dflags this_mod modLoc h us cmms
 = panic "Native code generator disabled"

