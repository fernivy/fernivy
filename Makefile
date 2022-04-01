.DEFAULT_GOAL := generate

generate: perf powerlog

perf: clean_perf
	@python3 generate.py perf
	@chmod +x perf/package/fernivy
	@chmod +x perf/package/perf_run.sh
	@chmod +x perf/package-deb/fernivy
	@chmod +x perf/package-deb/perf_run.sh

clean_perf:
	@rm -rf perf/package
	@rm -rf perf/package-deb

powerlog: clean_powerlog
	@python3 generate.py powerlog
	@chmod +x powerlog/package/fernivy
	@chmod +x powerlog/package/powerlog_run.sh
	@chmod +x powerlog/package-brew/fernivy
	@chmod +x powerlog/package-brew/powerlog_run.sh

clean_powerlog:
	@rm -rf powerlog/package
	@rm -rf powerlog/package-brew

clean: clean_perf clean_powerlog
