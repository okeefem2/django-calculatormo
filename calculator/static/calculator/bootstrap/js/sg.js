<SCRIPT>
	function computeFS(sg) {
		var fs = new Number(0);
		
		fs = (13.21858 + (0.17809 * Math.round((sg - 1.06) * 1000)));
		return fs;
	}
	function computeSGadjust(t1, t2, t3, tw) {
		var sgadj = new Number(0);
		var total = new Number(0);
		var count = new Number(0);
		var iWater = new Number(0);
		var iTuber = new Number(0);

		var sg38 = new Array(-21, -20, -18, -18, -20, -23, -29, -38, -47, -56);
		var sg40 = new Array(-17, -16, -14, -14, -16, -19, -25, -34, -43, -52);
		var sg45 = new Array( -9,  -8,  -6,  -6,  -8, -11, -17, -26, -35, -44);
		var sg50 = new Array( -3,  -2,   0,   0,  -2,  -5, -11, -20, -29, -38);
		var sg55 = new Array(  1,   2,   4,   4,   2,  -1,  -7, -16, -25, -34);
		var sg60 = new Array(  4,   5,   7,   7,   5,   2,  -4, -13, -22, -31);
		var sg65 = new Array(  5,   6,   8,   8,   6,   3,  -3, -12, -21, -30);
		var sg70 = new Array(  6,   7,   9,   9,   7,   4,  -2, -11, -20, -29);
		var sg75 = new Array(  7,   8,   10, 10,   8,   5,  -1, -10, -19, -28); 
		var sg80 = new Array(  8,   9,   11, 11,   9,   6,   0,  -9, -18, -27); 
		var sg85 = new Array(  9,  10,   12, 12,  10,   7,   1,  -8, -17, -26); 
		var sg90 = new Array( 10,  11,   13, 13,  11,   8,   2,  -7, -16, -25); 
		var sg95 = new Array( 11,  12,   14, 14,  12,   9,   3,  -6, -15, -24); 
		var sg100 = new Array(12,  13,   15, 15,  13,  10,   4,  -5, -14, -23); 
		
		if(t1 > 0) { total = total + t1; count = count + 1; }
		if(t2 > 0) { total = total + t2; count = count + 1; }
		if(t3 > 0) { total = total + t3; count = count + 1; }
		if(count >  0) { total = total / count; }
				
		if(total < 40) { iTuber = 0; }
		else if(total > 100) { iTuber = 13; }
		else { iTuber = Math.round(total / 5) - 7; }
		
		if(tw < 40) { iWater = 0; }
		else if(tw > 80) { iWater = 9; }
		else { iWater = Math.round(tw / 5) - 7; }
		
		if((tw > 0) && (total > 0) && (Math.abs(tw - total) > 10)) 
		{	switch(iTuber)
			{ case 0: sgadj =  (sg38[iWater] / 10000); break;
			  case 1: sgadj =  (sg40[iWater] / 10000); break;
			  case 2: sgadj =  (sg45[iWater] / 10000); break;
			  case 3: sgadj =  (sg50[iWater] / 10000); break;
			  case 4: sgadj =  (sg55[iWater] / 10000); break;
			  case 5: sgadj =  (sg60[iWater] / 10000); break;
			  case 6: sgadj =  (sg65[iWater] / 10000); break;
			  case 7: sgadj =  (sg70[iWater] / 10000); break;
			  case 8: sgadj =  (sg75[iWater] / 10000); break;
			  case 9: sgadj =  (sg80[iWater] / 10000); break;
			  case 10: sgadj =  (sg85[iWater] / 10000); break;
			  case 11: sgadj =  (sg90[iWater] / 10000); break;
			  case 12: sgadj =  (sg95[iWater] / 10000); break;
			  case 13: sgadj =  (sg100[iWater] / 10000); break;
			}
		}
		return sgadj;
	}		
	function computeSG(ww, wa) {
		var sg = new Number(0);
	
		if((wa < 0) || (ww < 0) || (ww > wa)) { return ''; }
		
		sg = wa / (wa - ww); 
 		return sg;
	}
</SCRIPT>