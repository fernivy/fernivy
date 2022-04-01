.DEFAULT_GOAL := generate

generate: perf powerlog

perf: clean_perf
	@python3 generate.py perf
	@chmod +x perf/package/fernivy
	@chmod +x perf/package/perf_run.sh

clean_perf:
	@rm -rf perf/package

powerlog: clean_powerlog
	@python3 generate.py powerlog
	@chmod +x powerlog/package/fernivy
	@chmod +x powerlog/package/powerlog_run.sh

brew_powerlog: clean_powerlog
	@python3 generate.py brew_powerlog
	@chmod +x powerlog/package/fernivy
	@chmod +x powerlog/package/powerlog_run.sh

clean_powerlog:
	@rm -rf powerlog/package

clean: clean_perf clean_powerlog
