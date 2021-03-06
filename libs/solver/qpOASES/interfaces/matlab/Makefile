##
##	This file is part of qpOASES.
##
##	qpOASES -- An Implementation of the Online Active Set Strategy.
##	Copyright (C) 2007-2012 by Hans Joachim Ferreau, Andreas Potschka,
##	Christian Kirches et al. All rights reserved.
##
##	qpOASES is free software; you can redistribute it and/or
##	modify it under the terms of the GNU Lesser General Public
##	License as published by the Free Software Foundation; either
##	version 2.1 of the License, or (at your option) any later version.
##
##	qpOASES is distributed in the hope that it will be useful,
##	but WITHOUT ANY WARRANTY; without even the implied warranty of
##	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
##	See the GNU Lesser General Public License for more details.
##
##	You should have received a copy of the GNU Lesser General Public
##	License along with qpOASES; if not, write to the Free Software
##	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
##



##
##	Filename:  src/interfaces/matlab/Makefile
##	Author:    Hans Joachim Ferreau, Andreas Potschka, Christian Kirches
##	Version:   3.0beta
##	Date:      2007-2012
##

include ../../make.mk

##
##	flags
##

IDIR = ../../include

IFLAGS      =  -I. \
               -I${IDIR} \
               -I${MATLAB_DIR}

EXTRAFLAGS = -D__cpluplus -D__MATLAB__ -D__NO_COPYRIGHT__ -largeArrayDims

QPOASES_OBJECT = qpOASES.${OBJEXT}
QPOASES_SEQUENCE_OBJECT = qpOASES_sequence.${OBJEXT}
QPOASES_SEQUENCE_SB_OBJECT = qpOASES_sequenceSB.${OBJEXT}

##
##	targets
##

all: ${BINDIR}/qpOASES.${MEXEXT} ${BINDIR}/qpOASES_sequence.${MEXEXT} ${BINDIR}/qpOASES_sequenceSB.${MEXEXT} copyMs

${BINDIR}/qpOASES.${MEXEXT}: ${QPOASES_OBJECT} 
	@${ECHO} "Creating" $@
	@${CPP} -shared -o $@ $? ${QPOASES_LINK} ${LINK_LIBRARIES}

${BINDIR}/qpOASES_sequence.${MEXEXT}: ${QPOASES_SEQUENCE_OBJECT} 
	@${ECHO} "Creating" $@
	@${CPP} -shared -o $@ $? ${QPOASES_LINK} ${LINK_LIBRARIES}

${BINDIR}/qpOASES_sequenceSB.${MEXEXT}: ${QPOASES_SEQUENCE_SB_OBJECT} 
	@${ECHO} "Creating" $@
	@${CPP} -shared -o $@ $? ${QPOASES_LINK} ${LINK_LIBRARIES}

copyMs:
	@${ECHO} "Copying M files ..."
	@${CP} qpOASES.m ${BINDIR}
	@${CP} qpOASES_options.m ${BINDIR}
	@${CP} qpOASES_sequence.m ${BINDIR}
	@${CP} qpOASES_sequenceSB.m ${BINDIR}
	@${CP} qpOASES_sequenceVM.m ${BINDIR}
	
clean:
	${RM} -f *.${OBJEXT}

clobber: clean

%.${OBJEXT}: %.cpp 
	@${ECHO} "Creating" $@
	@${CPP} ${DEF_TARGET} -c ${IFLAGS} ${EXTRAFLAGS} ${CPPFLAGS} $<


##
##	end of file
##
