FreqWeighting {

	classvar <dBATable, <dBCTable;
	
	*initClass {
		var w;
		w = [
			20, 		-50.39485544953144, 	-6.219314505055775,
			40,		-34.53944652216944,	-1.981601442383699,
			80,		-22.397864845969433,	-0.49616535098426534,
			120,		-16.70898634885321, 	-0.19126229888796986,
			160,		-13.244524521345557,	-0.08244844758564795,
			200,		-10.847251705547315, 	-0.032149983610281554,
			300,		-7.054656066972937,	0.015737975844390798,
			400,		-4.774080439360921,	0.029508426801028446,
			800,		-0.7947685551968535,	0.018821286898093006,
			1000,	0,					0,
			1500,	0.9043003835710138,	-0.07011201728508164,
			3000,	1.2287449334196208,	-0.4485105349670798,
			6000,	0.05157916561081696,	-1.819781134058758,
			10000,	-2.4883328267581657,	-4.402200263167712,
			15000,	-6.010258146624303,	-7.937491292675597
		
		];
		
		w = w.clump(3).flop;
		dBATable = [ w[0], w[1] ];
		dBCTable = [ w[0], w[2] ];

	}

	
	*freqToDBA { |freq|
		^this.tableIndex(freq, dBATable);
	}

	*freqToDBC { |freq|
		^this.tableIndex(freq, dBCTable);
		
	}
	
	*tableIndex { |freq, table|
		var index = table[0].indexInBetween(freq);
		var weight;
		weight = [table[1].at(index.floor), table[1].at(index.ceil)];
		weight = weight.frac.linlin(0, 1, weight[0], weight[1]);
		^weight
	}


	
}


/*
w = w.clump(3).flop;
x = [w[0], w[1] ]
x = x.flop
i = w[0].indexInBetween(8000)
*/
