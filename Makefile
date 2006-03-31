############################
# Change the task name!
############################
TASK = Abs_pointing

include /data/mta/MTA/include/Makefile.MTA

BIN  = abs_pointing_acis_plot.perl abs_pointing_comp_entry.perl abs_pointing_comp_second_time.perl abs_pointing_compute_pos_diff.perl abs_pointing_extract_obsid.perl abs_pointing_find_candidate.perl abs_pointing_get_coord_from_simbad.perl abs_pointing_hrci_plot.perl abs_pointing_hrcs_plot.perl abs_pointing_main.perl abs_pointing_print_html.perl abs_pointing_run_script abs_pointing_simbad_query.perl abs_pointing_wrap_script
DOC  = README
DATA = Query_mta.pm constellation constellation2

install:
ifdef BIN
	rsync --times --cvs-exclude $(BIN) $(INSTALL_BIN)/
endif
ifdef DATA
	mkdir -p $(INSTALL_DATA)
	rsync --times --cvs-exclude $(DATA) $(INSTALL_DATA)/
endif
ifdef DOC
	mkdir -p $(INSTALL_DOC)
	rsync --times --cvs-exclude $(DOC) $(INSTALL_DOC)/
endif
ifdef IDL_LIB
	mkdir -p $(INSTALL_IDL_LIB)
	rsync --times --cvs-exclude $(IDL_LIB) $(INSTALL_IDL_LIB)/
endif
ifdef CGI_BIN
	mkdir -p $(INSTALL_CGI_BIN)
	rsync --times --cvs-exclude $(CGI_BIN) $(INSTALL_CGI_BIN)/
endif
ifdef PERLLIB
	mkdir -p $(INSTALL_PERLLIB)
	rsync --times --cvs-exclude $(PERLLIB) $(INSTALL_PERLLIB)/
endif
ifdef WWW
	mkdir -p $(INSTALL_WWW)
	rsync --times --cvs-exclude $(WWW) $(INSTALL_WWW)/
endif
