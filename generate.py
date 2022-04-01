import sys, shutil
from datetime import datetime


class Config:
    """
    The class which deals with the configurations of the project.
    """

    def __init__(self, filename):
        self._configs = {}
        with open(filename) as f:
            for line in f:
                data = line.strip().split(": ")
                self._configs[data[0]] = data[1]

    @property
    def configs(self):
        return self._configs


def generate_fernivy(tool, replace, package="package"):
    """
    This generator:
    * skips the line assigning the TOOL variable,
    * applies the specific replacement function,
    * replaces all remaining occurrences of "$TOOL" with the name of the tool.
    :param tool: The name of the tool that was used for the measurement.
    :param replace: The function that edits the string.
    :param package: The package into which we are generating this.
    """
    # input file
    fin = open("template.sh", "rt")
    # output file to write the result to
    fout = open(tool + f"/{package}/fernivy", "wt")
    # for each line in the input file
    for line in fin:
        if line.startswith("TOOL="):
            continue
        # read replace the string and write to output file
        line = replace(line).replace("$TOOL", tool)
        fout.write(line)
    # close input and output files
    fin.close()
    fout.close()


def generate_perf_control(conf, package="package"):
    """
    This generator creates the debian/control file for perf.
    :param conf: The configuration of the project.
    :param package: The package into which we are generating this.
    """
    with open(f"perf/{package}/debian/control", "w") as f:
        f.write("Source: " + conf.configs["package"] + "\n")
        f.write("Section: admin" + "\n")
        f.write("Maintainer: " + conf.configs["maintainer"] + "\n")
        f.write("\n")
        f.write("Package: " + conf.configs["package"] + "\n")
        f.write("Architecture: all" + "\n")
        f.write("Depends: " + conf.configs["python"] + ",\n         linux-perf" + "\n")
        f.write("Homepage: " + conf.configs["website"] + "\n")
        f.write("Description: " + conf.configs["description"] + "\n")


def generate_perf_changelog(conf, package="package"):
    """
    This generator creates the debian/changelog file for perf.
    :param conf: The configuration of the project.
    :param package: The package into which we are generating this.
    """
    with open(f"perf/{package}/debian/changelog", "w") as f:
        f.write("fernivy (" + conf.configs["version"] + ") stable; urgency=low\n\n")
        f.write("Please check out the repository for release information:"
                " https://github.com/fernivy/fernivy/blob/main/CHANGELOG.md\n\n")
        # Thu, 31 Mar 2022 08:36:00 +0100
        f.write(" -- FernIvy " + datetime.now().strftime("%a, %d %b %Y %H:%M:%S"))


def generate_perf(conf):
    """
    This generator creates the package for perf.
    :param conf: The configuration of the project.
    """
    shutil.copytree("perf/backup/", "perf/package/")
    shutil.copytree("perf/backup/", "perf/package-deb/")
    # installation from source
    generate_fernivy("perf",
                     lambda line:
                     line.replace(
                         "# Request for sudo access when needed",
                         "if (( $EUID != 0 )); then echo \"Please run as root!\"; exit; fi"
                     )
                     .replace("$TOOL\"/backup/\"$TOOL\"_run.sh\"", "./perf_run.sh")
                     )
    # installation through deb
    generate_fernivy("perf",
                     lambda line:
                     line.replace(
                         "# Request for sudo access when needed",
                         "if (( $EUID != 0 )); then echo \"Please run as root!\"; exit; fi"
                     )
                     .replace("$TOOL\"/backup/\"$TOOL\"_run.sh\"", "/usr/lib/perf_run.sh")
                     .replace("parser.py", "/usr/lib/parser.py"),
                     package="package-deb"
                     )
    generate_perf_control(conf, package="package-deb")
    generate_perf_changelog(conf, package="package-deb")
    shutil.copyfile("parser.py", "perf/package/parser.py")
    shutil.copyfile("parser.py", "perf/package-deb/parser.py")


def generate_powerlog(conf):
    """
    This generator creates the package and package-brew for powerlog.
    """
    shutil.copytree("powerlog/backup/", "powerlog/package/")
    shutil.copytree("powerlog/backup/", "powerlog/package-brew/")
    # installation from source
    generate_fernivy("powerlog",
                     lambda line:
                     line.replace("$TOOL\"/backup/\"$TOOL\"_run.sh\"", "./powerlog_run.sh")
                     )
    # installation through homebrew
    generate_fernivy("powerlog",
                     lambda line:
                     line.replace(
                         "$TOOL\"/backup/\"$TOOL\"_run.sh\"",
                         f"/usr/local/Cellar/fernivy/{conf.configs['version']}/bin/powerlog_run.sh"
                     )
                     .replace(
                         "parser.py",
                         f"/usr/local/Cellar/fernivy/{conf.configs['version']}/bin/parser.py"
                     ),
                     package="package-brew"
                     )
    shutil.copyfile("parser.py", "powerlog/package/parser.py")
    shutil.copyfile("parser.py", "powerlog/package-brew/parser.py")


if __name__ == "__main__":

    config = Config("config.yml")

    if sys.argv[1] == "perf":
        generate_perf(config)
    elif sys.argv[1] == "powerlog":
        generate_powerlog(config)
