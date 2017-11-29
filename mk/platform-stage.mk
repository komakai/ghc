ifeq "$(target_stage)" "1"

HOSTPLATFORM = $(HOSTPLATFORM_STAGE1)
TARGETPLATFORM = $(TARGETPLATFORM_STAGE1)
BUILDPLATFORM = $(BUILDPLATFORM_STAGE1)

HostPlatform_CPP = $(HostPlatform_CPP_STAGE1)
HostArch_CPP = $(HostArch_CPP_STAGE1)
HostOS_CPP = $(HostOS_CPP_STAGE1)
HostVendor_CPP = $(HostVendor_CPP_STAGE1)

TargetPlatform_CPP = $(TargetPlatform_CPP_STAGE1)
TargetArch_CPP = $(TargetArch_CPP_STAGE1)
TargetOS_CPP = $(TargetOS_CPP_STAGE1)
TargetVendor_CPP = $(TargetVendor_CPP_STAGE1)

BuildPlatform_CPP = $(BuildPlatform_CPP_STAGE1)
BuildArch_CPP = $(BuildArch_CPP_STAGE1)
BuildOS_CPP = $(BuildOS_CPP_STAGE1)
BuildVendor_CPP = $(BuildVendor_CPP_STAGE1)

else

HOSTPLATFORM = $(HOSTPLATFORM_STAGE2)
TARGETPLATFORM = $(TARGETPLATFORM_STAGE2)
BUILDPLATFORM = $(BUILDPLATFORM_STAGE2)

HostPlatform_CPP = $(HostPlatform_CPP_STAGE2)
HostArch_CPP = $(HostArch_CPP_STAGE2)
HostOS_CPP = $(HostOS_CPP_STAGE2)
HostVendor_CPP = $(HostVendor_CPP_STAGE2)

TargetPlatform_CPP = $(TargetPlatform_CPP_STAGE2)
TargetArch_CPP = $(TargetArch_CPP_STAGE2)
TargetOS_CPP = $(TargetOS_CPP_STAGE2)
TargetVendor_CPP = $(TargetVendor_CPP_STAGE2)

BuildPlatform_CPP = $(BuildPlatform_CPP_STAGE2)
BuildArch_CPP = $(BuildArch_CPP_STAGE2)
BuildOS_CPP = $(BuildOS_CPP_STAGE2)
BuildVendor_CPP = $(BuildVendor_CPP_STAGE2)

endif
