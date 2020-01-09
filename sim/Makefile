################################################################################
##                                                                            ##
##  This confidential and proprietary software may be used only               ##
##  as authorized by a licensing agreement from CoWare, Inc.                  ##
##  In the event of publication, the following notice is applicable:          ##
##                                                                            ##
##      (c) COPYRIGHT 2001-2009 COWARE, INC.                                  ##
##             ALL RIGHTS RESERVED                                            ##
##                                                                            ##
##  The entire notice above must be reproduced on all authorized copies.      ##
##                                                                            ##
################################################################################
##
##  This file was generated automatically by
##  CoWare Processor Generator!
##  Version 2009.1.1 Linux -- May, 2009
## 
##
##      FileName: makefile
##      Date:     Mon Apr 13 2015
## 	Modified: Hailong Jiao
################################################################################


export WORKLIB=work

# Tool settings
VCOMP = ncvlog
VCOMP_OPTIONS = -incdir ${SRC_RTL} -w
VELAB = ncelab
VELAB_OPTIONS = -access +rwc  -timescale 1ns/1ps -work ${WORKLIB}
VSIM = ncsim
VSIM_OPTIONS = 


# settings for RTL simulation
SRC_RTL    = ..
SCR_NETLIST = ../synthesis/p+r_enc
LIB         = work
TOP_MODULE = TS3D_tb
SOURCE_TESTBENCH = ${SRC_RTL}/testbench/TS3D/TS3D_tb.v \
										${SRC_RTL}/include/dw_params_presim.vh 
SOURCES   = ${SRC_RTL}/source/TS3D/TS3D.v \
						${SRC_RTL}/source/CONFIG/CONFIG.v \
						${SRC_RTL}/source/PEL/PEL.v\
						${SRC_RTL}/source/PEB/PEB.v\
						${SRC_RTL}/source/PEC/PEC.v\
						${SRC_RTL}/source/CNVROW/CNVROW.v\
						${SRC_RTL}/source/MACAW/MACAW.v\
						${SRC_RTL}/source/FLGOFFSET/FLGOFFSET.v\
						${SRC_RTL}/source/CTRLWEI/CTRLWEI.v\
						${SRC_RTL}/source/DISWEI/DISWEI.v\
						${SRC_RTL}/source/CTRLACT/CTRLACT.v\
						${SRC_RTL}/source/DISACT/DISACT.v\
						${SRC_RTL}/source/PACKER/PACKER.v\
						${SRC_RTL}/source/primitives/RAM_SIM/SRAM_DUAL.v\
		          	     
NETLIST   =  ${SCR_NETLIST}/TOP_ASIC_synth.v \
	     /workspace/technology/umc/55nm/SC/fuctional_lib/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055LSCLPMVBDR-LIBRARY_TAPE_OUT_KIT-Ver.B01_P.B/verilog/u055lsclpmvbdr_sdf30_nv.v \
/workspace/technology/umc/55nm_201908/IO/verilog/u055giolp25mvirfs.v \
	     
	     
targets:
	@echo "targets: [ dir | comp | elab | gui | comp_synth | elab_synth | gui_synth | tcf | clean ]"

dir:
	@if [ ! -d ${LIB} ]; then mkdir ${LIB} ; fi
		     
comp: dir ${SOURCES} ${SOURCE_TESTBENCH}
	@if [ ! -d ${LIB} ]; then mkdir ${LIB} ; fi
	${VCOMP} ${VCOMP_OPTIONS} ${LIB} ${SOURCES} ${SOURCE_TESTBENCH}

elab: comp
	${VELAB} ${VELAB_OPTIONS} ${TOP_MODULE}

gui: 	
	${VSIM} -GUI ${VSIM_OPTIONS} ${LIB}.${TOP_MODULE}	

comp_synth: dir ${SOURCES} ${SOURCE_TESTBENCH}
	@if [ ! -d ${LIB} ]; then mkdir ${LIB} ; fi
	${VCOMP} ${VCOMP_OPTIONS}  ${LIB} ${NETLIST} ${SOURCE_TESTBENCH}
	
elab_synth: comp_synth
	${VELAB} ${VELAB_OPTIONS} -nonotifier -sdf_file ../synthesis/gate/TOP_ASIC_synth.sdf ${TOP_MODULE}
# 	${VELAB} ${VELAB_OPTIONS} -sdf_file ../synthesis/gate/top_asyncFIFO.sdf ${TOP_MODULE}

gui_synth:	
	${VSIM} -GUI ${VSIM_OPTIONS} ${LIB}.${TOP_MODULE}
	
tcf:
	${VSIM} -input test.tcl  ${LIB}.${TOP_MODULE}
	
sdf:
	echo "start compiling sdf file...."
	ncsdfc ./gate/LT_RISC_32p5.sdf
	
clean:
	rm -rf ${WORKLIB}
	rm -rf ncelab.log ncsim.key ncsim.log ncvlog.log	
