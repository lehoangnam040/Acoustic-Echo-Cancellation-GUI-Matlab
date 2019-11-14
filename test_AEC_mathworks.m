fs = 8000;

M = fs/2 + 1;

frameSize = 2048;

[B,A] = cheby2(4,20,[0.1 0.7]);
impulseResponseGenerator = dsp.IIRFilter('Numerator', [zeros(1,6) B], ...
    'Denominator', A);
roomImpulseResponse = impulseResponseGenerator( ...
        (log(0.99*rand(1,M)+0.01).*sign(randn(1,M)).*exp(-0.002*(1:M)))');
roomImpulseResponse = roomImpulseResponse / norm(roomImpulseResponse) * 4;
room = dsp.FIRFilter('Numerator', roomImpulseResponse');

% plot filter
% FVT = fvtool(impulseResponseGenerator);  % Analyze the filter
% FVT.Color = [1 1 1];
disp(fs);
load nearspeech;    % v la nearspeech
disp(fs);
load farspeech;     % x la farspeech
% fs = 16000;
L = length(x);
echoFarspeech = room(x);

micSignal = v + echoFarspeech + 0.001*randn(L ,1);
% Construct the Frequency-Domain Adaptive Filter
echoCanceller    = dsp.FrequencyDomainAdaptiveFilter('Length', 2048, ...
                    'StepSize', 0.025, ...
                    'InitialPower', 0.01, ...
                    'AveragingFactor', 0.98, ...
                    'Method', 'Unconstrained FDAF');
                
% [y, e] = echoCanceller(micSignal, x);

nearSpeechSrc   = dsp.SignalSource('Signal',v,'SamplesPerFrame',frameSize);
farSpeechSrc    = dsp.SignalSource('Signal',x,'SamplesPerFrame',frameSize);
farSpeechEchoSrc = dsp.SignalSource('Signal', echoFarspeech, 'SamplesPerFrame', frameSize);
micSrc = dsp.SignalSource('Signal', micSignal, 'SamplesPerFrame', frameSize);

nearSpeechSrc.SamplesPerFrame = frameSize;
farSpeechSrc.SamplesPerFrame = frameSize;
farSpeechEchoSrc.SamplesPerFrame = frameSize;
micSrc.SamplesPerFrame = frameSize;
% Switch the echo canceller to Partitioned constrained FDAF
echoCanceller.Method      = 'Partitioned constrained FDAF';
% Set the block length to frameSize
echoCanceller.BlockLength = frameSize;
resSink = dsp.SignalSink;
% ySink = dsp.SignalSink;

% Stream processing loop - adaptive filter step size = 0.025
while(~isDone(micSrc))
    farSpeech = farSpeechEchoSrc();
    micS = micSrc();
    % Apply FDAF
    [y, e] = echoCanceller(farSpeech, micS);
    resSink(e);
%     ySink(y);
end

result = resSink.Buffer;
% y_hat = ySink.Buffer;





