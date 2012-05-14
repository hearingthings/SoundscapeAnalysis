var triggerLatency = 0.021;
var serialWait = 0.01, nMeasures = 10;
var measurePeriod = (triggerLatency max: serialWait) * nMeasures;
var mpPlus = measurePeriod + 0.001;
var postDelay = 0.1;
var ambiTestPeriods = 4;
var onTestPeriods = 10;
var bpfQueue, whiteQueue, dbQueue;


var getSerialInt, getSerialMean;
var gbpfInAmp, gbpfOutAmp;


getSerialInt = { |wait=0.01|
Ê Ê Ê Êvar f = [], a, n, getInt;
	  getInt = {while({ n = p.next; n.notNil;}, {
Ê Ê Ê Ê Ê Ê Ê Êf = f.add(n);
Ê Ê Ê Ê})};

Ê Ê Ê Êp.put(1);
Ê Ê Ê Êwait.wait;
	  while({ f.size < 2 }, {
		getInt.value;  
	  });
Ê Ê Ê Êa = f[0] << 8;
Ê Ê Ê Êa = a + f[1];
Ê Ê Ê Êa
};
getSerialMean = { |n=20, wait=0.01|
	var f;
	f = [];
	n.do{ f = f.add(getSerialInt.value(wait)) };
	f.mean;	
};



SynthDef("bpfInAmp", { |freq, rq, inCh=0, ampTime=0.01, t_trig, id=0|
	var chain;
	chain = SoundIn.ar(0);
	chain = BPF.ar(chain, freq, rq);
	chain = Amplitude.kr(chain, ampTime, ampTime);
	SendReply.kr(t_trig, 'bpfInAmp', chain, id);
	
}).store;

SynthDef("whiteNoiseBPF", { |freq, rq, amp, ampTime, t_trig, id=0|
	var chain;
	chain = WhiteNoise.ar(amp);
	chain = BPF.ar(chain, freq, rq);
	Out.ar(0, chain);
	chain = Amplitude.kr(chain, ampTime, ampTime);
	SendReply.kr(t_trig, 'whiteNoiseBPF', chain, id);
}).store;



{
	var amps = (-70, -65..0).dbamp;
	var freq = 1000;
	var rq = 0.25;
	var ampTime = 0.01;
	var nTests = 1;
	var bpfInSynth;
	~results = Array.fill(amps.size, { Array.newClear(nTests) });
	
	(amps.size * (measurePeriod * (onTestPeriods +ambiTestPeriods))).debug("estimatedTime");

	o.remove; o = OSCresponder(nil, 'bpfInAmp', { 
		|t, r, msg| 
		var id = msg[2];
		var val = msg[3];
		bpfQueue = bpfQueue.add(val);
	}).add;
	r.remove; r = OSCresponder(nil, 'whiteNoiseBPF', { 
		|t, r, msg| 
		var id = msg[2];
		var val = msg[3];
		
		whiteQueue = whiteQueue.add(val);
	}).add;
	
	
	s.latency = 0;
	//set up initial synths
	bpfInSynth = Synth(\bpfInAmp, [\freq, freq, \rq, rq, \ampTime, ampTime]);
	
	3.wait;
	"no error".postln;
	//trigger routine
	nTests.do{ |testNum|
		amps.do{ |amp, i|
			var result, synth;
			var preMic=[], preDB=[], onMic=[], onDB=[], onOut=[], postMic=[], postDB=[];
			
			//do a test:
				//ambiPre
					//get mic and db levels for the various periods
				ambiTestPeriods.do{ |tp|
					var dbMean, micMean;
					{dbMean = getSerialMean.value(nMeasures, serialWait);}.fork;
					{	bpfQueue = [];
						nMeasures.do{ |n|
							bpfInSynth.set(\t_trig, 1);
							triggerLatency.wait;

						};
						micMean = bpfQueue.mean;

					}.fork;
					mpPlus.wait;
					preDB = preDB.add( dbMean );
					preMic = preMic.add( micMean );	
				};
				preMic = preMic.mean;
				preDB = preDB.mean;

				"finished ambitest".postln;
				//on
					//turn sound on
				synth = Synth('whiteNoiseBPF', [\freq, freq, \rq, rq, \amp, amp]);
					//wait a period
				mpPlus.wait;
					
					//get mic, db, and output levels for the various periods
				onTestPeriods.do{ |tp|
					var dbMean, mic, db, out;
					{dbMean = getSerialMean.value(nMeasures, serialWait);}.fork;
					{	bpfQueue = [];
						nMeasures.do{
							bpfInSynth.set(\t_trig, 1);
							triggerLatency.wait;

						};
						mic = bpfQueue.mean;
					}.fork;
					{	whiteQueue = [];
						nMeasures.do{
							synth.set(\t_trig, 1);
							triggerLatency.wait;
						};
						out = whiteQueue.mean;
					}.fork;
					
					mpPlus.wait;
					onMic = onMic.add( mic );
					onOut = onOut.add( out );
					onDB = onDB.add( dbMean );
					
				};
				onMic = onMic.mean;
				onOut = onOut.mean;
				onDB = onDB.mean;
				
					//turn sound off
				synth.free;

				//wait for postDelay	
				postDelay.wait;

				//off
					//get mic and db levels for the various periods
				ambiTestPeriods.do{ |tp|
					var dbMean, micMean;
					{dbMean = getSerialMean.value(nMeasures, serialWait);}.fork;
					{	bpfQueue = [];
						nMeasures.do{ |n|
							bpfInSynth.set(\t_trig, 1);
							triggerLatency.wait;

						};
						micMean = bpfQueue.mean;

					}.fork;
					mpPlus.wait;
					postDB = postDB.add( dbMean );
					postMic = postMic.add( micMean );				};
				postMic = postMic.mean;	
				postDB = postDB.mean;		
			//return test result
			//final version is ( \ambiPre: [mic, db], \on: [mic, db, out], \ambiPost, [mic, db])
			result = (
				ambiPre: [preMic, preDB],
				on: [onMic, onOut, onDB],
				ambiPost: [postMic, postDB],
				amp: amp
			);
			~results[i].put(testNum, result);
		};
	};	

}.fork;


