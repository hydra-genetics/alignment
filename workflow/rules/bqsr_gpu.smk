__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule bqsr_gpu:
    input:
        bam="alignment/align_dedup_gpu/{sample}_{type}.dedup.bam",
        ref=config["reference"]["fasta"],
        indels=config["bqsr_gpu"]["known_indels"],
    output:
        recal=temp("alignment/{rule}/{sample}_{type}.recal.txt"),
    log:
        "alignment/{rule}/{sample}_{type}.recal.txt.log",
    benchmark:
        repeat(
            "alignment/{rule}/{sample}_{type}.recal.txt.benchmark.tsv",
            config.get("bqsr_gpu", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("bqsr_gpu", config["default_resources"])["threads"]
    # container:
    #     config.get("align_dedup_GPU", {}).get("container", "default_container")
    message:
        "{rule}: Calculate bqsr on alignment/{rule}/{wildcards.sample}_{wildcards.type} on the GPU"
    shell:
        "(pbrun bqsr "
        "--ref {input.ref} "
        "--in-bam {input.bam} "
        "--knownSites {input.indels} "
        "--out-recal-file {output.recal} "
        ") &> {log}"