#
# =====================================================================
# Copyright (C) 2012 Texas Instruments Incorporated
#
# All rights reserved. Property of Texas Instruments Incorporated.
# Restricted rights to use, duplicate or disclose this code are
# granted through contract.
#
# The program may not be used without the written permission
# of Texas Instruments Incorporated or against the terms and conditions
# stipulated in the agreement under which this program has been
# supplied.
# =====================================================================
#

# Repo
BIOSTOOLSROOT	?= /opt/ti
REPO		:= $(BIOSTOOLSROOT)

# Different tool versions can easily be programmed by defining below variables
# in your environment.
XDCVERSION	?= xdctools_3_25_06_96
BIOSVERSION	?= bios_6_37_03_30
IPCVERSION	?= ipc_3_23_01_03
CEVERSION	?= codec_engine_3_24_00_08
FCVERSION	?= framework_components_3_24_02_15
XDAISVERSION	?= xdais_7_24_00_04
OSALVERSION	?= osal_1_24_00_09

# TI Compiler Settings
export C66XCGTOOLSPATH ?= /opt/ti/C6000CGT7.4.2

# Define where the sources are
DSPDCEMMSRC	= $(shell pwd)
TIVIDEOTOOLSROOT ?= $(BIOSTOOLSROOT)

# Generate the full package paths for tools
BIOSPROD	= $(REPO)/$(BIOSVERSION)
CEPROD		= $(TIVIDEOTOOLSROOT)/$(CEVERSION)
FCPROD		= $(TIVIDEOTOOLSROOT)/$(FCVERSION)
XDAISPROD	= $(REPO)/$(XDAISVERSION)
OSALPROD	= $(REPO)/$(OSALVERSION)

# XDC settings
export XDCBUILDCFG = $(DSPDCEMMSRC)/build/config.bld

XDCDIST_TREE	= $(REPO)/$(XDCVERSION)
export XDCROOT	= $(XDCDIST_TREE)

export XDCPATH  = $(BIOSPROD)/packages;$(IPCSRC)/packages;$(CEPROD)/packages;$(FCPROD)/packages;$(XDAISPROD)/packages;$(OSALPROD)/packages;$(DSPDCEMMSRC)/extrel/ti/dsp_codecs/packages;$(DSPDCEMMSRC)/src;

# Custom settings for build
JOBS		?= 1
# Set profile, always set as release version. Alternate option is "debug"
PROFILE		?= release
# Set debug/trace level from 0 to 4
TRACELEVEL	?= 0
# Offloads core to sysm3 code
OFFLOAD		?= 1
# Set to Non-SMP by default
FORSMP		?= 0
# Set Instrumentation to be allowed (ENABLE to enable it)
SETINST		?= ENABLE
# Set HW revision type- OMAP5:ES20, VAYU:ES10
HWVERSION   ?= ES10

all: dspbin

# Include platform build configuration
config:
ifeq (bldcfg.mk,$(wildcard bldcfg.mk))
include bldcfg.mk
else
	@echo "No config selected. Please configure the build first and then try to build."
	@echo "For more info, use 'make help'"
	@exit 1
endif

unconfig:
	@echo "Removed existing configuration"
	@rm -f bldcfg.mk

vayu_config: unconfig
	@echo "Creating new config\c"
	@echo DSP_CONFIG = vayu_config > bldcfg.mk
	@echo ".\c"
	@echo MYXDCARGS=\"profile=$(PROFILE) trace_level=$(TRACELEVEL) hw_type=VAYU hw_version=$(HWVERSION) BIOS_type=non-SMP\" >> bldcfg.mk
	@echo ".\c"
	@echo CHIP = VAYU >> bldcfg.mk
	@echo ".\c"
	@echo FORSMP = 0 >> bldcfg.mk
	@echo ".\c"
	@echo DSPBINNAME = "dra7xx-c66x-dsp.xe66" >> bldcfg.mk
	@echo INTBINNAME = "dsp.xe66" >> bldcfg.mk
	@echo ".\c"
	@echo "done"

clean: config
	export XDCARGS=$(MYXDCARGS); \
	 $(XDCROOT)/xdc --jobs=$(JOBS) clean -PD $(DSPDCEMMSRC)/platform/ti/dce/baseimage/.

build: config
ifeq ($(IPCSRC),)
	@echo "ERROR: IPCSRC not set. Exiting..."
	@echo "For more info, use 'make help'"
	@exit 1
else ifeq ($(C66XCGTOOLSPATH),)
	@echo "ERROR: C66XCGTOOLSPATH not set. Exiting..."
	@echo "For more info, use 'make help'"
	@exit 1
endif
	export XDCARGS=$(MYXDCARGS); \
	$(XDCROOT)/xdc --jobs=$(JOBS) -PD $(DSPDCEMMSRC)/platform/ti/dce/baseimage/.

dspbin: build
ifeq ($(FORSMP),0)
	$(C66XCGTOOLSPATH)/bin/strip6x $(DSPDCEMMSRC)/platform/ti/dce/baseimage/out/dsp/$(PROFILE)/$(INTBINNAME) -o=$(DSPBINNAME)
else
	@echo "***********Not yet implemented************"
endif

info: tools sources custom
tools:
	@echo "REPO    := $(REPO)"
	@echo "XDC     := $(XDCDIST_TREE)"
	@echo "BIOS    := $(BIOSPROD)"
	@echo "OSAL    := $(OSALPROD)"
	@echo "FC      := $(FCPROD)"
	@echo "CE      := $(CEPROD)"
	@echo "XDAIS   := $(XDAISPROD)"
	@echo "C66XCGTOOLSPATH := $(C66XCGTOOLSPATH)"
	@echo " "

sources:
	@echo "IPC  := $(IPCSRC)"
	@echo " "

	@echo "DSPDCEMMSRC  := $(DSPDCEMMSRC)"
	@echo "DSPDCEMMSRC info: $(shell git --git-dir=$(DSPDCEMMSRC)/.git --work-tree=$(DSPDCEMMSRC)/ log --pretty=format:'%ad %h %d' --oneline --date=short -1 )"
	@echo "DUCATIMMSRC describe: $(shell git --git-dir=$(DSPDCEMMSRC)/.git --work-tree=$(DSPDCEMMSRC)/ describe --dirty)"
	@echo " "

custom:
	@echo "JOBS       := $(JOBS)"
	@echo "PROFILE    := $(PROFILE)"
	@echo "TRACELEVEL := $(TRACELEVEL)"
	@echo "OFFLOAD    := $(OFFLOAD)"
	@echo "FORSMP     := $(FORSMP)"
	@echo "SETINST    := $(SETINST)"
	@echo "HWVERSION  := $(HWVERSION)"
	@echo " "
	@echo "Ducati configuration used:  $(DSP_CONFIG)"
	@echo "Ducati binary name:         $(DSPBINNAME)"
	@echo " "

help:
	@echo " "
	@echo "Please export the following variables: "
	@echo " 1. BIOSTOOLSROOT - Directory where all the BIOS tools are installed."
	@echo "                    If not mentioned, picks up the default, /opt/ti"
	@echo " 2. C66XCGTOOLSPATH - DSP Code Generation Tools installation path"
	@echo "                       If not mentioned, tries the default install location, /opt/ti/TI_CGT_TI_ARM_5.0.1"
	@echo " 3. IPCSRC - Absolute path of the $(IPCVERSION)"
	@echo " 4. [Optional] - Any of the following variables can be defined to customize your build."
	@echo "       JOBS       - To specify the number of parallel build jobs (default is 1)"
	@echo "       PROFILE    - 'release' or 'debug' profile for the libraries and binaries (default is release)"
	@echo "       TRACELEVEL - From 0 to 4. Higher the value, more the traces. 0 implies no traces (default is 0)"
	@echo "       OFFLOAD    - Enable offloading support (default is 1, set to 0 to disable)"
	@echo " 5. [Optional] - Any of the following variables can be defined to change the default tool versions."
	@echo "       XDCVERSION       = $(XDCDIST_TREE)"
	@echo "       BIOSVERSION      = $(BIOSPROD)"
	@echo "       IPCVERSION       = $(IPCSRC)"
	@echo "       CEVERSION        = $(CEPROD)"
	@echo "       FCVERSION        = $(FCPROD)"
	@echo "       XDAISVERSION     = $(XDAISPROD)"
	@echo "       OSALVERSION      = $(OSALPROD)"
	@echo "       C66XCGTOOLSPATH = $(C66XCGTOOLSPATH)"
	@echo " "
	@echo "Use the appropriate make targets from the following: "
	@echo "  Configure Platform: "
	@echo "     OMAP5 (SMP)       - export HWVERSION=ES20 && make omap5_smp_config"
	@echo "     VAYU/J6 (SMP)     - export HWVERSION=ES10 && make vayu_smp_config"
	@echo "  Build:               - make"
	@echo "  Clean:               - make clean"
	@echo "  Generate Binary: "
	@echo "     Firmware        - make dspbin"
	@echo "  Information: "
	@echo "     Tools           - make tools"
	@echo "     Sources         - make sources"
	@echo "     Custom          - make custom"
	@echo "     all 3           - make info"
	@echo "  Others: "
	@echo "     Check config    - make config"
	@echo "     Clean config    - make unconfig"
	@echo " "
