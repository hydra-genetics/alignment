__author__ = "Magdalena Zarowiecki"
__copyright__ = "Copyright 2024, Uppsala Universitet"
__email__ = "magdalena.z@scilifelab.uu.se"
__license__ = "GPL-3"


rule hifiasm:
    input:
        fasta=["long_read/hifiasm/{sample}_{type}_{processing_unit}_{barcode}.s2fq.fastq.gz"],
    # optional
    output:
        #"long_read/hifiasm/{sample}_{type}_{processing_unit}_{barcode}.a_ctg.gfa",
        multiext(
            "long_read/hifiasm/{sample}_{type}_{processing_unit}_{barcode}.",
            "a_ctg.gfa",
            "a_ctg.lowQ.bed",
            "a_ctg.noseq.gfa",
            "p_ctg.gfa",
            "p_ctg.lowQ.bed",
            "p_ctg.noseq.gfa",
            "p_utg.gfa",
            "p_utg.lowQ.bed",
            "p_utg.noseq.gfa",
            "r_utg.gfa",
            "r_utg.lowQ.bed",
            "r_utg.noseq.gfa",
        ),
    log:
        "long_read/hifiasm/{sample}_{type}_{processing_unit}_{barcode}.log",
    container:
        config.get("hifiasm", {}).get("container", config["default_container"]),
    params:
        extra="--primary -f 37 -l 1 -s 0.75 -O 1",
    threads: config.get("hifiasm", {}).get("threads", config["default_resources"]["threads"]),
    resources:
        partition=config.get("hifiasm", {}).get("partition", config["default_resources"]["partition"]),
        time=config.get("hifiasm", {}).get("time", config["default_resources"]["time"]),
        mem_per_cpu=config.get("hifiasm", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]), 
        threads=config.get("hifiasm", {}).get("threads", config["default_resources"]["threads"]),
    wrapper:
        # "file:///beegfs-storage/projects/wp3/nobackup/Workspace/magz_testing/snakemake-wrappers/bio/hifiasm"
        "v3.3.6/bio/hifiasm"

# Dervied from https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/hifiasm.html