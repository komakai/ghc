
define linkall # $1 = outputdir

# $2 will be empty - doesn't matter
$(call clean-target,$1,$2,$1)
distclean : clean_$1_$2_config
maintainer-clean : distclean

ALL_LINKER = $$(LD)
ALL_LINKER_OPTS = $$(CONF_GCC_LINKER_OPTS_STAGE2)

ALL_AR = $$(AR_STAGE2)
ALL_AR_OPTS = $$(AR_OPTS_STAGE2)
ALL_EXTRA_AR_ARGS = $$(EXTRA_AR_ARGS_STAGE2)

ALL_WAYS = $$(GhcLibWays)

$$(foreach way,$$(ALL_WAYS),$$(eval \
    $$(call linkall-way,$1,$$(way)) \
  ))

endef
