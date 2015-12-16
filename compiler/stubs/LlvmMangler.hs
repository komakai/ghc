-- -----------------------------------------------------------------------------
-- | GHC LLVM Mangler
--
-- This script processes the assembly produced by LLVM, rearranging the code
-- so that an info table appears before its corresponding function.
--
-- On OSX we also use it to fix up the stack alignment, which needs to be 16
-- byte aligned but always ends up off by word bytes because GHC sets it to
-- the 'wrong' starting value in the RTS.
--

module LlvmMangler ( llvmFixupAsm ) where

import DynFlags
import Outputable
import System.IO

llvmFixupAsm :: DynFlags -> FilePath -> FilePath -> IO ()
llvmFixupAsm dflags f1 f2 = do
    panic "Llvm disabled"

