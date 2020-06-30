def foof2mat_customfreq():
    import sys
    import hdf5storage

    import sklearn
    from scipy import io
    import scipy
    import numpy as np
    from fooof import FOOOF
    import neurodsp
    import matplotlib.pyplot as plt
    import pacpy
    import h5py
    import matplotlib
    from matplotlib import lines

    import math

    from neurodsp import spectral

    # FOOOF imports: get FOOOF & FOOOFGroup objects
    from fooof import FOOOFGroup
    slpa = []
    ra = []
    dat = hdf5storage.loadmat(str(sys.argv[1]))
    frq_ax = np.linspace(0, 1000, 10001)  #dat["fx"][0]
    pwr_spectra = dat['avgpwr']  #dat["powall"]
    for fl in range(30, 100, 2):
        for ul in range(50, 300, 2):
            if fl < ul:
                # pwr_spectra=x['x']
                # Initialize a FOOOFGroup object - it accepts all the same settings as FOOOF
                fg = FOOOFGroup(max_n_peaks=6, peak_threshold=4)

                frange = (fl, ul)

                # Fit a group of power spectra with the .fit() method# Fit a
                #  The key difference (compared to FOOOF) is that it takes a 2D array of spectra
                #     This matrix should have the shape of [n_spectra, n_freqs]
                fg.fit(frq_ax, pwr_spectra, frange)

                slp = fg.get_all_data('background_params', 'slope')
                r = fg.get_all_data('r_squared')

                slpa = np.concatenate((slpa, slp))
                ra = np.concatenate((ra, r))


    scipy.io.savemat('slpa.mat',{'slpa': slpa})
    scipy.io.savemat('ra.mat', {'ra': ra})
    return

foof2mat_customfreq()