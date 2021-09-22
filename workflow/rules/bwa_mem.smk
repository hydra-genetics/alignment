__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule bwa_mem:
    input:
        reads=["prealignment/merged/{sample}_{type}_fastq1.fq.gz", "prealignment/merged/{sample}_{type}_fastq2.fq.gz"],
    output:
        bam="alignment/{rule}/{sample}_{type}.bam",
    params:
        index=config["reference"]["fasta"],
        extra=config["bwa_mem"]["params"]["extra"],
        sort=config["bwa_mem"]["params"].get("sort", "samtools"),
        sort_order=config["bwa_mem"]["params"].get("sort_order", "coordinate"),
        sort_extra="-@ %s" % str(config["bwa_mem"]["threads"]),
    log:
        "aligment/{rule}/{sample}_{type}.bam.log",
    benchmark:
        repeat(
            "aligment/{rule}/{sample}_{type}.bam.benchmark.tsv",
            config.get("{rule}", {}).get("benchmark_repeats", 1),
        )
    threads: config["bwa_mem"]["threads"]
    container:
        config.get("bwa_mem", {}).get("container", "default_container")
    conda:
        "../envs/{rule}.yaml"
    message:
        "{rule}: Align alignment/{rule}/{wildcards.sample}_{wildcards.type} with bwa and sort"
    wrapper:
        "0.70.0/bio/bwa/mem"
