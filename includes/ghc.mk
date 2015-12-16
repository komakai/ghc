# -----------------------------------------------------------------------------
#
# (c) 2009 The University of Glasgow
#
# This file is part of the GHC build system.
#
# To understand how the build system works and how to modify it, see
#      http://ghc.haskell.org/trac/ghc/wiki/Building/Architecture
#      http://ghc.haskell.org/trac/ghc/wiki/Building/Modifying
#
# -----------------------------------------------------------------------------

#
# Header files built from the configure script's findings
#
# XXX: these should go in includes/dist/build?
includes_H_VERSION  = includes/ghcversion.h
includes_H_CONFIG_STAGE1 = includes/stage1/ghcautoconf.h
includes_H_PLATFORM_STAGE1 = includes/stage1/ghcplatform.h
config_H_SRC_STAGE1 = mk/stage1/config.h
config_MK_SRC_STAGE1 = mk/stage1/config.mk
includes_H_CONFIG_STAGE2 = includes/stage2/ghcautoconf.h
includes_H_PLATFORM_STAGE2 = includes/stage2/ghcplatform.h
config_H_SRC_STAGE2 = mk/stage2/config.h
config_MK_SRC_STAGE2 = mk/stage2/config.mk

#
# All header files are in includes/{one of these subdirectories}
#
includes_H_SUBDIRS += .
includes_H_SUBDIRS += rts
includes_H_SUBDIRS += rts/prof
includes_H_SUBDIRS += rts/storage
includes_H_SUBDIRS += stg

includes_H_FILES := $(wildcard $(patsubst %,includes/%/*.h,$(includes_H_SUBDIRS)))
# This isn't necessary, but it makes the paths look a little prettier
includes_H_FILES := $(subst /./,/,$(includes_H_FILES))

#
# Options
#

includes_CC_OPTS += $(SRC_CC_OPTS)
includes_CC_OPTS += $(SRC_CC_WARNING_OPTS)

ifeq "$(GhcUnregisterised)" "YES"
includes_CC_OPTS += -DUSE_MINIINTERPRETER
endif

includes_CC_OPTS_STAGE1 += $(CONF_CC_OPTS_STAGE1)
includes_CC_OPTS_STAGE2 += $(CONF_CC_OPTS_STAGE2)
includes_CC_OPTS_STAGE1 += $(addprefix -I,$(GHC_INCLUDE_DIRS_STAGE1))
includes_CC_OPTS_STAGE2 += $(addprefix -I,$(GHC_INCLUDE_DIRS_STAGE2))
includes_CC_OPTS += -Irts

ifneq "$(GhcWithSMP)" "YES"
includes_CC_OPTS += -DNOSMP
endif

ifeq "$(DYNAMIC_BY_DEFAULT)" "YES"
includes_CC_OPTS += -DDYNAMIC_BY_DEFAULT
endif


$(includes_H_VERSION) : mk/stage1/project.mk | $$(dir $$@)/.
	@echo "Creating $@..."
	@echo "#ifndef __GHCVERSION_H__"  > $@
	@echo "#define __GHCVERSION_H__" >> $@
	@echo >> $@
	@echo "#ifndef __GLASGOW_HASKELL__" >> $@
	@echo "# define __GLASGOW_HASKELL__ $(ProjectVersionInt)" >> $@
	@echo "#endif" >> $@
	@echo >> $@
	@if [ -n "$(ProjectPatchLevel1)" ]; then \
	  echo "#define __GLASGOW_HASKELL_PATCHLEVEL1__ $(ProjectPatchLevel1)" >> $@; \
	fi
	@if [ -n "$(ProjectPatchLevel2)" ]; then \
	  echo "#define __GLASGOW_HASKELL_PATCHLEVEL2__ $(ProjectPatchLevel2)" >> $@; \
	fi
	@echo >> $@
	@echo '#define MIN_VERSION_GLASGOW_HASKELL(ma,mi,pl1,pl2) (\'      >> $@
	@echo '   ((ma)*100+(mi)) <  __GLASGOW_HASKELL__ || \'             >> $@
	@echo '   ((ma)*100+(mi)) == __GLASGOW_HASKELL__    \'             >> $@
	@echo '          && (pl1) <  __GLASGOW_HASKELL_PATCHLEVEL1__ || \' >> $@
	@echo '   ((ma)*100+(mi)) == __GLASGOW_HASKELL__    \'             >> $@
	@echo '          && (pl1) == __GLASGOW_HASKELL_PATCHLEVEL1__ \'    >> $@
	@echo '          && (pl2) <= __GLASGOW_HASKELL_PATCHLEVEL2__ )'    >> $@
	@echo >> $@
	@echo "#endif /* __GHCVERSION_H__ */"          >> $@
	@echo "Done."

ifneq "$(HOSTPLATFORM)" "$(BUILDPLATFORM)"
EXTRA_HSC2HS_OPTS = --cross-compile
endif
 
EXTRA_HSC2HS_OPTS += $(addprefix --cflag=,$(CONFIGURE_CFLAGS))
 
ifeq "$(phase)" "final"
EXTRA_HSC2HS_OPTS += $(addprefix --cflag=,$(CONF_CC_OPTS_STAGE2))
endif

# Build config files
#
define build-config-files
$(call trace, build-config-files($1))
$(call profStart, build-config-files($1))
# $1 = target stage

ifneq "$(BINDIST)" "YES"
$$(includes_H_CONFIG_STAGE$1) : $$(config_H_SRC_STAGE$1) $$(config_MK_SRC_STAGE$1) includes/ghc.mk | $$(dir $$@)/.
	mkdir -p $$(dir $$@)
	echo "Creating $$@..."
	echo "#ifndef __GHCAUTOCONF_H__" >$$@
	echo "#define __GHCAUTOCONF_H__" >>$$@
#
#	Copy the contents of mk/config.h, turning '#define PACKAGE_FOO
#	"blah"' into '/* #undef PACKAGE_FOO */' to avoid clashes.
#
	sed 's,^\([	 ]*\)#[	 ]*define[	 ][	 ]*\(PACKAGE_[A-Z]*\)[	 ][ 	]*".*".*$$$$,\1/* #undef \2 */,'  $$(config_H_SRC_STAGE$1) >> $$@
#
#	Tack on some extra config information from the build system
#
ifeq "$(GhcEnableTablesNextToCode) $(GhcUnregisterised)" "YES NO"
	echo >> $$@
	echo "#define TABLES_NEXT_TO_CODE 1" >> $$@
endif
#
ifeq "$(CC_LLVM_BACKEND)" "1"
	echo >> $$@
	echo "#define llvm_CC_FLAVOR 1" >> $$@
endif
#
ifeq "$(CC_CLANG_BACKEND)" "1"
	echo >> $$@
	echo "#define clang_CC_FLAVOR 1" >> $$@
endif
#
	echo "#endif /* __GHCAUTOCONF_H__ */"          >> $$@
	echo "Done."
endif

$$(includes_H_PLATFORM_STAGE$1) : includes/Makefile | $$(dir $$@)/.
	$(call removeFiles,$$@)
	echo "Creating $$@..."
	echo "#ifndef __GHCPLATFORM_H__"  >$$@
	echo "#define __GHCPLATFORM_H__" >>$$@
	echo >> $$@
	echo "#define BuildPlatform_TYPE  $(HostPlatform_CPP)" >> $$@
	echo "#define HostPlatform_TYPE   $(TargetPlatform_CPP)" >> $$@
	echo >> $$@
	echo "#define $(HostPlatform_CPP)_BUILD  1" >> $$@
	echo "#define $(TargetPlatform_CPP)_HOST  1" >> $$@
	echo >> $$@
	echo "#define $(HostArch_CPP)_BUILD_ARCH  1" >> $$@
	echo "#define $(TargetArch_CPP)_HOST_ARCH  1" >> $$@
	echo "#define BUILD_ARCH  \"$(HostArch_CPP)\"" >> $$@
	echo "#define HOST_ARCH  \"$(TargetArch_CPP)\"" >> $$@
	echo >> $$@
	echo "#define $(HostOS_CPP)_BUILD_OS  1" >> $$@
	echo "#define $(TargetOS_CPP)_HOST_OS  1" >> $$@
	echo "#define BUILD_OS  \"$(HostOS_CPP)\"" >> $$@
	echo "#define HOST_OS  \"$(TargetOS_CPP)\"" >> $$@
ifeq "$(HostOS_CPP)" "irix"
	echo "#ifndef $(IRIX_MAJOR)_HOST_OS" >> $$@  
	echo "#define $(IRIX_MAJOR)_HOST_OS  1" >> $$@  
	echo "#endif" >> $$@  
endif
	echo >> $$@
	echo "#define $(HostVendor_CPP)_BUILD_VENDOR  1" >> $$@
	echo "#define $(TargetVendor_CPP)_HOST_VENDOR  1" >> $$@
	echo "#define BUILD_VENDOR  \"$(HostVendor_CPP)\"" >> $$@
	echo "#define HOST_VENDOR  \"$(TargetVendor_CPP)\"" >> $$@
	echo >> $$@
	echo "/* These TARGET macros are for backwards compatibility... DO NOT USE! */" >> $$@
	echo "#define TargetPlatform_TYPE $(TargetPlatform_CPP)" >> $$@
	echo "#define $(TargetPlatform_CPP)_TARGET  1" >> $$@
	echo "#define $(TargetArch_CPP)_TARGET_ARCH  1" >> $$@
	echo "#define TARGET_ARCH  \"$(TargetArch_CPP)\"" >> $$@
	echo "#define $(TargetOS_CPP)_TARGET_OS  1" >> $$@  
	echo "#define TARGET_OS  \"$(TargetOS_CPP)\"" >> $$@
	echo "#define $(TargetVendor_CPP)_TARGET_VENDOR  1" >> $$@
ifeq "$(GhcUnregisterised)" "YES"
	echo "#define UnregisterisedCompiler 1" >> $$@
endif
	echo >> $$@
	echo "#endif /* __GHCPLATFORM_H__ */"          >> $$@
	echo "Done."

# ---------------------------------------------------------------------------
# Make DerivedConstants.h for the compiler

includes_DERIVEDCONSTANTS_STAGE$1 = includes/stage$1/dist-derivedconstants/header/DerivedConstants.h
includes_GHCCONSTANTS_HASKELL_TYPE_STAGE$1 = includes/stage$1/dist-derivedconstants/header/GHCConstantsHaskellType.hs
includes_GHCCONSTANTS_HASKELL_VALUE_STAGE$1 = includes/stage$1/dist-derivedconstants/header/platformConstants
includes_GHCCONSTANTS_HASKELL_WRAPPERS_STAGE$1 = includes/stage$1/dist-derivedconstants/header/GHCConstantsHaskellWrappers.hs
includes_GHCCONSTANTS_HASKELL_EXPORTS_STAGE$1 = includes/stage$1/dist-derivedconstants/header/GHCConstantsHaskellExports.hs

includes_GHCCONSTANTS_STAGE$1 = $$(includes_GHCCONSTANTS_HASKELL_TYPE_STAGE$1) $$(includes_GHCCONSTANTS_HASKELL_VALUE_STAGE$1) $$(includes_GHCCONSTANTS_HASKELL_WRAPPERS_STAGE$1) $$(includes_GHCCONSTANTS_HASKELL_EXPORTS_STAGE$1)

ifneq "$(BINDIST)" "YES"
$$(includes_DERIVEDCONSTANTS_STAGE$1): $$(includes_H_CONFIG_STAGE$1) $$(includes_H_PLATFORM_STAGE$1) $$(includes_H_VERSION) $$(includes_H_FILES) $$(rts_H_FILES)

$$(includes_GHCCONSTANTS_HASKELL_VALUE_STAGE$1): $$(includes_H_CONFIG_STAGE$1) $$(includes_H_PLATFORM_STAGE$1) $$(includes_H_VERSION) $$(includes_H_FILES) $$(rts_H_FILES)

DERIVE_CONSTANTS_FLAGS_STAGE$1 += --gcc-program "$(WhatGccIsCalled)"
DERIVE_CONSTANTS_FLAGS_STAGE$1 += $$(addprefix --gcc-flag$$(space),$$(includes_CC_OPTS) $$(includes_CC_OPTS_STAGE$1) -fcommon)
DERIVE_CONSTANTS_FLAGS_STAGE$1 += --nm-program "$(NM)"

$$(includes_DERIVEDCONSTANTS_STAGE$1): $(deriveConstants_INPLACE) | $$(dir $$@)/.
	mkdir -p $$(dir $$@)
	$$< --gen-header -o $$@ --tmpdir $$(dir $$@) $$(DERIVE_CONSTANTS_FLAGS_STAGE$1)

$$(includes_GHCCONSTANTS_HASKELL_TYPE_STAGE$1): $(deriveConstants_INPLACE) | $$(dir $$@)/.
	mkdir -p $$(dir $$@)
	$$< --gen-haskell-type -o $$@ --tmpdir $$(dir $$@) $$(DERIVE_CONSTANTS_FLAGS_STAGE$1)

$$(includes_GHCCONSTANTS_HASKELL_VALUE_STAGE$1): $(deriveConstants_INPLACE) | $$(dir $$@)/.
	mkdir -p $$(dir $$@)
	$$< --gen-haskell-value -o $$@ --tmpdir $$(dir $$@) $$(DERIVE_CONSTANTS_FLAGS_STAGE$1)

$$(includes_GHCCONSTANTS_HASKELL_WRAPPERS_STAGE$1): $(deriveConstants_INPLACE) | $$(dir $$@)/.
	mkdir -p $$(dir $$@)
	$$< --gen-haskell-wrappers -o $$@ --tmpdir $$(dir $$@) $$(DERIVE_CONSTANTS_FLAGS_STAGE$1)

$$(includes_GHCCONSTANTS_HASKELL_EXPORTS_STAGE$1): $(deriveConstants_INPLACE) | $$(dir $$@)/.
	mkdir -p $$(dir $$@)
	$$< --gen-haskell-exports -o $$@ --tmpdir $$(dir $$@) $$(DERIVE_CONSTANTS_FLAGS_STAGE$1)
endif

$(call profEnd, build-config-files($1))
endef

INSTALL_LIBS += $(includes_GHCCONSTANTS_HASKELL_VALUE_STAGE2)

$(eval $(call build-config-files,$(target_stage)))

# ---------------------------------------------------------------------------
# Install all header files

$(eval $(call clean-target,includes,,\
  $(includes_H_VERSION) \
  $(includes_H_CONFIG_STAGE1) $(includes_H_PLATFORM_STAGE1) \
  $(includes_H_CONFIG_STAGE2) $(includes_H_PLATFORM_STAGE2)))

$(eval $(call all-target,includes,\
  $(includes_H_VERSION) \
  $(includes_H_CONFIG_STAGE1) $(includes_H_PLATFORM_STAGE1) \
  $(includes_GHCCONSTANTS_HASKELL_TYPE_STAGE1) \
  $(includes_GHCCONSTANTS_HASKELL_VALUE_STAGE1) \
  $(includes_GHCCONSTANTS_HASKELL_WRAPPERS_STAGE1) \
  $(includes_GHCCONSTANTS_HASKELL_EXPORTS_STAGE1) \
  $(includes_DERIVEDCONSTANTS_STAGE1) \
  $(includes_H_CONFIG_STAGE2) $(includes_H_PLATFORM_STAGE2) \
  $(includes_GHCCONSTANTS_HASKELL_TYPE_STAGE2) \
  $(includes_GHCCONSTANTS_HASKELL_VALUE_STAGE2) \
  $(includes_GHCCONSTANTS_HASKELL_WRAPPERS_STAGE2) \
  $(includes_GHCCONSTANTS_HASKELL_EXPORTS_STAGE2) \
  $(includes_DERIVEDCONSTANTS_STAGE2)))

install: install_includes

.PHONY: install_includes
install_includes :
	$(call INSTALL_DIR,"$(DESTDIR)$(ghcheaderdir)")
	$(foreach d,$(includes_H_SUBDIRS), \
	    $(call INSTALL_DIR,"$(DESTDIR)$(ghcheaderdir)/$d") && \
	    $(call INSTALL_HEADER,$(INSTALL_OPTS),includes/$d/*.h,"$(DESTDIR)$(ghcheaderdir)/$d/") && \
	) true
	$(call INSTALL_HEADER,$(INSTALL_OPTS),$(includes_H_CONFIG_STAGE$(target_stage)) $(includes_H_PLATFORM_STAGE$(target_stage)) $(includes_H_VERSION) $(includes_DERIVEDCONSTANTS_STAGE$(target_stage)),"$(DESTDIR)$(ghcheaderdir)/")

