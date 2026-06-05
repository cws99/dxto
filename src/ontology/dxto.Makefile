## Customize Makefile settings for dxto
##
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

# ============================================================
# Source files for the two custom components
# ============================================================

DIAG_REL_SRC  = $(COMPONENTSDIR)/dxto-diagnostic-relations.tsv
MAPPINGS_SRC  = $(COMPONENTSDIR)/dxto-mappings.sssom.tsv

# Wire TSV validation into the test suite
ALL_TSV_FILES += $(DIAG_REL_SRC) $(MAPPINGS_SRC)

# ============================================================
# Component: dxto-diagnostic-relations.owl
#
# Source: $(DIAG_REL_SRC)  (ROBOT template TSV)
# Columns: test (ID) | disease (SC dxto:is_diagnostic_for some %)
#          | role | tier | evidence | guideline_provenance
#
# The stamp-file pattern is the ODK-approved override point:
# building logic lives in the stamp rule; the main Makefile's
# $(COMPONENTSDIR)/%.owl rule just ensures the file exists.
# ============================================================

$(TMPDIR)/stamp-component-dxto-diagnostic-relations.owl: \
		$(DIAG_REL_SRC) $(SRC) | $(TMPDIR)
	$(ROBOT) template \
		--input $(SRC) \
		--template $(DIAG_REL_SRC) \
		--prefix "DXTO: http://purl.obolibrary.org/obo/DXTO_" \
		--prefix "MONDO: http://purl.obolibrary.org/obo/MONDO_" \
		--prefix "dxto: http://purl.obolibrary.org/obo/dxto/" \
		--prefix "dcterms: http://purl.org/dc/terms/" \
		annotate \
		  --ontology-iri $(ONTBASE)/components/dxto-diagnostic-relations.owl \
		-o $(COMPONENTSDIR)/dxto-diagnostic-relations.owl && \
	touch $@

# ============================================================
# Component: dxto-mappings.owl
#
# Source: $(MAPPINGS_SRC)  (SSSOM TSV with metadata header)
# Converts to OWL-RDF via the sssom-utils CLI, then re-annotates
# the ontology IRI so catalog-v001.xml can resolve it correctly.
# ============================================================

$(TMPDIR)/stamp-component-dxto-mappings.owl: \
		$(MAPPINGS_SRC) | $(TMPDIR)
	sssom convert \
		--input $< \
		--output-format owl-rdf \
		-o $(TMPDIR)/mappings-raw.owl && \
	$(ROBOT) annotate \
		-i $(TMPDIR)/mappings-raw.owl \
		--ontology-iri $(ONTBASE)/components/dxto-mappings.owl \
		-o $(COMPONENTSDIR)/dxto-mappings.owl && \
	touch $@
