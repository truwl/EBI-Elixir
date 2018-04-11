cwlVersion: v1.0
class: Workflow
label: Transcripts annotation workflow

requirements:
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types:
    - $import: ../tools/InterProScan/InterProScan-apps.yaml

inputs:
  transcriptsFile:
    type: File
#   TODO: Resolve: Missing required 'format' for File at runtime
#    format: edam:format_1929  # FASTA
  singleBestOnly: boolean?
  applications: ../tools/InterProScan/InterProScan-apps.yaml#apps[]?

outputs:
  peptide_sequences:
    type: File
    outputSource: identify_coding_regions/peptide_sequences
  coding_regions:
    type: File
    outputSource: identify_coding_regions/coding_regions
  gff3_output:
    type: File
    outputSource: identify_coding_regions/gff3_output
  bed_output:
    type: File
    outputSource: identify_coding_regions/bed_output

steps:
  identify_coding_regions:
    label: Identifies candidate coding regions within transcript sequences
    run: TransDecoder-v5-wf-2steps.cwl
    in:
      transcriptsFile: transcriptsFile
      singleBestOnly: singleBestOnly
    out: [ peptide_sequences, coding_regions, gff3_output, bed_output ]

  functional_analysis:
    doc: |
        Matches are generated against predicted CDS, using a sub set of databases
        (Pfam, TIGRFAM, PRINTS, PROSITE patterns, Gene3d) from InterPro.
    run: ../tools/InterProScan/InterProScan-v5.cwl
    in:
      proteinFile: identify_coding_regions/peptide_sequences
      applications: applications
    out: [ i5Annotations ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"