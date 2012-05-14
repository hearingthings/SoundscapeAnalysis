if (p.isNil) {
	SerialPort.listDevices;
	p = SerialPort(
	Ê Ê Ê Ê"/dev/tty.usbmodem1d11",
	Ê Ê Ê Êbaudrate: 9600,
	Ê Ê Ê Êcrtscts: true);
};

~getSerialInt = { |wait=0.01|
Ê Ê Ê Êvar f = [], a, n, getInt, t=0;
	  getInt = {while({ n = p.next; n.notNil;}, {
Ê Ê Ê Ê Ê Ê Ê Êf = f.add(n);
Ê Ê Ê Ê})};

Ê Ê Ê Êp.put(1);
Ê Ê Ê Êwait.wait;
	  while({ (f.size < 2) and: (t < 10) }, {
		getInt.value;
		t = t+1;
	  });
	  t.debug("numserialtries");
Ê Ê Ê Êa = f[0] << 8;
Ê Ê Ê Êa = a + f[1];
Ê Ê Ê Êa
};
~getSerialMean = { |n=100, wait=0.01|
	var f;
	f = [];
	n.do{ f = f.add(~getSerialInt.value(wait)) };
	f.mean;	
};

c = Conductor.make{ |con, amp|
	SynthDef("pink", { |amp|
		Out.ar(0, PinkNoise.ar(amp));
	}).store;
	con.synth_(
		(instrument: \pink),
		[amp: amp]
	);
	
}.show;

{2.wait; ~getSerialMean.value(100).postln}.fork

a = [
	[691.25, 75.4],
	[738.39, 78.6],
	[667.77, 71.6],
	[634.11, 68.0],
	[603.17, 65.5],
	[511.68, 55.0],
	[462.45, 49.7],
	[421.32, 45.4],
	[381.55, 41.5],
	[480.75, 52.0],
	[749.88, 80.8],
	[794.73, 85.5]
];
	
a = a.sort{ |a, b| a[0] < b[0] };

b = a.flop[0];	
c = a.flop[1];	

f = File.new("data/scs/dbVolts/volts.txt", "w");
b.do{ |volt| f.write(volt.asString); f.write(","); };
f.close;

f = File.new("data/scs/dbVolts/dbs.txt", "w");
c.do{ |db| f.write(db.asString); f.write(","); };
f.close;


c.plot;


	
	
	