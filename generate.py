import sys

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


def generate_powerlog():
    """
    This generator:
    * replaces all occurrences of "$TOOL" with "powerlog",
    * skips the line assigning the TOOL variable.
    """
    # input file
    fin = open("template.sh", "rt")
    # output file to write the result to
    fout = open("powerlog/package/fernivy", "wt")
    # for each line in the input file
    for line in fin:
        if line.startswith('TOOL='):
            continue
        # read replace the string and write to output file
        line = line\
            .replace('$TOOL', 'powerlog')\
            .replace('\"powerlog\"', 'powerlog')
        fout.write(line)
    # close input and output files
    fin.close()
    fout.close()


def generate_perf_fernivy():
    """
    This generator:
    * replaces all occurrences of "$TOOL" with "perf",
    * sets the correct paths for the helper scripts,
    * skips the line assigning the TOOL variable,
    * adds the request for sudo access.
    """
    # input file
    fin = open("template.sh", "rt")
    # output file to write the result to
    fout = open("perf/package/fernivy", "wt")
    # for each line in the input file
    for line in fin:
        if line.startswith('TOOL='):
            continue
        if line.__contains__("Request for sudo access when needed"):
            fout.write("if (( $EUID != 0 )); then echo \"Please run as root!\"; exit; fi\n")
            continue
        # read replace the string and write to output file
        line = line\
            .replace('\"./\"$TOOL\"', '\"/usr/lib/perf')\
            .replace('$TOOL', 'perf')\
            .replace('parser.py', '/usr/lib/parser.py')
        fout.write(line)
    # close input and output files
    fin.close()
    fout.close()


def generate_perf_control(conf):
    """
    This generator creates the debian/control file for perf.
    :param conf: The configuration of the project.
    """
    with open('perf/package/debian/control', 'w') as f:
        f.write("Source: " + conf.configs['package'] + "\n")
        f.write("Section: admin" + "\n")
        f.write("Maintainer: " + conf.configs['maintainer'] + "\n")
        f.write("\n")
        f.write("Package: " + conf.configs['package'] + "\n")
        f.write("Version: " + conf.configs['version'] + "\n")
        f.write("Architecture: all" + "\n")
        f.write("Depends: " + conf.configs['python'] + ",\n         linux-perf" + "\n")
        f.write("Homepage: " + conf.configs['website'] + "\n")
        f.write("Description: " + conf.configs['description'] + "\n")


def generate_perf(conf):
    """
    This generator creates the package for perf.
    :param conf: The configuration of the project.
    """
    generate_perf_fernivy()
    generate_perf_control(conf)

if __name__ == '__main__':

    config = Config('config.yml')

    if sys.argv[1] == 'perf':
        generate_perf(config)
    elif sys.argv[1] == 'powerlog':
        generate_powerlog()
