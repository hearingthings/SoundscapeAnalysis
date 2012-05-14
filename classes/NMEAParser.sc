/*
f = File.new("/Users/danielstclair/projects/soundscapeSensor/longRecordings/MayZoom/GPS.TXT", "r");

f.seek(0, 0);
g = f.getLine;

a =0; i=0; l = ""; c = $a;
while({(c.ascii != 13) and: (i <256) }) {
	c = f.getChar;
	l = l ++ c;
	i = i+1;	
}

l

c = f.getChar.ascii;
f.pos;
f.seek(43, 0);
g = f.getLine
f.seek(0,0);

g.size
*/

//NMEAParser

//file interface
//get new line from file
	//seek to first dollar sign
	//add characters into string until char 13

//TODO: checksums - check'em

NMEAParser {
	
	getLineFromFile { |file| 
		var i=0, c=file.getChar, l="";
		while( { (i < 256) and: (c != $$) } ) {
			c =file.getChar;
		};

		if (c != $$) { "NMEAParser: no $ Char in first 256 bytes of file".throw; };

		while({(c.ascii != 13) and: (i <256) }) {
			c = f.getChar;
			l = l ++ c;
			i = i+1;	
		};
		
		if (l[0..2] != "$GP") { "No valid NMEA sentence found".throw; };
		
		l; //return new line
	}

	processLine { |line|
		
		var thisType = line[1..5]; //TODO: check if dollar sign has been stripped out
		var types = ["GPGSA", "GPGSV", "GPRMC", "GPVTG", "GPGGA"];
		
		types.do{ |type, i|
			if (type == thisType) {
				type = "parse" ++ type;
				this.perform(type.asSymbol, line);
			};
		};		
	}

	parseGPGSA { |line|
		var keys = [
			1, \MODE,
			(3..14), \PRN,
			15, \PDOP,
			16, \HDOP,
			17, \VDOP
		];
		var outDic = Dictionary.new;
		
		keys.clump(2).do{ |index, i|
			var key = index[1];
			var obj, res;
			index = index[0];
			if (index.size == 0) { //we're working with a single integer
				outDic.put(key, parseElement(line[index]));
			} {
				//we have an array
				index.do{ |in, ini|
					
				};
			};	
		};
		line = line.split($,);
		
	}
	
	parseGPGSV { |line|
	
	}
	
	parseGPRMC { |line|
		/*
	1    = UTC time of fix
	2    = Data status (A=Valid position, V=navigation receiver warning)
	3    = Latitude of fix
	4    = N or S of longitude
	5    = Longitude of fix
	6    = E or W of longitude
	7    = Speed over ground in knots
	8    = Track made good in degrees True
	9    = UTC date of fix
	10   = Magnetic variation degrees (Easterly var. subtracts from true course)
	11   = E or W of magnetic variation
	12   = Mode indicator, (A=Autonomous, D=Differential, E=Estimated, N=Data not valid)
	13   = Checksum
	*/
	}
	
	parseGPVTG { |line|
		
	}
	
	parseGPGGA { |line|
	
	}

	parseElement { |el|
		var obj, res;
		obj = try{ res = el.interpret };
		if (obj.isNil) {
			res = el;
		};
		res;
	}
	
	
}




