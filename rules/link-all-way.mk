
define linkall-way # $1 = outputdir, $2 = way

$1_$2_BIGLIB = $1/libhaskell$$($2_libsuf)

ifeq "$2" "dyn"

$$($1_$2_BIGLIB) : $$($2_ALL_OBJS)
	mkdir -p $$(dir $$@);
	"$$(ALL_LINKER)" \
         -shared -Wl,-Bsymbolic -Wl,-h,$(notdir $$@) \
         $$($2_ALL_OBJS) \
         $$(ALL_LINKER_OPTS) $$(ALL_EXTRA_LINKER_OPTS) \
         -o $$@

else

# Build the ordinary .a library
$$($1_$2_BIGLIB) : $$($2_ALL_OBJS)
	mkdir -p $$(dir $$@);
	"$$(RM)" $$(RM_OPTS) $$@ $$@.contents
	echo $$($2_ALL_OBJS) >> $$@.contents
ifeq "$$($1_ArSupportsAtFile)" "YES"
	"$$(ALL_AR)" $$(ALL_AR_OPTS) $$(ALL_EXTRA_AR_ARGS) $$@ @$$@.contents
else
	"$$(XARGS)" $$(XARGS_OPTS) "$$(ALL_AR)" $$(ALL_AR_OPTS) $$(ALL_EXTRA_AR_ARGS) $$@ < $$@.contents
endif
	"$$(RM)" $$(RM_OPTS) $$@.contents
endif

$(call all-target,$1,all_$1_$2)
$(call all-target,$1_$2,$$($1_$2_BIGLIB))

endef

