TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS BELOW HERE

# Use typed rset structure (see 3.16.1 release notes)
USR_CPPFLAGS += -DUSE_TYPED_RSET

# xxxRecord.h will be created from xxxRecord.dbd
DBDINC += xxxRecord

# Install xxxSupport.dbd into <top>/dbd
DBD += xxxSupport.dbd

# Build an IOC support library
LIBRARY_IOC += sampleIOCSupport

# Compile and add code to the support library
sampleIOCSupport_SRCS += xxxRecord.c
sampleIOCSupport_SRCS += devXxxSoft.c

# Link locally-provided code into the support library,
# rather than directly into the IOC application, that
# causes problems on Windows DLL builds
sampleIOCSupport_SRCS += dbSubExample.c
sampleIOCSupport_SRCS += devsampleIOCVersion.c
sampleIOCSupport_SRCS += sampleIOCHello.c
sampleIOCSupport_SRCS += initTrace.c

sampleIOCSupport_LIBS += $(EPICS_BASE_IOC_LIBS)

# Auto-generate a header file containing a version string.
# Version comes from the VCS if available, else date+time.
GENVERSION = sampleIOCVersion.h
# Macro name
GENVERSIONMACRO = sampleIOCVERSION

# Build the IOC application
PROD_IOC = sampleIOC

# sampleIOC.dbd will be created and installed
DBD += sampleIOC.dbd

# sampleIOC.dbd will include these files:
sampleIOC_DBD += base.dbd
sampleIOC_DBD += xxxSupport.dbd
sampleIOC_DBD += dbSubExample.dbd
sampleIOC_DBD += devsampleIOCVersion.dbd
sampleIOC_DBD += sampleIOCHello.dbd
sampleIOC_DBD += initTrace.dbd

# sampleIOC_registerRecordDeviceDriver.cpp derives from sampleIOC.dbd
sampleIOC_SRCS += sampleIOC_registerRecordDeviceDriver.cpp

# Build the main IOC entry point where needed
sampleIOC_SRCS_DEFAULT += sampleIOCMain.cpp
sampleIOC_SRCS_vxWorks += -nil-

# Link in the code from our support library
sampleIOC_LIBS += sampleIOCSupport

# To build SNL programs, SNCSEQ must be defined
# in the <top>/configure/RELEASE file
ifneq ($(SNCSEQ),)
    # Build sncExample into sampleIOCSupport
    sncExample_SNCFLAGS += +r
    sampleIOC_DBD += sncExample.dbd
    # A .stt sequence program is *not* pre-processed:
    sampleIOCSupport_SRCS += sncExample.stt
    sampleIOCSupport_LIBS += seq pv
    sampleIOC_LIBS += seq pv

    # Build sncProgram as a standalone program
    PROD_HOST += sncProgram
    sncProgram_SNCFLAGS += +m
    # A .st sequence program *is* pre-processed:
    sncProgram_SRCS += sncProgram.st
    sncProgram_LIBS += seq pv
    sncProgram_LIBS += $(EPICS_BASE_HOST_LIBS)
endif

# Link QSRV (pvAccess Server) if available
ifdef EPICS_QSRV_MAJOR_VERSION
    sampleIOC_LIBS += qsrv
    sampleIOC_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)
    sampleIOC_DBD += PVAServerRegister.dbd
    sampleIOC_DBD += qsrv.dbd
endif

# Finally link IOC to the EPICS Base libraries
sampleIOC_LIBS += $(EPICS_BASE_IOC_LIBS)

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD EXTRA GNUMAKE RULES BELOW HERE

# Explicit dependency needed for generated header file
devsampleIOCVersion$(DEP): $(COMMON_DIR)/$(GENVERSION)
