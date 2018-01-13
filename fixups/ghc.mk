ifeq "$(UseFixups)" "YES"

fixups_dist_CC = $(CC_STAGE2)

RESOURCES_FIXUP_SRC = fixups/resources.c
SYMTABLE_FIXUP_SRC = fixups/symbolLookup.c

ifeq "$(Ios)" "YES"
fixups_LEADING_UNDERSCORE = yes
endif

define build-fixups # args: $1 = way

ifeq "$1" "v"
$1_fixups_LIBSUFFIX = a
$1_fixups_INCSUFFIX = .inc
fixups_dist_$1_CC_OPTS = -Iincludes $$(CONF_CC_OPTS_STAGE2)
else
$1_fixups_INCSUFFIX = .dyn_inc
fixups_dist_$1_CC_OPTS = -fPIC -DDYNAMIC -Iincludes $$(CONF_CC_OPTS_STAGE2)
ifeq "$(Android)" "YES"
$1_fixups_LIBSUFFIX = so
else ifeq "$(Ios)" "YES"
$1_fixups_LIBSUFFIX = dylib
endif
endif

$1_fixups_RESFILES = fixups/resfiles$$($1_fixups_INCSUFFIX)
$1_fixups_SYMBOLFILE = fixups/symboltable$$($1_fixups_INCSUFFIX)

$$($1_fixups_RESFILES) : $$(ghc_stage2_$1_LIB)
	fixups/genres.pl $1

$$($1_fixups_SYMBOLFILE) : $$(ghc_stage2_$1_LIB)
	fixups/gensymtable.pl $$($1_fixups_LIBSUFFIX) $$(fixups_LEADING_UNDERSCORE)

$(call distdir-way-opts,fixups,dist,$1)
$(call c-suffix-rules,fixups,dist,$1,NO)

RESOURCES_FIXUP_$1_OBJ = fixups/dist/build/resources.$$($1_osuf)
SYMTABLE_FIXUP_$1_OBJ = fixups/dist/build/symbolLookup.$$($1_osuf)

$$(RESOURCES_FIXUP_$1_OBJ) : $$($1_fixups_RESFILES)
$$(SYMTABLE_FIXUP_$1_OBJ) : $$($1_fixups_SYMBOLFILE)

$1_ALL_OBJS += $$(RESOURCES_FIXUP_$1_OBJ) $$(SYMTABLE_FIXUP_$1_OBJ)

endef

$(foreach way,$(GhcLibWays),$(eval $(call build-fixups,$(way))))

endif
