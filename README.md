# EEG Analysis #

### Introduction ###

This repo is created in May 2016. It is a part of my graduation project (correlation between music features and EEG).  

### Environment ###

* MATLAB R2012a  
* [EEGLAB v12.0.1.0b](http://sccn.ucsd.edu/eeglab/) (Click [here](https://bitbucket.org/zzc_actual/eeg-analysis/downloads/eeglab12_0_1_0b.zip) to download)  
* [FastICA 2.5](http://research.ics.aalto.fi/ica/fastica/) (Click [here](https://bitbucket.org/zzc_actual/eeg-analysis/downloads/FastICA_2.5.zip) to download)  

### Script ###

**version 1.0**  

Script 'zzc_eeg.m' can be used to analyze the correlation coefficient between music features (use [this](https://bitbucket.org/zzc_actual/music-feature-analysis) to calculate them) and EEG. The process is as follows:  

* preprocess: resample & filter  
* get amplitude of selected band  
* independent component analysis (ICA, optional)  
* calculate correlation coefficient  
* rank correlation coefficient  
* draw topography & save  

Script 'zzc_eeg_clear.m' can be used to clear the result of running 'zzc_eeg.m'.  

Other scripts are called by 'zzc_eeg.m'. Actually, I believe that script 'zzc_rank_sort_column.m' can be used as substitute of default function 'sort' in MATLAB.  

**version 2.0**  

My professor said that the process in script 'zzc_eeg.m' is not appropriate. And, the result is not satisfactory. So I change the process. New process is as follows:  

* preprocess: resample & filter  
* independent component analysis (ICA, optional)  
* get amplitude of selected band  
* calculate correlation coefficient  
* rank correlation coefficient  
* select by p  
* draw topography & save (optional)  

Some new features is added to script 'zzc_eeg.m', like these:  

* Directly read '.set' file.  
* Automatically save the result.  
* Custom information can be added to the name of the object folder.  

Script 'zzc_eeg_epoch.m' is added. This script is used to epoch fragments from raw EEG data. It can generate '.set' files, which can be directly used by script 'zzc_eeg.m'.  

Script 'zzc_eeg_clear.m' is also modified.  

### Other ###

* All lines end up with CRLF (Windows).  
* File '60_channels_map.ced' is used to draw topography.  