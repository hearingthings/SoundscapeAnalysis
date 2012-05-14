// current setup, ear thresh is either 0.003981071705535.ampdb, 0.0063095734448019.ampdb

//
//make a new array of events with the following keys
//amp, onDB, offDB


//t = Object.readArchive("/Users/blank/Applications/SuperCollider/sipTest1/sipTest_2.txt");

l = t.data.flat.collect{ |e|
		[ e[\on][0].ampdb, e[\amp].ampdb ];
};
//[ onMicDB, instAmpDB ]


~onMicDB = l.flop[0];
~instAmpDB = l.flop[1];

f = File.new("data/scs/micVsSpeaker/onMicDB.txt", "w");
~onMicDB.do{ |lev| f.write(lev.asString); f.write(", ") };
f.close;

f = File.new("data/scs/micVsSpeaker/instAmpDB.txt", "w");
~instAmpDB.do{ |lev| f.write(lev.asString); f.write(", ") };
f.close;

/*
~instAmpForMicDB = { |micDB|
	(1.077 * micDB) + -30.14;
};

Linear model Poly1:
     f(x) = p1*x + p2
Coefficients (with 95% confidence bounds):
       p1 =       1.077  (1.054, 1.1)
       p2 =       30.14  (29, 31.29)
*/