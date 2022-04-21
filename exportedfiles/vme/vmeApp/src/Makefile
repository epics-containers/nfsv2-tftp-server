TOP = ../..
include $(TOP)/configure/CONFIG

PROD_IOC_RTEMS = vme
DBD += vme.dbd
vme_DBD += base.dbd
vme_DBD += drvIpac.dbd
vme_DBD += Hy8401ip.dbd
vme_DBD += asyn.dbd
vme_DBD += Hy8402ip.dbd
#vme_DBD += funcgenRecord.dbd
vme_SRCS += vme_registerRecordDeviceDriver.cpp
vme_SRCS += vmeMain.cpp
vme_LIBS += Hy8402ip
vme_LIBS += asyn
vme_LIBS += Hy8401ip
vme_LIBS += Ipac
vme_LIBS += $(EPICS_BASE_IOC_LIBS)

include $(TOP)/configure/RULES

