#!/bin/bash
while getopts i: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
	esac
done

(echo -e '#query_name\tseed_eggNOG_ortholog\tseed_ortholog_evalue\tseed_ortholog_score\tbest_tax_level\tPreferred_name\tGOs\tEC\tKEGG_ko\tKEGG_Pathway\tKEGG_Module\tKEGG_Reaction\tKEGG_rclass\tBRITE\tKEGG_TC\tCAZy\tBiGG_Reaction' && cat ${INPUT}) > hmmscan_result.tbl