function [amplitude, frequency] = zzc_eeg_spectrum(eeg_fragment, sample_rate, length_s, channel, object_band_range)
%GET SPECTRUM of EEG FRAGMENT
%
%   [amplitude, frequency]
%      = zzc_eeg_spectrum(eeg_fragment, sample_rate, length_s, channel, object_band_range)
%
%   ----------
%
%   Parameter 'eeg_fragment' is the EEG data fragment. It must be a two-dimensional matrix.
%
%   Parameter 'sample_rate' is the sampling rate. It must be a double.
%
%   Parameter 'length_s' is the length (second) of the EEG data fragment.
%       It must be a double.
%
%   Parameter 'channel' indicates which channel of the EEG data fragment will be caculated.
%       It must be a double.
%
%   Parameter 'object_band_range' indicated which band (Hz) of the EEG data fragment will be caculated.
%       It must be a 1x2 matrix.
%
%   ----------
%
%   Return value 'amplitude' and 'frequency' indicate the spectrum of the EEG data fragment.
%       Use instruction 'plot(amplitude, frequency)' to get the spectrogram.

% check parameter
if length(size(eeg_fragment)) ~= 2
    error('Parameter 1 must be a two-dimensional matrix.');
end
if ~isfloat(sample_rate)
    error('Parameter 2 must be a double.');
end
if ~isfloat(length_s)
    error('Parameter 3 must be a double.');
end
if ~isfloat(channel)
    error('Parameter 4 must be a double.');
end
[r, c] = size(object_band_range);
if r ~= 1 || c ~= 2
    error('Parameter 5 must be a 1x2 matrix.')
end

selected_channel = eeg_fragment(channel, :);
point_number = sample_rate * length_s;
fft_point_number = size(selected_channel, 2);

% fast fourier transformation
if fft_point_number < point_number
    selected_channel = [selected_channel , zeros(1, (point_number - fft_point_number))];
    selected_channel = fft(selected_channel);
else
    selected_channel = fft(selected_channel, point_number);
end
amplitude = abs(selected_channel) / sqrt(point_number);
frequency = sample_rate / point_number * (0 : (point_number / 2 - 1));

% select band
amplitude = amplitude((frequency >= object_band_range(1)) & (frequency <= object_band_range(2)));
frequency = frequency((frequency >= object_band_range(1)) & (frequency <= object_band_range(2)));

end
