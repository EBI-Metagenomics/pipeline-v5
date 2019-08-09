#!/usr/bin/env python3

import os
import re
import argparse
import sys
import glob
import pandas as pd
from Bio import SeqIO

def virus_parser(**kwargs):
	
	HC_viral_predictions, LC_viral_predictions, prophage_predictions = [[] for _ in range(3)]
	HC_viral_predictions_names, LC_viral_predictions_names, prophage_predictions_names = ['' for _ in range(3)]

	VF_result_df = pd.read_csv(kwargs["VF_output"], sep="\t")

	# VF_high_ids
	VF_high_ids = list(VF_result_df[(VF_result_df["pvalue"] < 0.05) & (VF_result_df["score"] >= 0.90)]["name"].values)
	if len(VF_high_ids) < 1:
		print("No contigs with p < 0.05 and score >= 0.90 were reported by VirFinder")
	else:
		print(str(len(VF_high_ids)) + ' found VF high ids')

	# VF_low_ids
	VF_low_ids = list(VF_result_df[(VF_result_df["pvalue"] < 0.05) & (VF_result_df["score"] >= 0.70) & (VF_result_df["score"] < 0.9)]["name"].values)
	if len(VF_low_ids) < 1:
		print("No contigs with p < 0.05 and 0.70 <= score < 0.90 were reported by VirFinder")
	else:
		print(str(len(VF_low_ids)) + ' found VF low ids')

	if len(glob.glob(os.path.join(kwargs["VS_output"], "*.fasta"))) > 0:
		VirSorter_viral_high = [x for x in glob.glob(os.path.join(kwargs["VS_output"], "*.fasta")) if re.search(r"cat-[12]\.fasta$", x)]
		VirSorter_viral_low = glob.glob(os.path.join(kwargs["VS_output"], "*cat-3.fasta"))[0]
		VirSorter_prophages = [x for x in glob.glob(os.path.join(kwargs["VS_output"], "*.fasta")) if re.search(r"cat-[45]\.fasta$", x)]
		print('VirSorter_viral_high', VirSorter_viral_high)
		print('VirSorter_viral_low', VirSorter_viral_low)
		print('VirSorter_prophages', VirSorter_prophages)

		print("\nBeginning the identification of high confidence _viral predictions...")

		VS_high_tuples = []
		search_id = re.compile(r"VIRSorter_([\w_]+)-([\w_-]*cat_\d)")  # was: "VIRSorter_([\w]+)-([a-z-]*cat_\d)"
		# Example: >VIRSorter_ERZ1024424_110-NODE-110-length-5464-cov-66_245332-cat_1
		for item in VirSorter_viral_high:  # VIRSorter_cat-1.fasta, VIRSorter_cat-2.fasta
			if os.stat(item).st_size != 0:
				with open(item) as input_file:
					for line in input_file:
						if search_id.search(line):
							VS_high_tuples.append((search_id.search(line).group(1), search_id.search(line).group(2)))
		print('VS high tuples:' + str(len(VS_high_tuples)))
		if len(VS_high_tuples) > 0:
			for x, y in VS_high_tuples:
				for record in SeqIO.parse(kwargs["assembly_file"], "fasta"):
					contig_id_search = re.sub(r"[.,:; ]", "_", record.description)
					if contig_id_search == x and record.description in VF_high_ids:
						if "circular" in y:
							suff = "11_H_%s_circular" % y.split("_")[1]
						else:
							suff = "11_H_%s" % y.split("_")[1]
						record.id = "%s_%s" % (record.id, suff)
						record.description = "_".join(record.description.split()[1:])
						HC_viral_predictions.append(record)
						break
					elif contig_id_search == x and record.description in VF_low_ids:
						if "circular" in y:
							suff = "11_L_%s_circular" % y.split("_")[1]
						else:
							suff = "11_L_%s" % y.split("_")[1]
						record.id = "%s_%s" % (record.id, suff)
						record.description = "_".join(record.description.split()[1:])
						HC_viral_predictions.append(record)
						break
					elif contig_id_search == x:
						if "circular" in y:
							suff = "01_%s_circular" % y.split("_")[1]
						else:
							suff = "01_%s" % y.split("_")[1]
						record.id = "%s_%s" % (record.id, suff)
						record.description = "_".join(record.description.split()[1:])
						HC_viral_predictions.append(record)
						break
			print('HC_viral_predictions', len(HC_viral_predictions))

			VS_high_ids = [x[0] for x in VS_high_tuples]
			VF_high_ids = [x for x in VF_high_ids if re.sub(r"[.,:; ]", "_", x) not in VS_high_ids]  # VF high - VS high
			VF_low_ids = [x for x in VF_low_ids if re.sub(r"[.,:; ]", "_", x) not in VS_high_ids]  # VF low - VS high
			print("High confidence _viral predictions identified")

		else:
			print("No contigs were retrieved from VirSorter categories 1 and 2, therefore no high confidence _viral contigs were reported")
			
		print("\nBeginning the identification of low confidence _viral predictions...")

		VS_low_tuples = []
		if os.stat(VirSorter_viral_low).st_size != 0:
			with open(VirSorter_viral_low) as input_file:
				for line in input_file:
					if search_id.search(line):
						VS_low_tuples.append((search_id.search(line).group(1), search_id.search(line).group(2)))

		if len(VS_low_tuples) > 0:
			id_suffix_list = []
			if len(VF_high_ids) > 0:
				for item in VF_high_ids:
					for x,y in VS_low_tuples:
						if re.sub(r"[.,:; ]", "_", item) == x:
							if "circular" in y:
								id_suffix_list.append((item, "11_H_3_circular"))
							else:
								id_suffix_list.append((item, "11_H_3"))
							break
					if item not in [elem[0] for elem in id_suffix_list]:
						id_suffix_list.append((item, "10_H"))
			if len(VF_low_ids) > 0:
				for item in VF_low_ids:
					for x,y in VS_low_tuples:
						if re.sub(r"[.,:; ]", "_", item) == x:
							if "circular" in y:
								id_suffix_list.append((item, "11_L_3_circular"))
							else:
								id_suffix_list.append((item, "11_L_3"))
							break
			if len(id_suffix_list) > 0:
				for x,y in id_suffix_list:
					for record in SeqIO.parse(kwargs["assembly_file"], "fasta"):
						if record.description == x:
							record.id = "%s_%s" % (record.id, y)
							record.description = "_".join(record.description.split()[1:])
							LC_viral_predictions.append(record)
							lc_description_changed = '.'.join(record.description.split('_'))  # changge _ to .
							LC_viral_predictions_names += lc_description_changed + '\n'
							break

		else:
			print("No contigs were reported as VirSorter category 3")
			
			if len(VF_high_ids) > 0:
				for item in VF_high_ids:
					for record in SeqIO.parse(kwargs["assembly_file"], "fasta"):
						if record.description == item:
							record.id = record.id + "_10_H"
							record.description = "_".join(record.description.split()[1:])
							LC_viral_predictions.append(record)
							lc_description_changed = '.'.join(record.description.split('_'))  # changge _ to .
							LC_viral_predictions_names += lc_description_changed + '\n'
							break

		if len(LC_viral_predictions) < 1:
			print("No low confidence _viral contigs were reported")
		
		else:
			print("Low confidence _viral predictions identified")
			
		print("Beginning the identification of prophage predictions")

		search_id = re.compile(r"VIRSorter_(.+?)_(gene_\d+_gene_\d+[0-9-]+cat_\d)")
		for item in VirSorter_prophages:
			if os.stat(item).st_size != 0:
				for prophage in SeqIO.parse(item, "fasta"):
					prophage_description = search_id.search(prophage.description).group(1)
					prophage_suffix = search_id.search(prophage.description).group(2)
					for record in SeqIO.parse(kwargs["assembly_file"], "fasta"):
						if re.sub(r"[.,:; ]", "_", record.description) == prophage_description:
							prophage.id = "%s_%s" % (record.id, prophage_suffix)
							prophage_description_changed = '.'.join(prophage_description.split('_'))  #changge _ to .
							prophage_predictions_names += prophage_description_changed + '\n'
							prophage.description = "_".join(record.description.split()[1:])
							prophage_predictions.append(prophage)
							break

		if len(prophage_predictions) < 1:
			print("No putative prophages were reported by VirSorter in categories 4 and 5")
		
		else:
			print("Prophage predictions identified")
			
	else:
		print("No putative _viral sequences were reported by VirSorter")
		
		if len(VF_high_ids) > 0:
			
			print("Beginning the identification of low confidence _viral predictions by VirFinder...")
			
			for item in VF_high_ids:
				for record in SeqIO.parse(kwargs["assembly_file"], "fasta"):
					if record.description == item:
						record.id = record.id + "_10_H"
						record.description = "_".join(record.description.split()[1:])
						LC_viral_predictions.append(record)
						lc_description_changed = '.'.join(record.description.split('_'))  # change _ to .
						LC_viral_predictions_names += lc_description_changed + '\n'
						break
						
			print("Low confidence _viral predictions by VirFinder identified")
					
	return [HC_viral_predictions, LC_viral_predictions, prophage_predictions, \
		   HC_viral_predictions_names, LC_viral_predictions_names, prophage_predictions_names]


if __name__ == "__main__":
	"""
	parser = argparse.ArgumentParser(description="Write fasta files with predicted _viral contigs sorted in categories and putative prophages")
	parser.add_argument("-a", "--assemb", dest="assemb", help="Metagenomic assembly fasta file", required=True)
	parser.add_argument("-f", "--vfout", dest="finder", help="Absolute or relative path to VirFinder output file",
						required=True)
	parser.add_argument("-s", "--vsdir", dest="sorter",
						help="Absolute or relative path to directory containing VirSorter output", required=True)
	parser.add_argument("-o", "--outdir", dest="outdir",
						help="Absolute or relative path of directory where output _viral prediction files should be stored (default: cwd)",
						default=".")
	if len(sys.argv) == 1:
		parser.print_help()
	else:
		args = parser.parse_args()
	
		viral_predictions = virus_parser(assembly_file=args.assemb, VF_output=args.finder, VS_output=args.sorter)

		if sum([len(x) for x in viral_predictions]) > 0:
			if len(viral_predictions[0]) > 0:
				SeqIO.write(viral_predictions[0], os.path.join(args.outdir, "High_confidence_putative_viral_contigs.fna"), "fasta")
				with open(os.path.join(args.outdir, "High_confidence_putative_names.fna"), 'w') as low_names:
					low_names.write(viral_predictions[3])

			if len(viral_predictions[1]) > 0:
				SeqIO.write(viral_predictions[1], os.path.join(args.outdir, "Low_confidence_putative_viral_contigs.fna"), "fasta")
				with open(os.path.join(args.outdir, "Low_confidence_putative_names.fna"), 'w') as low_names:
					low_names.write(viral_predictions[4])

			if len(viral_predictions[2]) > 0:
				SeqIO.write(viral_predictions[2], os.path.join(args.outdir, "Putative_prophages.fna"), "fasta")
				with open(os.path.join(args.outdir, "Putative_prophages_names.fna"), 'w') as proph_names:
					proph_names.write(viral_predictions[5])

		else:
			print("Overall, no putative _viral contigs or prophages were detected in the analysed metagenomic assembly")
	"""
	viral_predictions = virus_parser(assembly_file="../../../workflows/Files_viral/chunk_1_filt500bp.fasta",
									 VF_output="../../../workflows/Files_viral/VirFinder_output.tsv",
									 VS_output="../../../workflows/Files_viral/Predicted_viral_sequences")