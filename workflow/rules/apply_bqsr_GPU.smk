__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule apply_bqsr_GPU:
    input:
        bam="alignment/align_dedup_GPU/{sample}_{type}.dedup.bam",
        ref=config["reference"]["fasta"],
        recal="alignment/{rule}/{sample}_{type}.recal.txt",
    output:
        bam=temp("alignment/{rule}/{sample}_{type}.bqsr.dedup.bam",
    log:
        "alignment/{rule}/{sample}_{type}.bqsr.dedup.log",
    benchmark:
        repeat(
            "alignment/{rule}/{sample}_{type}.bqsr.dedup.benchmark.tsv",
            config.get("apply_bqsr_GPU", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("apply_bqsr_GPU", config["default_resources"])["threads"]
    # container:
    #     config.get("align_dedup_GPU", {}).get("container", "default_container")
    # conda:
    #     "../envs/align_dedup_GPU.yaml"
    message:
        "{rule}: Apply bqsr on alignment/{rule}/{wildcards.sample}_{wildcards.type} and write new bam file on the GPU"
    shell:
        "(pbrun applybqsr "
        "--ref {input.ref} "
        "--in-bam {input.bam} "
        "--in-recal-file {input.recal} "
        "--out-bam {output.bam} "
        ") &> {log}"
