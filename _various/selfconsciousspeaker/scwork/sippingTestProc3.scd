// current setup, ear thresh is either 0.003981071705535.ampdb, 0.0063095734448019.ampdb

//
//make a new array of events with the following keys
//amp, onDB, offDB


//t = Object.readArchive("/Users/blank/Applications/SuperCollider/sipTest1/sipTest_2.txt");

~ev = t.data.flat.collect{ |e|
		var noiseMean;
		noiseMean = (e[\ambiPost][0] + e[\ambiPre][0]) / 2;
		[e[\amp], e[\ambiPre][1], e[\ambiPost][1]];
};


//see if off amp gets higher once the amp gets higher
o = ~ev = ~ev.sort{ |a, b| a[0] < b[0] }; //sort by amp ascending
o = o.flop;
o[1..].multiplot(drawLines: true);
o[1].plot
o[2].plot