# ChangeLog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Fixed the generator to not copy the `debian` folder to `perf/package/`
- Remove sleep time after the final run

## [v1.2.0] 1 April 2022
- Added `package-brew` generator for PowerLog (works with `homebrew` packaging)
- Edited the README to contains up-to-date information
- Created the CONTRIBUTING.md
- Created the CHANGELOG.md
- Moved the `tool_run.sh` files to their relevant directories
- Moved the package generation from the `Makefile` to the python script (except for `chmod`)
- Simplified the generator for the fernivy files into one method which takes a lambda parameter for the replacement function (to ensure some things are done for all tools)

## [v1.1.0] 31 March 2022
- Added sudo access request outside of script
- Changed to using `mktemp` for temporary files
- Structured the repository to use a template, generator, and `Makefile`

## [v1.0.1 for MacOS] 31 March 2022
- Added recursive generation of folders
- Fixed output filename extension
- Set `powerlog` as the default tool

## [v1.0.0]  29 March 2022
- Added support for Perf (Linux) and PowerLog (MacOS)
- Added uniform data output for all supported tools
- Added command Mode vs Timed Mode
- Added varying number of runs + customisable sleep time
- Added averages over runs
- Added output file and output folder specification
- Added logging mode
