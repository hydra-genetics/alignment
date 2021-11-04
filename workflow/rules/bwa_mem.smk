__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule bwa_mem:
    input:
        reads=["prealignment/merged/{sample}_{type}_fastq1.fastq.gz", "prealignment/merged/{sample}_{type}_fastq2.fastq.gz"],
    output:
        bam=temp("alignment/bwa_mem/{sample}_{type}.bam"),
    params:
        index=config["reference"]["fasta"],
        extra="%s %s"
        % (
            config.get("bwa_mem", {}).get("extra", ""),
            config.get("bwa_mem", {}).get(
                "read_group", "-R '@RG\\tID:{sample}\\tSM:{sample}\\tPL:illumina\\tPU:{sample}' -v 1 "
            ),
        ),
        sorting=config.get("bwa_mem", {}).get("sort", "samtools"),
        sort_order=config.get("bwa_mem", {}).get("sort_order", "coordinate"),
        sort_extra="-@ %s"
        % str(config.get("bwa_mem", config["default_resources"]).get("threads", config["default_resources"]["threads"])),
    log:
        "alignment/bwa_mem/{sample}_{type}.bam.log",
    benchmark:
        repeat(
            "alignment/bwa_mem/{sample}_{type}.bam.benchmark.tsv",
            config.get("bwa_mem", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("bwa_mem", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("bwa_mem", {}).get('threads', config["default_resources"]["threads"]),
        time=config.get("bwa_mem", {}).get('time', config["default_resources"]["time"]),
    container:
        config.get("bwa_mem", {}).get("container", config["default_container"])
    conda:
        "../envs/bwa_mem.yaml"
    message:
        "{rule}: Align alignment/{rule}/{wildcards.sample}_{wildcards.type} with bwa and sort"
    wrapper:
        "0.78.0/bio/bwa/mem"
