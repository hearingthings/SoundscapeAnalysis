///
(
SerialPort.devices;
p = SerialPort(
Ê Ê Ê Ê"/dev/tty.usbmodem1d11",
Ê Ê Ê Êbaudrate: 9600,
Ê Ê Ê Êcrtscts: true);
)

s.recChannels_(1) ;

// read a byte from the device
(
	var getSerialInt;
	
	getSerialInt = {
	Ê Ê Ê Êvar f = [], a, n;
	Ê Ê Ê Êp.put(1);
	Ê Ê Ê Ê0.1.wait;
	Ê Ê Ê Êwhile({ n = p.next; n.notNil;}, {
	Ê Ê Ê Ê Ê Ê Ê Êf = f.add(n);
	Ê Ê Ê Ê Ê Ê Ê Ê0.01.wait;
	Ê Ê Ê Ê});
	Ê Ê Ê Êa = f[0] << 8;
	Ê Ê Ê Êa = a + f[1];
	Ê Ê Ê Êa
	};

	
	{	
		var i = 1; //interval
		var amps = (-60, -48..0);
		var freqs = (50, 54..123).midicps;
		var resultsPerTest = 10;
		var estTime;
		estTime = (amps.size * freqs.size) * ((resultsPerTest * 0.1) + 0.5 + 0.3);
		estTime.debug("estimated time");
		~results = Array.fill(freqs.size, { Array.fill(amps.size) });

		SynthDef("sinetest", { |freq, amp, gate=1|
			var chain, env;
			env = Env.asr(0.01, amp, 0.01);
			env = EnvGen.kr(env, gate: gate, doneAction:2);
			chain = SinOsc.ar(freq, 0, amp * env);
			Out.ar(0, chain);
		}).store;
		
		2.wait;
		s.record;
		freqs.do{ |freq, findex|
			freq.debug("freq");
			amps.do{ |amp, aindex|
				var synth = Synth("sinetest", [\freq, freq, \amp, amp.dbamp, \gate, 1]);
				var resArr = Array.newClear(resultsPerTest);
				amp.debug("amp");
				0.5.wait; //settling time
				resArr = resArr.collect{ 
					var r = getSerialInt.value;
					0.1.wait; //wait time between measurements for new data	
					//TODO: filter out nils
					r
				};
				
				~results[findex].put(aindex, resArr);
				
				synth.set(\gate, 0);
				0.3.wait;
			};
		};
		
		s.stopRecording;

	}.fork;
)



p.close;
