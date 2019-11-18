FROM python:3

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN pip install -q biopython pandas ete3 xlrd

# annotation
COPY Annotation/viral_contigs_annotation.py /viral_contigs_annotation.py

# assign
RUN python -c 'from ete3 import NCBITaxa; NCBITaxa()'
COPY Assign/contig_taxonomic_assign.py /contig_taxonomic_assign.py

# getPredictedFaa
COPY GetPredictedFaa/get_predicted_faa.py /get_predicted_faa.py

# lenghtFiltering
COPY LengthFiltering/filter_contigs_len.py /filter_contigs_len.py

# parsingPredictions
COPY ParsingPredictions/vs_vf_categories.py /vs_vf_categories.py

# ratioEvalue
COPY RatioEvalue/Additional_data_vpHMMs.xlsx /Additional_data_vpHMMs.xlsx
COPY RatioEvalue/Ratio_Evalue_table.py /Ratio_Evalue_table.py
COPY RatioEvalue/vphmm_taxa_dict.py /vphmm_taxa_dict.py

CMD ["python"]