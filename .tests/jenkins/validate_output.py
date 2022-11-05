#!/usr/bin/pyhton

import click
import json
import logging
import os
import subprocess

import rich.console
import rich.logging
import rich.traceback

log = logging.getLogger()


def rich_force_colors():
    """
    Check if any environment variables are set to force Rich to use coloured output
    """
    if os.getenv("GITHUB_ACTIONS") or os.getenv("FORCE_COLOR") or os.getenv("PY_COLORS"):
        return True
    return None


def run():
    # Set up rich stderr console
    stderr = rich.console.Console(stderr=True, force_terminal=rich_force_colors())

    # Set up the rich traceback
    rich.traceback.install(console=stderr, width=200, word_wrap=True, extra_lines=1)

    stderr.print("\u001b[36m" + r"' ('-. .-.             _ .-') _  _  .-')     ('-.             .-') _     ('-.    .-')    .-') _               .-') _             ",  # noqa
                 highlight=False)
    stderr.print("\u001b[36m" + r"( OO )  /            ( (  OO) )( \( -O )   ( OO ).-.        (  OO) )  _(  OO)  ( OO ). (  OO) )             ( OO ) )            ",  # noqa
                 highlight=False)
    stderr.print("\u001b[36m" + r",--. ,--.  ,--.   ,--.\     .'_ ,------.   / . --. /        /     '._(,------.(_)---\_)/     '._ ,-.-') ,--./ ,--,'  ,----.     ",  # noqa
                 highlight=False)
    stderr.print("\u001b[36m" + r"|  | |  |   \  `.'  / ,`'--..._)|   /`. '  | \-.  \    .-') |'--...__)|  .---'/    _ | |'--...__)|  |OO)|   \ |  |\ '  .-./-')  ",  # noqa
                 highlight=False)
    stderr.print("\u001b[36m" + r"|   .|  | .-')     /  |  |  \  '|  /  | |.-'-'  |  | _(  OO)'--.  .--'|  |    \  :` `. '--.  .--'|  |  \|    \|  | )|  |_( O- ) ",  # noqa
                 highlight=False)
    stderr.print("\u001b[36m" + r"|       |(OO  \   /   |  |   ' ||  |_.' | \| |_.'  |(,------.  |  |  (|  '--.  '..`''.)   |  |   |  |(_/|  .     |/ |  | .--, \ ",  # noqa
                 highlight=False)
    stderr.print("\u001b[36m" + r"|  .-.  | |   /  /\_  |  |   / :|  .  '.'  |  .-.  | '------'  |  |   |  .--' .-._)   \   |  |  ,|  |_.'|  |\    | (|  | '. (_/ ",  # noqa
                 highlight=False)
    stderr.print("\u001b[36m" + r"|  | |  | `-./  /.__) |  '--'  /|  |\  \   |  | |  |           |  |   |  `---.\       /   |  | (_|  |   |  | \   |  |  '--'  |  ",  # noqa
                 highlight=False)
    stderr.print("\u001b[36m" + r"`--' `--'   `--'      `-------' `--' '--'  `--' `--'           `--'   `------' `-----'    `--'   `--'   `--'  `--'   `------'   ",  # noqa
                 highlight=False)
    stderr.print("\033[0m\n\n", highlight=False)

    cli()


@click.group(help="CLI tool to validate output using a json file")
@click.option("-v", "--verbose", is_flag=True, default=False, help="Print verbose output to the console.")
@click.option("-l", "--log-file", help="Save a verbose log to a file.", metavar="<filename>")
def cli(verbose, log_file):
    log.setLevel(logging.DEBUG)

    log.addHandler(
        rich.logging.RichHandler(
            level=logging.DEBUG if verbose else logging.INFO,
            console=rich.console.Console(stderr=True, force_terminal=rich_force_colors()),
            show_time=False,
            markup=True,
        )
    )

    if log_file:
        log_fh = logging.FileHandler(log_file, encoding="utf-8")
        log_fh.setLevel(logging.DEBUG)
        log_fh.setFormatter(logging.Formatter("[%(asctime)s] %(name)-20s [%(levelname)-7s]  %(message)s"))
        log.addHandler(log_fh)


@cli.command(short_help="validate generated output")
@click.option(
    "-j",
    "--json-file",
    prompt="json file",
    required=True,
    type=str,
    help="Json file with files that will be validated",
)
@click.option("-d", "--directory", prompt=True, required=True, type=str, help="Directory where analysis have been run.")
def validate_result(json_file, directory):
    with open(json_file) as input_data:
        validation_data = json.load(input_data)
        log.info("Validating")
        for analys in validation_data['final_output']:
            log.info(f"Step: {analys}")
            for rule in validation_data['final_output'][analys]:
                log.info(f"- rule: {rule}")
                for f_path, md5 in validation_data['final_output'][analys][rule].items():
                    if f_path.endswith("bam"):
                        result = process_bam_file(f_path, directory)
                        if result.returncode != 0:
                            raise ValueError(f"Could not run command: {result.args}\n"
                                             f"Exit code {result.returncode}\n{result.stderr}")
                        if result.stdout.decode("utf-8").split(" ")[0] != md5:
                            raise ValueError(f"{f_path} expect md5 {md5} found {{}}".
                                             format(result.stdout.decode("utf-8").split(" ")[0]))
                        else:
                            log.info(f"-- {f_path} with md5 {md5} passed validation")


def process_bam_file(f_path, directory):
    command = ["samtools view ", os.path.join(directory, f_path), "|", "md5sum"]
    return subprocess.run(" ".join(command), stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)


if __name__ == "__main__":
    run()
