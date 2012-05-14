// current setup, ear thresh is either 0.003981071705535.ampdb, 0.0063095734448019.ampdb

//
//make a new array of events with the following keys
//amp, onDB, offDB


//t = Object.readArchive("/Users/blank/Applications/SuperCollider/sipTest1/sipTest_2.txt");

l = t.data.flat.collect{ |e|
		[ e[\on][0], e[\on][1] ];
};
//[ onMic, onOut ]


~onMic = l.flop[0];
~onOut = l.flop[1];

f = File.new("data/scs/micVsSpeaker/onMic.txt", "w");
~onMic.do{ |lev| f.write(lev.asString); f.write(", ") };
f.close;

f = File.new("data/scs/micVsSpeaker/onOut.txt", "w");
~onOut.do{ |lev| f.write(lev.asString); f.write(", ") };
f.close;

/*
~outToMicLevel = { |out|
	(0.6335 * out) + 0.0004892;
};

Linear model Poly1:
     f(x) = p1*x + p2
Coefficients (with 95% confidence bounds):
       p1 =      0.6335  (0.616, 0.651)
       p2 =   0.0004892  (0.0001798, 0.0007987)
*/