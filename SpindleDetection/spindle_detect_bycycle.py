def spindle_detect_bycycle():
	import sys
	import numpy as np
	import scipy as sp
	from scipy import io
	import matplotlib.pyplot as plt
	from bycycle.filt import lowpass_filter
	from bycycle.features import compute_features
	import pandas
	import hdf5storage

	signal_all =hdf5storage.loadmat(str(sys.argv[1]))
	signal_all=signal_all["lfp"]["trial"][0][0][0]
	refch_all = range(0,len(signal_all))

	Fs = 1000
	f_lowpass = 40
	N_seconds = .25

	for refch in refch_all:
		signal = signal_all[refch, :]
		signal_low = lowpass_filter(signal, Fs, f_lowpass,
								N_seconds=N_seconds, remove_edge_artifacts=False)

		from bycycle.burst import plot_burst_detect_params

		burst_kwargs = {'amplitude_fraction_threshold': float(sys.argv[2]),
					'amplitude_consistency_threshold': float(sys.argv[3]),
					'period_consistency_threshold': float(sys.argv[4]),
					'monotonicity_threshold': float(sys.argv[5]),
					'N_cycles_min': 4}

		#burst_kwargs = {'amplitude_fraction_threshold': .5,
		#            'amplitude_consistency_threshold': .3,
		#            'period_consistency_threshold': .5,
		#            'monotonicity_threshold': .7,
		#            'N_cycles_min': 4}

		df = compute_features(signal_low, Fs, (8.5,19), burst_detection_kwargs=burst_kwargs,hilbert_increase_N=True)

		df_csv = pandas.DataFrame.to_csv(df)

		df_dir = "spindle_detect\spindle_peaks"+str(refch)+".csv"
		csv = open(df_dir,"w")
		csv.write(df_csv)
	return 

spindle_detect_bycycle()