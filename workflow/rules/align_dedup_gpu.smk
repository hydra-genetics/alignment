__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule align_dedup_gpu:
    input:
        fastq1="prealignment/merged/{sample}_{type}_fastq1.fq.gz",
        fastq2="prealignment/merged/{sample}_{type}_fastq2.fq.gz",
        ref=config["reference"]["fasta"],
    output:
        bam="alignment/{rule}/{sample}_{type}.dedup.bam",
    params:
        SM=config.get("align_dedup_gpu", "{sample}").get("SM", "{sample}"),
        PL=config.get("align_dedup_gpu", "illumina").get("PL", "illumina"),
        ID=config.get("align_dedup_gpu", "{sample}").get("ID", "{sample}"),
    log:
        "alignment/{rule}/{sample}_{type}.dedup.bam.log",
    benchmark:
        repeat(
            "alignment/{rule}/{sample}_{type}.dedup.bam.benchmark.tsv",
            config.get("align_dedup_gpu", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("align_dedup_gpu", config["default_resources"])["threads"]
    # container:
    #     config.get("align_dedup_GPU", {}).get("container", "default_container")
    message:
        "{rule}: Align alignment/{rule}/{wildcards.sample}_{wildcards.type} and then sort and mark duplicates on the GPU"
    shell:
        # --num-gpus 1 Needed?
        "(pbrun fq2bam "
        "--ref {input.ref} "
        "--in-fq {input.fastq1} {input.fastq2} "
        "--read-group-sm {params.SM} "
        "--read-group-pl {params.PL} "
        "--read-group-id-prefix {params.ID} "
        "--num-gpus 1 "
        "--out-bam {output.bam} "
        "--tmp-dir GPU_run_{wildcards.sample} "
        ") &> {log}"
