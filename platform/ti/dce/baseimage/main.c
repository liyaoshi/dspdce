/*
 * Copyright (c) 2011, Texas Instruments Incorporated
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * *  Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * *  Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * *  Neither the name of Texas Instruments Incorporated nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <xdc/std.h>
#include <xdc/cfg/global.h>
#include <xdc/runtime/System.h>
#include <xdc/runtime/Diags.h>
#include <xdc/runtime/Error.h>

#include <ti/ipc/MultiProc.h>
#include <ti/sysbios/BIOS.h>
#include <ti/sysbios/knl/Task.h>
#include <ti/ipc/rpmsg/_RPMessage.h>
#include <ti/ipc/remoteproc/Resource.h>

#include <ti/grcm/RcmTypes.h>
#include <ti/grcm/RcmServer.h>
#include <ti/framework/dce/dce_priv.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Include the custom resource table for memory configuration.
#if (defined VAYU_ES10)
#include "custom_rsc_table_vayu_dsp.h"
#elif (defined OMAP5432_ES20)
#include "custom_rsc_table_omap5_dsp.h"
#endif

extern uint32_t    dce_debug;

/* Legacy function to allow Linux side rpmsg sample tests to work: */
extern void start_ping_tasks();

static unsigned int SyslinkMemUtils_VirtToPhys(Ptr Addr)
{
    unsigned int    pa;

    if( !Addr || Resource_virtToPhys((unsigned int) Addr, &pa)) {
        return (0);
    }
    return (pa);
}

void *MEMUTILS_getPhysicalAddr(Ptr vaddr)
{
    unsigned int    paddr = SyslinkMemUtils_VirtToPhys(vaddr);

    DEBUG("virtual addr:%x\tphysical addr:%x", vaddr, paddr);
    return ((void *)paddr);
}

void tools_ShowVersion()
{
    System_printf("\n\n **** DSPMM VERSION INFO **** \n\nCompile DATE %s TIME %s \n", __DATE__, __TIME__);

    System_printf("\n** DSPMM VERSION INFO END ** \n");
#if 0
    System_printf("Trace Buffer PA 0x%x Trace Level %d\
                   \nTrace Usage: level:[0-4: 0-no trace, 1-err, 2-debug, 3-info, 4-CE,FC,IPC traces] \n\n",
                  MEMUTILS_getPhysicalAddr((Ptr)(TRACEBUFADDR)), dce_debug);
#endif
}

int main(int argc, char * *argv)
{
    extern void start_load_task(void);
    UInt16    hostId;

    /* Set up interprocessor notifications */
    System_printf("%s starting..\n", MultiProc_getName(MultiProc_self()));

    hostId = MultiProc_getId("HOST");
    RPMessage_init(hostId);

    /* Some background ping testing tasks, used by rpmsg samples: */
    start_ping_tasks();

    /* CPU load reporting in the trace. */
   // start_load_task();

    /* Dump Tools version */
    tools_ShowVersion();

    BIOS_start();

    return (0);
}

