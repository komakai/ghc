-- -----------------------------------------------------------------------------
-- | This is the top-level module in the LLVM code generator.
--

module LlvmCodeGen ( llvmCodeGen, llvmFixupAsm ) where

import LlvmMangler
import DynFlags
import Outputable
import UniqSupply
import System.IO
import Cmm
import qualified Stream

-- -----------------------------------------------------------------------------
-- | Top-level of the LLVM Code generator
--
llvmCodeGen :: DynFlags -> Handle -> UniqSupply
               -> Stream.Stream IO RawCmmGroup ()
               -> IO ()
llvmCodeGen dflags h us cmm_stream
  = panic "Llvm disabled"

