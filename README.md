# FernIvy
This repository contains the source code for FernIvy, a power-measurement tool meant to provide a uniform command-line interface across multiple platforms.
It was originally developed for the [Sustainable Software Engineering](https://luiscruz.github.io/course_sustainableSE) course at the TU Delft.

For documentation and installation, please see the [docs page](https://fernivy.github.io/docs/). It currently has support for:
* `perf` (Linux)
* `PowerLog` (MacOS)

It has the following syntax and options:

```
syntax:
    fernivy [-h] [-l]
            [-s seconds_to_run | -c command_to_run]
            [-r number_of_runs] [-b seconds_between_runs]
            [-e] [-p] [-t]
            [-o output_file_name] [-f output_file_folder]
options:
b     Set the number of second to pause between runs.
c     Run for specified command.
      Put the entire command in quotation marks if it is longer than one word.
e     Print total energy consumption.
f     Set the folder in which to save the output file.
      If it does not exist, it will be created.
h     Print this Help.
l     Run in logging mode.
o     Set output file.
      The path to the file has to exist.
      It cannot start with "temp".
p     Print average power.
r     Set the number of times to run.
s     Run for specified number of seconds.
t     Print total execution time.
```

If you find any bugs or have a feature request, feel free to create an issue or (even better) [contribute](CONTRIBUTING.md)! 
