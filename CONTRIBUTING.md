# Contributing to FernIvy

Thank you for wanting to contribute to FernIvy!

Please read this contributing guide carefully to make sure that your PR can be merged quickly.

## Structure of the Repository

The vision of FernIvy is to be a uniform interface across many platforms and tools.
Unfortunately, these often all require different things.
We therefore work with a `template.sh` for development, and we use a `Makefile` to generate FernIvy for each tool separately.

Let's take Perf as an example. The following things are needed to support Perf:

1. A separate directory called `perf` with a `backup` subdirectory.
2. A `perf_run.sh` script inside the `perf/backup` directory which contains the command that performs the actual measurement.
   It takes the target output file as the first argument and the command to measure for as the second argument.
3. A directory `perf/backup/debian` which contains the file structure necessary to create a `.deb` package from FernIvy.
4. A `generate_perf` method in the `generate.py` file, which generates the entire tool ready to be packaged into the `perf/package/` directory. It:
   1. copies the entire `perf/backup/` into `perf/package`,
   2. generates the `fernivy` script by replacing `$TOOL` with the correct packaging locations and adding a line requesting sudo access to run,
   3. generates the `debian/control` file containing the relevant release information,
   4. copies the `parser.py` into the package.
5. Two commands in the `Makefile`:
   1. A `clean_perf` command which recursively removes the entire `perf/package` directory and is included in the `clean` command.
   2. A `perf` command which cleans the package, calls the `generate.py` script for perf, and makes all the executables executable.
      It is included in the `generate` command.

To package FernIvy with Perf into a `.deb` file, simply navigate to the `perf/package/` directory and run `dpkg-buildpackage -uc -us`.

To run FernIvy with Perf in the dev environment, change the `TOOL=<tool>` line in `template.sh` to `TOOL=perf` (this line is always removed in the generation process).
You can run e.g. the following command:

```bash
./template.sh -s 2 -b 1 -r 5 -p -e -t
```

**NOTE:** For Perf specifically, you need to run the tool using `sudo`, since Perf requires root access.

## Dependencies

For each tool and operating system, FernIvy needs different dependencies to work and to be packaged.
We therefore aim to keep all dependencies to a minimum.
Therefore, if you can implement something **simply** without a library, please do so.

For this reason, the `yml` file we use cannot have nested properties.

## Code Style

FernIvy is currently written using a mixture of Shell and Python scripts.
As you can imagine, this can quickly become unmaintainable and hard to read.
Therefore, we ask you to follow these code style guidelines:

### Python
* Use the standard Python code style (snake-casing, indentation, etc.).
* Write docstrings for all the methods that you write (initialisers only need one if there is something special about them).

### Shell
* Name information variables with capitals.
* Name control flow variables using the `_name` format.
* Flow control blocks should have the following format:

```bash
 if [[ <condition> ]]; then
     # comment
     <body>
 fi
```

### Both
* Use 4 spaces for 1 indent.
* Use double-quotes for strings (`"` instead of `'`).
* Provide comments for your code.

## ChangeLog

Please record each significant change in the [CHANGELOG.md](CHANGELOG.md) file under "Unreleased" to enable us to facilitate keeping track of all the changes.

## Git Usage

To keep a clean git history, please follow these guidelines:

* **Rebase** on main instead of merging main into your own branch.
* Have informative and structured [commit messages](https://cbea.ms/git-commit/).
* Use the templates available.
