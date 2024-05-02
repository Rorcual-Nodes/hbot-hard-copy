

set -ex



pip check
python -c "import pandas; pandas.test(extra_args=['-m not clipboard and not single_cpu', '--skip-slow', '--skip-network', '--skip-db', '-n=2'])"
exit 0
