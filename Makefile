.DEFAULT_GOAL := generate

generate: perf powerlog

powerlog: clean_powerlog
	@mkdir powerlog/package
	@python3 generate.py powerlog
	@chmod +x powerlog/package/fernivy
	@cp powerlog_run.sh powerlog/package/
	@chmod +x powerlog/package/powerlog_run.sh
	@cp parser.py powerlog/package/

clean_powerlog:
	@rm -rf powerlog/package

perf: clean_perf
	@mkdir perf/package
	@cp -r perf/backup/debian/ perf/package/debian/
	@cp perf/backup/Makefile perf/package/Makefile
	@python3 generate.py perf
	@chmod +x perf/package/fernivy
	@cp perf_run.sh perf/package/
	@chmod +x perf/package/perf_run.sh
	@cp parser.py perf/package/

clean_perf:
	@rm -rf perf/package

clean: clean_perf clean_powerlog

