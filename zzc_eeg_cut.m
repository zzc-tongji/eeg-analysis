function eeg_fragment = zzc_eeg_cut(eeg_data, time_range, sample_rate)
%CUT EEG DATA
%
%   eeg_fragment = zzc_eeg_cut(eeg_data, time_range, sample_rate)
%
%   ----------
%
%   Parameter 'eeg_data' is the source EEG data. It must be a two-dimensional matrix.
%
%   Parameter 'time_range' indicates beginning and end time of fragment. It must be a 1x2 matrix.
%
%   Parameter 'sample_rate'. It must be a double.
%
%   Each value of multiplication of parameter 'eeg_data' and 'time_range'
%       should not be greater that the size of eache column of parameter 'eeg_data'.
%
%   ----------
%
%   Return value 'eeg_fragment' is the EEG data fragment.

% check parameter
if length(size(eeg_data)) ~= 2
    error('Parameter 1 must be a two-dimensional matrix.');
end
[r, c] = size(time_range);
if r ~= 1 || c ~= 2
    error('Parameter 2 must be a 1x2 matrix.')
end
if ~isfloat(sample_rate)
    error('Parameter 3 must be a double.');
end

% cut
a = time_range(1) * sample_rate + 1;
b = time_range(2) * sample_rate;
eeg_fragment = eeg_data(:, a : b);

end
