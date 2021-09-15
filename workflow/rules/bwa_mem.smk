__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule bwa_mem:
    input:
        reads=["prealignment/merged/{sample}_{unit}_fastq1.fq.gz", "prealignment/merged/{sample}_{unit}_fastq2.fq.gz"],
    output:
        bam="alignment/bwa_mem/{sample}_{unit}.bam",
    params:
        index=config["reference"]["fasta"],
        extra=config["bwa_mem"]["params"]["extra"],
        sort=config["bwa_mem"]["params"].get("sort", "samtools"),
        sort_order=config["bwa_mem"]["params"].get("sort_order", "coordinate"),
        sort_extra="-@ %s" % str(config["bwa_mem"]["threads"]),
    log:
        "aligment/bwa_mem/{sample}_{unit}.bam.log",
    benchmark:
        "alignment/bwa_mem/{sample}_{unit}.bam.benchmark.tsv"
    threads: config["bwa_mem"]["threads"]
    container:
        config["bwa_mem"]["container"]
    message:
        "{rule}: Align {wildcards.sample}_{wildcards.unit} with bwa and sort"
    wrapper:
        "0.70.0/bio/bwa/mem"
