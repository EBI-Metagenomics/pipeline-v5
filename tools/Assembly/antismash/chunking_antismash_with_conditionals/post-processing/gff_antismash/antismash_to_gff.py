#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright 2021 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import argparse
import logging
import re
import subprocess
from urllib import parse

from Bio import SeqIO

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


"""
antismash smCOG mapping to feature types.
Taken and modified from:
- https://github.com/antismash/antismash/blob/4afc4f0a2cd94e12b525fad68fbabe39b48905ac/antismash/detection/genefunctions/smcogs.py
Mapping:
- https://github.com/antismash/antismash/blob/master/antismash/detection/genefunctions/data/cog_annotations.txt
"""
_SMCOG_TYPE_MAPPING = {
    "SMCOG1000": "transport",
    "SMCOG1001": "biosynthetic-additional",
    "SMCOG1002": "biosynthetic-additional",
    "SMCOG1003": "regulatory",
    "SMCOG1004": "biosynthetic-additional",
    "SMCOG1005": "transport",
    "SMCOG1006": "biosynthetic-additional",
    "SMCOG1007": "biosynthetic-additional",
    "SMCOG1008": "regulatory",
    "SMCOG1009": "biosynthetic-additional",
    "SMCOG1010": "biosynthetic-additional",
    "SMCOG1011": "transport",
    "SMCOG1012": "biosynthetic-additional",
    "SMCOG1013": "biosynthetic-additional",
    "SMCOG1014": "regulatory",
    "SMCOG1015": "regulatory",
    "SMCOG1016": "regulatory",
    "SMCOG1017": "biosynthetic-additional",
    "SMCOG1018": "biosynthetic-additional",
    "SMCOG1019": "biosynthetic-additional",
    "SMCOG1020": "transport",
    "SMCOG1021": "biosynthetic-additional",
    "SMCOG1022": "biosynthetic-additional",
    "SMCOG1023": "biosynthetic-additional",
    "SMCOG1024": "biosynthetic-additional",
    "SMCOG1025": "biosynthetic-additional",
    "SMCOG1026": "other",
    "SMCOG1027": "biosynthetic-additional",
    "SMCOG1028": "biosynthetic-additional",
    "SMCOG1029": "transport",
    "SMCOG1030": "regulatory",
    "SMCOG1031": "regulatory",
    "SMCOG1032": "regulatory",
    "SMCOG1033": "transport",
    "SMCOG1034": "biosynthetic-additional",
    "SMCOG1035": "biosynthetic-additional",
    "SMCOG1036": "biosynthetic-additional",
    "SMCOG1037": "other",
    "SMCOG1038": "biosynthetic-additional",
    "SMCOG1039": "biosynthetic-additional",
    "SMCOG1040": "biosynthetic-additional",
    "SMCOG1041": "regulatory",
    "SMCOG1042": "biosynthetic-additional",
    "SMCOG1043": "biosynthetic-additional",
    "SMCOG1044": "transport",
    "SMCOG1045": "biosynthetic-additional",
    "SMCOG1046": "biosynthetic-additional",
    "SMCOG1047": "biosynthetic-additional",
    "SMCOG1048": "regulatory",
    "SMCOG1049": "transport",
    "SMCOG1050": "biosynthetic-additional",
    "SMCOG1051": "transport",
    "SMCOG1052": "biosynthetic-additional",
    "SMCOG1053": "biosynthetic-additional",
    "SMCOG1054": "other",
    "SMCOG1055": "biosynthetic-additional",
    "SMCOG1056": "biosynthetic-additional",
    "SMCOG1057": "regulatory",
    "SMCOG1058": "regulatory",
    "SMCOG1059": "biosynthetic-additional",
    "SMCOG1060": "biosynthetic-additional",
    "SMCOG1061": "other",
    "SMCOG1062": "biosynthetic-additional",
    "SMCOG1063": "biosynthetic-additional",
    "SMCOG1064": "biosynthetic-additional",
    "SMCOG1065": "transport",
    "SMCOG1066": "biosynthetic-additional",
    "SMCOG1067": "transport",
    "SMCOG1068": "transport",
    "SMCOG1069": "transport",
    "SMCOG1070": "biosynthetic-additional",
    "SMCOG1071": "regulatory",
    "SMCOG1072": "biosynthetic-additional",
    "SMCOG1073": "other",
    "SMCOG1074": "transport",
    "SMCOG1075": "biosynthetic-additional",
    "SMCOG1076": "transport",
    "SMCOG1077": "other",
    "SMCOG1078": "regulatory",
    "SMCOG1079": "biosynthetic-additional",
    "SMCOG1080": "biosynthetic-additional",
    "SMCOG1081": "biosynthetic-additional",
    "SMCOG1082": "transport",
    "SMCOG1083": "biosynthetic-additional",
    "SMCOG1084": "biosynthetic-additional",
    "SMCOG1085": "transport",
    "SMCOG1086": "transport",
    "SMCOG1087": "other",
    "SMCOG1088": "biosynthetic-additional",
    "SMCOG1089": "biosynthetic-additional",
    "SMCOG1090": "biosynthetic-additional",
    "SMCOG1091": "biosynthetic-additional",
    "SMCOG1092": "other",
    "SMCOG1093": "biosynthetic-additional",
    "SMCOG1094": "other",
    "SMCOG1095": "biosynthetic-additional",
    "SMCOG1096": "transport",
    "SMCOG1097": "other",
    "SMCOG1098": "biosynthetic-additional",
    "SMCOG1099": "other",
    "SMCOG1100": "biosynthetic-additional",
    "SMCOG1101": "biosynthetic-additional",
    "SMCOG1102": "biosynthetic-additional",
    "SMCOG1103": "biosynthetic-additional",
    "SMCOG1104": "biosynthetic-additional",
    "SMCOG1105": "biosynthetic-additional",
    "SMCOG1106": "transport",
    "SMCOG1107": "transport",
    "SMCOG1108": "other",
    "SMCOG1109": "biosynthetic-additional",
    "SMCOG1110": "biosynthetic-additional",
    "SMCOG1111": "biosynthetic-additional",
    "SMCOG1112": "regulatory",
    "SMCOG1113": "transport",
    "SMCOG1114": "biosynthetic-additional",
    "SMCOG1115": "biosynthetic-additional",
    "SMCOG1116": "transport",
    "SMCOG1117": "transport",
    "SMCOG1118": "transport",
    "SMCOG1119": "biosynthetic-additional",
    "SMCOG1120": "regulatory",
    "SMCOG1121": "biosynthetic-additional",
    "SMCOG1122": "other",
    "SMCOG1123": "biosynthetic-additional",
    "SMCOG1124": "biosynthetic-additional",
    "SMCOG1125": "regulatory",
    "SMCOG1126": "regulatory",
    "SMCOG1127": "biosynthetic-additional",
    "SMCOG1128": "biosynthetic-additional",
    "SMCOG1129": "biosynthetic-additional",
    "SMCOG1130": "other",
    "SMCOG1131": "transport",
    "SMCOG1132": "other",
    "SMCOG1133": "regulatory",
    "SMCOG1134": "biosynthetic-additional",
    "SMCOG1135": "regulatory",
    "SMCOG1136": "regulatory",
    "SMCOG1137": "transport",
    "SMCOG1138": "biosynthetic-additional",
    "SMCOG1139": "biosynthetic-additional",
    "SMCOG1140": "biosynthetic-additional",
    "SMCOG1141": "biosynthetic-additional",
    "SMCOG1142": "other",
    "SMCOG1143": "biosynthetic-additional",
    "SMCOG1144": "biosynthetic-additional",
    "SMCOG1145": "biosynthetic-additional",
    "SMCOG1146": "biosynthetic-additional",
    "SMCOG1147": "biosynthetic-additional",
    "SMCOG1148": "other",
    "SMCOG1149": "regulatory",
    "SMCOG1150": "biosynthetic-additional",
    "SMCOG1151": "other",
    "SMCOG1152": "biosynthetic-additional",
    "SMCOG1153": "biosynthetic-additional",
    "SMCOG1154": "biosynthetic-additional",
    "SMCOG1155": "biosynthetic-additional",
    "SMCOG1156": "biosynthetic-additional",
    "SMCOG1157": "other",
    "SMCOG1158": "biosynthetic-additional",
    "SMCOG1159": "biosynthetic-additional",
    "SMCOG1160": "biosynthetic-additional",
    "SMCOG1161": "biosynthetic-additional",
    "SMCOG1162": "other",
    "SMCOG1163": "biosynthetic-additional",
    "SMCOG1164": "other",
    "SMCOG1165": "biosynthetic-additional",
    "SMCOG1166": "transport",
    "SMCOG1167": "regulatory",
    "SMCOG1168": "biosynthetic-additional",
    "SMCOG1169": "transport",
    "SMCOG1170": "biosynthetic-additional",
    "SMCOG1171": "regulatory",
    "SMCOG1172": "biosynthetic-additional",
    "SMCOG1173": "other",
    "SMCOG1174": "biosynthetic-additional",
    "SMCOG1175": "biosynthetic-additional",
    "SMCOG1176": "biosynthetic-additional",
    "SMCOG1177": "biosynthetic-additional",
    "SMCOG1178": "biosynthetic-additional",
    "SMCOG1179": "biosynthetic-additional",
    "SMCOG1180": "biosynthetic-additional",
    "SMCOG1181": "biosynthetic-additional",
    "SMCOG1182": "biosynthetic-additional",
    "SMCOG1183": "biosynthetic-additional",
    "SMCOG1184": "transport",
    "SMCOG1185": "other",
    "SMCOG1186": "transport",
    "SMCOG1187": "biosynthetic-additional",
    "SMCOG1188": "other",
    "SMCOG1189": "biosynthetic-additional",
    "SMCOG1190": "biosynthetic-additional",
    "SMCOG1191": "biosynthetic-additional",
    "SMCOG1192": "other",
    "SMCOG1193": "biosynthetic-additional",
    "SMCOG1194": "other",
    "SMCOG1195": "regulatory",
    "SMCOG1196": "biosynthetic-additional",
    "SMCOG1197": "regulatory",
    "SMCOG1198": "other",
    "SMCOG1199": "other",
    "SMCOG1200": "other",
    "SMCOG1201": "regulatory",
    "SMCOG1202": "transport",
    "SMCOG1203": "biosynthetic-additional",
    "SMCOG1204": "biosynthetic-additional",
    "SMCOG1205": "transport",
    "SMCOG1206": "other",
    "SMCOG1207": "biosynthetic-additional",
    "SMCOG1208": "other",
    "SMCOG1209": "biosynthetic-additional",
    "SMCOG1210": "biosynthetic-additional",
    "SMCOG1211": "other",
    "SMCOG1212": "transport",
    "SMCOG1213": "other",
    "SMCOG1214": "transport",
    "SMCOG1215": "regulatory",
    "SMCOG1216": "biosynthetic-additional",
    "SMCOG1217": "biosynthetic-additional",
    "SMCOG1218": "other",
    "SMCOG1219": "biosynthetic-additional",
    "SMCOG1220": "biosynthetic-additional",
    "SMCOG1221": "other",
    "SMCOG1222": "biosynthetic-additional",
    "SMCOG1223": "other",
    "SMCOG1224": "regulatory",
    "SMCOG1225": "biosynthetic-additional",
    "SMCOG1226": "other",
    "SMCOG1227": "other",
    "SMCOG1228": "biosynthetic-additional",
    "SMCOG1229": "other",
    "SMCOG1230": "other",
    "SMCOG1231": "biosynthetic-additional",
    "SMCOG1232": "other",
    "SMCOG1233": "biosynthetic-additional",
    "SMCOG1234": "transport",
    "SMCOG1235": "biosynthetic-additional",
    "SMCOG1236": "biosynthetic-additional",
    "SMCOG1237": "other",
    "SMCOG1238": "other",
    "SMCOG1239": "regulatory",
    "SMCOG1240": "biosynthetic-additional",
    "SMCOG1241": "other",
    "SMCOG1242": "other",
    "SMCOG1243": "transport",
    "SMCOG1244": "biosynthetic-additional",
    "SMCOG1245": "other",
    "SMCOG1246": "biosynthetic-additional",
    "SMCOG1247": "biosynthetic-additional",
    "SMCOG1248": "biosynthetic-additional",
    "SMCOG1249": "biosynthetic-additional",
    "SMCOG1250": "other",
    "SMCOG1251": "other",
    "SMCOG1252": "transport",
    "SMCOG1253": "other",
    "SMCOG1254": "transport",
    "SMCOG1255": "regulatory",
    "SMCOG1256": "biosynthetic-additional",
    "SMCOG1257": "biosynthetic-additional",
    "SMCOG1258": "biosynthetic-additional",
    "SMCOG1259": "other",
    "SMCOG1260": "regulatory",
    "SMCOG1261": "other",
    "SMCOG1262": "biosynthetic-additional",
    "SMCOG1263": "biosynthetic-additional",
    "SMCOG1264": "biosynthetic-additional",
    "SMCOG1265": "other",
    "SMCOG1266": "regulatory",
    "SMCOG1267": "other",
    "SMCOG1268": "biosynthetic-additional",
    "SMCOG1269": "other",
    "SMCOG1270": "biosynthetic-additional",
    "SMCOG1271": "biosynthetic-additional",
    "SMCOG1272": "other",
    "SMCOG1273": "other",
    "SMCOG1274": "biosynthetic-additional",
    "SMCOG1275": "biosynthetic-additional",
    "SMCOG1276": "biosynthetic-additional",
    "SMCOG1277": "other",
    "SMCOG1278": "regulatory",
    "SMCOG1279": "biosynthetic-additional",
    "SMCOG1280": "biosynthetic-additional",
    "SMCOG1281": "other",
    "SMCOG1282": "transport",
    "SMCOG1283": "biosynthetic-additional",
    "SMCOG1284": "regulatory",
    "SMCOG1285": "other",
    "SMCOG1286": "other",
    "SMCOG1287": "regulatory",
    "SMCOG1288": "transport",
    "SMCOG1289": "other",
    "SMCOG1290": "transport",
    "SMCOG1291": "biosynthetic-additional",
    "SMCOG1292": "other",
    "SMCOG1293": "biosynthetic-additional",
    "SMCOG1294": "biosynthetic-additional",
    "SMCOG1295": "other",
    "SMCOG1296": "other",
    "SMCOG1297": "biosynthetic-additional",
    "SMCOG1298": "biosynthetic-additional",
    "SMCOG1299": "other",
    "SMCOG1300": "other",
}


def aggregate_clusters(geneclus_file):
    """Parse the genecluster.txt file and return a dict.
    Each entry on the dict:
    {
        "contig_id": {
            // i.e ctg467_5      // i.e [terpene, bacteriocin]...
            "locus_tag on .embl": ["cluster_id"]
        },...
    }
    Note: Each locust tag shouldn't have more than one antiSMASH cluster
    but this code will handle that scenario
    """
    aggregated_clusters = {}
    with open(geneclus_file, "r") as reader:
        for line in reader:
            _, contig, as_cluster_id, entries, *_ = line.split("\t")
            contig_id = contig.replace(" ", "-")
            locus_tags = entries.split(";")

            lt_dict = {}
            for locus_tag in locus_tags:
                lt_dict.setdefault(locus_tag, []).append(as_cluster_id)

            aggregated_clusters[contig_id] = lt_dict

    return aggregated_clusters


def _get_value(entry_quals, key, cb=lambda x: x):
    """Get the value from the entry and apply the callback"""
    return ",".join(cb(v) for v in entry_quals.get(key, []))


def _clean_as_notes(value):
    """Remove comments that point to antiSMASH HTML images and URLEncode"""
    return "" if ".png" in value else parse.quote(value)


def _mags_name_clean(query_name):
    """Clean the MAGs genome name.
    MAGs .embl query_name is:

    GUT_GENOME096033_1-NZ_JH815228.1-Fusobacterium-ulcerans-ATCC-49185-genomic
    That name is not proper for the .gff file so it is cleaned
    in order to return: GUT_GENOME096033_1
    """
    return re.sub(r"[-|\s].+", "", query_name)


def _get_biosynthetic_type(entry_quals):
    """Get the antismash biosythetic type of a CDS feature
    Modified from: https://github.com/antismash/antismash
    """
    bio_type = "other"
    for sec_met in entry_quals.get("sec_met", []):
        if sec_met.startswith("Kind:"):
            return sec_met[6:]

    for note in entry_quals.get("note", []):
        if note.startswith("smCOG:"):
            smcog = note[7:].split(":")[0]
            bio_type = _SMCOG_TYPE_MAPPING.get(smcog, "other")

    return bio_type


def build_attributes(entry_quals, gc_entries):
    """Convert the CDS features to gff attributes field for an CDS entry"""
    locus_tag = entry_quals["locus_tag"][0]
    attributes = []

    attributes.append(["as_notes", _get_value(entry_quals, "note", _clean_as_notes)])
    attributes.append(["as_gene_functions", _get_value(entry_quals, "gene_functions")])
    attributes.append(["as_gene_kind", _get_value(entry_quals, "gene_kind")])
    attributes.append(["product", _get_value(entry_quals, "product")])

    bio_type = _get_biosynthetic_type(entry_quals)
    if bio_type != "other":
        # gc_entries example: {"ERZ111_1":["terpene","bacteriocin"]},"ERZ111_2":[]...}
        relevant_entries = gc_entries.get(locus_tag, [])
        if relevant_entries:
            attributes.append(["as_gene_clusters", ",".join(relevant_entries)])

    attributes.append(["as_type", bio_type])

    return ";".join([name + "=" + val for name, val in attributes if len(val)])


def build_gff(embl_file, gclusters, mag=False):
    """Build the GFF from the geneclusters and the EMBL file"""
    entries = SeqIO.parse(embl_file, "embl")
    for entry in entries:
        query_name = entry.id
        query_description = entry.description
        if mag:
            query_name = _mags_name_clean(query_name)
        query_name = query_name.replace(" ", "-")

        # filter the embl file by the contigs that have a
        # gene cluster entry in the geneclusters.txt file
        gc_entries = gclusters.get(query_name, None)
        if not gc_entries:
            continue

        # get the data from the embl file
        for entry_feature in entry.features:

            if entry_feature.type != "CDS":
                continue

            quals = entry_feature.qualifiers

            if "locus_tag" not in quals:
                continue

            attributes = build_attributes(quals, gc_entries)

            yield [
                query_description,
                "antiSMASH",
                "CDS",
                # correct offset gff are +1
                str(entry_feature.location.start + 1),
                str(entry_feature.location.end + 1),
                ".",  # Score
                "+" if entry_feature.strand > 0 else "-",
                ".",
                "ID=" + query_description + ";" + attributes,
            ]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Build an antiSMASH gff file for the webclient"
    )
    parser.add_argument(
        "-e", dest="embl", help="EMBL antiSMASH results file", required=True
    )
    parser.add_argument("-g", dest="geneclus", help="antiSMASH geneclusters.txt file")
    parser.add_argument(
        "--mag",
        help="MAGs use a specific naming convention on the EMBL file."
        + "This flag will process the DESC field on the EMBL to correct that",
        action="store_true",
    )
    parser.add_argument(
        "--no-tabix",
        help="Disable the compressed gff build process.",
        action="store_true",
    )
    parser.add_argument("-o", dest="out", help="Ouput GFF file name", required=True)
    args = parser.parse_args()

    with open(args.out, "w") as out_handle:

        print("##gff-version 3", file=out_handle)

        logger.info("Aggregating genecluster.txt")
        clusters_data = aggregate_clusters(args.geneclus)

        logger.info("Building the gff file")
        for row in build_gff(args.embl, clusters_data, mag=args.mag):
            print("\t".join(row), file=out_handle)

    if not args.no_tabix:
        logger.info("Sorting...")
        grep = '(grep ^"#" {0}; grep -v ^"#" {0} | sort -k1,1 -k4,4n)'.format(args.out)
        grep += "| bgzip > {0}.bgz".format(args.out)
        logger.info(grep)
        subprocess.call(grep, shell=True)
        logger.info("Building index...")
        subprocess.call(["tabix", "-p", "gff", "{}.bgz".format(args.out)])
