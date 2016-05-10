





<!---

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>
      Google Visualization API Sample
    </title>
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load('visualization', '1', {packages: ['gauge']});
    </script>
    <script type="text/javascript">
    var gauge;
    var gaugeData;
    var gaugeOptions;
    function drawGauge() {
      gaugeData = new google.visualization.DataTable();
      gaugeData.addColumn('number', 'BIN 1');
      gaugeData.addRows(1);
      gaugeData.setCell(0, 0, 55);
    
    
      gauge = new google.visualization.Gauge(document.getElementById('gauge'));
      gaugeOptions = {
          min: 0, 
          max: 100, 
          yellowFrom: 80,
          yellowTo: 90,
          redFrom: 90, 
          redTo: 100, 
          minorTicks: 5
      };
      gauge.draw(gaugeData, gaugeOptions);
    }
    
    function changeTemp(dir) {
      gaugeData.setValue(0, 0, gaugeData.getValue(0, 0) + dir * 25);
       gauge.draw(gaugeData, gaugeOptions);
    }
    
    
    google.setOnLoadCallback(drawGauge);
    </script>
  </head>
  <body style="font-family: Arial;border: 0 none;">
    <div id="gauge" style="width: 300px; height: 300px;"></div>
    <input type="button" value="Go Faster" onclick="changeTemp(1)" />
    <input type="button" value="Slow down" onclick="changeTemp(-1)" />
--->






<cfif isDefined("loadReport")>
	<cflocation url="loadReportSP.cfm?cbxDate=#cbxDate#" addtoken="no">
</cfif>

<cfset suffix = 2009>
<cfparam name="farmID" default="16">
<cfparam name="seasonToday" default="8">
<cfparam name="filter_groupID" default="15">
<cfparam name="filter_farmID" default="16">

<!--- setup for season and farm selection --->
<CFINCLUDE TEMPLATE="../filter_params.cfm">

<!--- Sackett Potatoes are currently the only customers --->
<cfif (client.user_userID EQ 60) OR (client.user_userAccessID EQ AdminID)>
	<cfset filter_groupID = 15>
	<cfset filter_farmID = 16>
</cfif>

<cfif filter_midSeasonID LT 9>
		<cfset suffix = 2001 + filter_midSeasonID>
<cfelse><cfset suffix = ""></cfif>
<cfset seasonToday = client.filter_midSeasonToday>
<cfset farmID = filter_farmID>
<!--- cfoutput>selected(#filter_midSeasonID#) -- today(#seasonToday#)<br></cfoutput --->


<CFQUERY NAME="q_get_seasons" DATASOURCE="#datasource#">
	SELECT season_id, season
	FROM season
	WHERE (season_id>7) AND (season_id<=#seasonToday#) AND (season_id IN (#client.user_seasonIDs#))
	ORDER BY season_id
</CFQUERY>

<CFQUERY NAME="q_get_groups" DATASOURCE="#datasource#">
	SELECT group_id, group_name
	FROM groups
	WHERE group_id IN (#client.user_availableGroupIDs#)
	ORDER BY group_name
</CFQUERY>

<CFQUERY NAME="q_get_farms" DATASOURCE="#datasource#">
	SELECT farm_id, farm_name
	FROM farm
	WHERE farm_id IN (#client.user_availableFarmIDs#)
		<CFIF filter_groupID GT 0>
			AND farm.group_id = #filter_groupID#
		</CFIF>
	ORDER BY farm_name	
</CFQUERY>

<!--- initialize data structures --->
<cfset bins = structNew()>
<cfset fields = structNew()>
<cfset trucks = structNew()>

<!--- queries for getting id and name --->
<cfquery name="qryTrucks" datasource="#datasource#">
	SELECT truck_id, truck_name, empty_weight
	FROM trucks
	WHERE (farm_id=#farmID#)
	ORDER BY truck_name ASC
</cfquery>
<cfset truckList = "">
<cfloop query="qryTrucks">
	<cfset trucks[qryTrucks.truck_id] = structNew()>
	<cfset trucks[qryTrucks.truck_id]["name"] = qryTrucks.truck_name>
	<cfset trucks[qryTrucks.truck_id]["empty_weight"] = qryTrucks.empty_weight>
	<cfset trucks[qryTrucks.truck_id]["count"] = 0>
	<cfset truckList = listAppend(truckList, qryTrucks.truck_id)>
</cfloop>

<cfquery name="qryFields" datasource="#datasource#">
	SELECT field_id, field_name
	FROM field
	WHERE (farm_id=#farmID#) AND (season_id=#filter_midSeasonID#)
	ORDER BY field_name ASC
</cfquery>
<cfset fieldList = "">
<cfloop query="qryFields">
	<cfif uCase(left(qryFields.field_name,5)) EQ "FIELD">
		<cfset fields["F#qryFields.field_id#"]["name"] = qryFields.field_name>
	<cfelse>
		<cfset fields["F#qryFields.field_id#"]["name"] = "Field " & qryFields.field_name>
	</cfif>
	<cfset fields["F#qryFields.field_id#"]["total"] = 0>
	<cfset fields["F#qryFields.field_id#"]["trucks"] = 0>
	<cfset fieldList = listAppend(fieldList, "F#qryFields.field_id#")>
</cfloop>
<cfset fields["F99"]["name"] = "Boundary Error">
<cfset fields["F99"]["total"] = 0>
<cfset fields["F99"]["trucks"] = 0>
<cfset fieldList = listAppend(fieldList, "F99")>
<cfset fields["F0"]["name"] = "Undefined">
<cfset fields["F0"]["total"] = 0>
<cfset fields["F0"]["trucks"] = 0>
<cfset fields["total"] = 0>
<cfset fields["trucks"] = 0>
<cfset fieldList = listAppend(fieldList, "F0")>

<cfquery name="qryBins" datasource="#datasource#">
	SELECT bin_id, bin_name,capacity
	FROM bin
	WHERE (farm_id=#farmID#) AND (season_id=#filter_midSeasonID#)
	ORDER BY bin_name ASC
</cfquery>
<cfset binList = "">
<cfloop query="qryBins">
	<cfif uCase(left(qryBins.bin_name,3)) EQ "BIN">
		<cfset bins["B#qryBins.bin_id#"]["name"] = qryBins.bin_name>
	<cfelse>
		<cfset bins["B#qryBins.bin_id#"]["name"] = "Bin " & qryBins.bin_name>
	</cfif>
	<cfset bins["B#qryBins.bin_id#"]["fields"] = structNew()>
	<cfset bins["B#qryBins.bin_id#"]["total"] = 0>
	<cfset bins["B#qryBins.bin_id#"]["trucks"] = 0>
    <cfif qryBins.capacity LT 1>
    <cfset bins["B#qryBins.bin_id#"]["capacity"]=0>
	<cfelse>
    <cfset bins["B#qryBins.bin_id#"]["capacity"]=qryBins.capacity>
    </cfif>
	<cfset binList = listAppend(binList, "B#qryBins.bin_id#")>
</cfloop>
<cfset bins["B901"]["name"] = "Loadout">
<cfset bins["B901"]["total"] = 0>
<cfset bins["B901"]["trucks"] = 0>
<cfset binList = listAppend(binList, "B901")>
<cfset bins["B0"]["name"] = "Undefined">
<cfset bins["B0"]["total"] = 0>
<cfset bins["B0"]["trucks"] = 0>
<cfset bins["total"] = 0>
<cfset bins["trucks"] = 0>
<cfset binList = listAppend(binList, "B0")>

<!--- get dates to be used for selecting a load subset --->
<cfquery name="qryDates" datasource="#datasource#">
	SELECT DISTINCT CONVERT(VARCHAR(10), load_dtm, 101) AS load_date
	FROM loads#suffix#
	WHERE (farm_id=#farmID#) AND (deleted=0)
	ORDER BY load_date DESC
</cfquery>
<cfset cbxDateList = valueList(qryDates.load_date)>
<cfparam name="cbxDate" default="allBins">

<!--- query to build output array --->
<cfquery name="qryLoads" datasource="#datasource#">
	SELECT load_bin, bin_id_est, bin_id_data, bin_id_user,
		   load_field, field_id_est, field_id_data, field_id_user,
		   weight_est, weight_data, weight_user, truck_id
	FROM loads#suffix# 
	WHERE (farm_id=#farmID#) AND (deleted=0)
		<cfif NOT(left(cbxDate, 3) EQ "all")>AND (CONVERT(VARCHAR(10), load_dtm, 101)='#cbxDate#')</cfif>
</cfquery>

<!--- accumulate weight by bin and by field --->
<cfif qryLoads.recordCount GT 0>
  <cfloop query="qryLoads">
  	<cfif qryLoads.bin_id_user GT 0><cfset loadBinID = qryLoads.bin_id_user>
  	<cfelseif qryLoads.bin_id_data GT 0><cfset loadBinID = qryLoads.bin_id_data>
  	<cfelse><cfset loadBinID = qryLoads.bin_id_est>
	</cfif>
    <!---cfset loadBinID = qryLoads.load_bin --->
	
  	<cfif qryLoads.field_id_user GT 0><cfset loadFieldID = qryLoads.field_id_user>
  	<cfelseif qryLoads.field_id_data GT 0><cfset loadFieldID = qryLoads.field_id_data>
  	<cfelse><cfset loadFieldID = qryLoads.field_id_est>
	</cfif>
    <!--- cfset loadFieldID = qryLoads.load_field --->

	<cfif NOT structKeyExists(bins["B#loadBinID#"], "F#loadFieldID#")>
		<cfset bins["B#loadBinID#"]["F#loadFieldID#"] = structNew()>
		<cfset bins["B#loadBinID#"]["F#loadFieldID#"]["total"] = 0>
		<cfset bins["B#loadBinID#"]["F#loadFieldID#"]["trucks"] = 0>
	</cfif>

	<cfif NOT structKeyExists(fields["F#loadFieldID#"], "B#loadBinID#")>
		<cfset fields["F#loadFieldID#"]["B#loadBinID#"] = structNew()>
		<cfset fields["F#loadFieldID#"]["B#loadBinID#"]["total"] = 0>
		<cfset fields["F#loadFieldID#"]["B#loadBinID#"]["trucks"] = 0>
	</cfif>

	<cfif qryLoads.weight_user GT 0><cfset netWeight = qryLoads.weight_user>
	<cfelseif qryLoads.weight_data GT 0><cfset netWeight = qryLoads.weight_data>
	<cfelse><cfset netWeight = qryLoads.weight_est></cfif>
	<cfset netWeight = netWeight - trucks[qryLoads.truck_id]["empty_weight"]>

	<cfset bins["B#loadBinID#"]["F#loadFieldID#"]["total"] = bins["B#loadBinID#"]["F#loadFieldID#"]["total"] + netWeight>
	<cfset bins["B#loadBinID#"]["F#loadFieldID#"]["trucks"] = bins["B#loadBinID#"]["F#loadFieldID#"]["trucks"] + 1>
	<cfset bins["B#loadBinID#"]["total"] = bins["B#loadBinID#"]["total"] + netWeight>
	<cfset bins["B#loadBinID#"]["trucks"] = bins["B#loadBinID#"]["trucks"] + 1>
	<cfset bins["total"] = bins["total"] + netWeight>
	<cfset bins["trucks"] = bins["trucks"] + 1>
	
	<cfset fields["F#loadFieldID#"]["B#loadBinID#"]["total"] = fields["F#loadFieldID#"]["B#loadBinID#"]["total"] + netWeight>
	<cfset fields["F#loadFieldID#"]["B#loadBinID#"]["trucks"] = fields["F#loadFieldID#"]["B#loadBinID#"]["trucks"] + 1>
	<cfset fields["F#loadFieldID#"]["total"] = fields["F#loadFieldID#"]["total"] + netWeight>
	<cfset fields["F#loadFieldID#"]["trucks"] = fields["F#loadFieldID#"]["trucks"] + 1>
	<cfset fields["total"] = fields["total"] + netWeight>
	<cfset fields["trucks"] = fields["trucks"] + 1>
		
	<cfset trucks[qryLoads.truck_id]["count"] = trucks[qryLoads.truck_id]["count"] + 1>
  </cfloop>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

<meta http-equiv="X-UA-Compatible" content="IE=edge"><meta http-equiv="content-type" content="text/html; charset=UTF-8">

<title>QualTrac Inventory Report</title>
<link rel="stylesheet" href="css/undo.css" type="text/css">
<link rel="stylesheet" href="css/loadReport.css" type="text/css">
<script type="text/javascript" src="js/overlib.js"><!-- overLIB (c) Erik Bosrup --></script>
<script type="text/javascript" src="js/loadReport.js"></script>
<script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load('visualization', '1', {packages: ['gauge']});
    </script>
    <script type="text/javascript">
    var gauge;
    var gaugeData;
    var gaugeOptions;
    function drawGauge() {
      gaugeData = new google.visualization.DataTable();
	   counter = 0;
	    gaugeData.addColumn('string', 'Label');
        gaugeData.addColumn('number', 'Value');
     
	
		<cfloop list="#binList#" index="binID">
		<cfoutput>
		<cfset binsize=bins[binID]["capacity"]>
	<cfif binsize gt 0>
   	   gaugeData.addRows([
          ['#bins[binID]["name"]#', ('#bins[binID]["total"]#'/100)/'#binsize#']]);
	  </cfif>
	  counter=counter+1;
	  
	  </cfoutput>
	  </cfloop>
      
     
    
    
      gauge = new google.visualization.Gauge(document.getElementById('gauge'));
      gaugeOptions = {
          min: 0, 
          max: 100, 
          yellowFrom: 80,
          yellowTo: 90,
          redFrom: 90, 
          redTo: 100, 
          minorTicks: 5
      };
      gauge.draw(gaugeData, gaugeOptions);
    }
    
    function changeTemp(dir) {
      gaugeData.setValue(0, 0, dir);
       gauge.draw(gaugeData, gaugeOptions);
    }
    
    
    google.setOnLoadCallback(drawGauge);
    </script>

</head>

<body>
<div id="gauge" style="width: 900px; height: 900px;"></div>

<table border="1" cellpadding="10" cellspacing="0" style="margin-left:20px;">
<tr><!--- LAYOUT: header row --->
<td colspan="2">
<FORM ACTION="Gauge_reports.cfm" NAME="filterForm">
  <TABLE>
	<!--- add header row --->
	<tr>
		<td align="left" colspan="2">
		  <div style="margin:8px; padding:5px;">
			<cfoutput><FONT SIZE=3 COLOR="#accentColor#"><B>QualTrac Inventory Report (loads#suffix#)</FONT></cfoutput>
		  </div>
		</td>
	</tr>
	<TR>
		<TD NOWRAP colspan="2">
			<FONT SIZE=1>
			Select Season
			<SELECT NAME="filter_midSeasonID" onChange="filterForm.submit();">
				<CFOUTPUT QUERY="q_get_seasons">
					<OPTION VALUE="#season_id#" <CFIF filter_midSeasonID IS season_id>SELECTED</CFIF>>#season#
				</CFOUTPUT>
			</SELECT>
			&nbsp;&nbsp;Select 
			<CFIF client.user_numberOfFarms GT 1>
				<CFIF (q_get_groups.recordCount GT 1) AND (listLen(client.user_availableGroupIDs) GT 1)>
					Group
					<SELECT NAME="filter_groupID" onChange="filterForm.submit();">
						<OPTION VALUE="" <CFIF filter_groupID IS "">SELECTED</CFIF>>- All Groups -
						</option><CFOUTPUT QUERY="q_get_groups">
							<CFIF filter_groupID IS group_id>
								<cfset selected = "SELECTED">
							<CFELSE>
							 	<cfset selected = "">
							</CFIF>
							<OPTION VALUE="#group_id#" #selected#>#group_name#
						</CFOUTPUT>
					</SELECT>&nbsp;&nbsp;
				</CFIF>
				Farm Name
				<SELECT NAME="filter_farmID" onChange="filterForm.submit();">
					<OPTION VALUE=0>- Select -
					</option><CFOUTPUT QUERY="q_get_farms">
						<OPTION VALUE="#farm_id#" <CFIF filter_farmID IS farm_id>SELECTED</CFIF>>#farm_name#
					</CFOUTPUT>
				</SELECT>
			<CFELSE>
				<CFQUERY NAME="q_get_farm_name" DATASOURCE="#datasource#">
					SELECT farm_name
					FROM farm
					WHERE farm_id = #client.user_availableFarmIDs#
				</CFQUERY>
				<CFOUTPUT>#q_get_farm_name.farm_name#</CFOUTPUT>
			</CFIF>
			<INPUT TYPE="Hidden" NAME="startRow" VALUE="1" />
		</font>
		</TD>
	</TR>
  </TABLE>
</FORM>
</td>
</tr><!--- end header row --->

<FORM name="mainForm" id="mainForm" method="post" action="Gauge_reports.cfm">
<tr>
<td valign="top"><!--- left column --->
  <cfset Width = 175>
  <cfoutput>
	<b>Report Date</b><br>
	<cfif listLen(cbxDateList) GT 0>
		<select name="cbxDate" id="cbxDate">
			<option value="allBins" <cfif cbxDate EQ "allBins">selected</cfif>>All Bins</option>
			<option value="allFields" <cfif cbxDate EQ "allFields">selected</cfif>>All Fields</option>
		<cfloop list="#cbxDateList#" index="load_date">
			<option value="#load_date#" <cfif load_date EQ cbxDate>selected</cfif>>#load_date#</option>
		</cfloop>
		</select><br>
		<input type="submit" name="Submit" value="Update Report" style="width:#Width#px;">
	<cfelse>no loads
	</cfif>
	<br>&nbsp;<br>
	<b>Return to Load Report</b><br>
	<input type="submit" name="loadReport" value=" Load Report SP " style="width:#Width#px;"><br>
  </cfoutput>
</td>
<td valign="top"><!--- right column --->

<!--- add the load report --->
<table border="0" cellpadding="0" cellspacing="0">
  <tr><td colspan="5"><b>Total Loads:</b> <cfoutput>#qryLoads.recordCount#</cfoutput></td></tr>
<cfoutput>
<cfif qryLoads.recordCount GT 0>
  <cfif NOT(cbxDate EQ "allFields")>
  <tr>
	<td><b>BIN</b></td>
	<td>&nbsp;</td>
	<td><b>FIELD</b></td>
	<td>&nbsp;</td>
	<td align="right"><b>CWT</b></td>
	<td>&nbsp;</td>
	<td><b>LOADS</b></td>
  </tr>
  <!--- output accumulations --->
  <cfloop list="#binList#" index="binID">
  <cfif bins[binID]["total"] GT 0>
	<tr>
		<td>#bins[binID]["name"]#</td>
		<td colspan="6">&nbsp;</td>
	</tr>
	<cfloop list="#fieldList#" index="fieldID">
	  <cfif structKeyExists(bins[binID], fieldID)>
		<tr>
			<td>&nbsp;</td>
			<td width="20">&nbsp;</td>
			<td>#fields[fieldID]["name"]#</td>
			<td width="20">&nbsp;</td>
			<td align="right">#numberFormat(int(bins[binID][fieldID]["total"] / 100))#</td>
			<td width="20">&nbsp;</td>
			<td align="center">#bins[binID][fieldID]["trucks"]#</td>
		</tr>
	  </cfif>
	</cfloop>
	<tr>
		<td>&nbsp;</td>
		<td width="20">&nbsp;</td>
		<td><b>TOTAL</b></td>
		<td width="20">&nbsp;</td>
		<td align="right">#numberFormat(int(bins[binID]["total"] / 100))#</td>
		<td width="20">&nbsp;</td>
		<td align="center">#bins[binID]["trucks"]#</td>
	</tr>
  </cfif>
  </cfloop>
  <tr><td colspan="7">&nbsp;</td></tr>

  <tr>
  	<td><b>ALL BINS</b></td>
	<td width="20">&nbsp;</td>
	<td><b>TOTAL</b></td>
	<td width="20">&nbsp;</td>
	<td align="right"><b>#numberFormat(int(bins["total"] / 100))#</b></td>
	<td width="20">&nbsp;</td>
	<td align="center"><b>#bins["trucks"]#</b></td>
  </tr>
  <cfelse>  
  <tr><td colspan="5" style="border-bottom:2x solid black;">&nbsp;</td></tr>
  <tr>
  	<td><b>FIELD</b></td>
	<td width="20">&nbsp;</td>
	<td><b>BIN</b></td>
	<td width="20">&nbsp;</td>
	<td align="right"><b>CWT</b></td>
	<td width="20">&nbsp;</td>
	<td><b>LOADS</b></td>
  </tr>
  <cfloop list="#fieldList#" index="fieldID">
  <cfif fields[fieldID]["total"] GT 0>
  	<tr>
		<td>#fields[fieldID]["name"]#</td>
		<td width="20">&nbsp;</td>
	</tr>
	<cfloop list="#binList#" index="binID">
	  <cfif structKeyExists(fields[fieldID], binID)>
		<tr>
			<td>&nbsp;</td>
			<td width="20">&nbsp;</td>
			<td>#bins[binID]["name"]#</td>
			<td width="20">&nbsp;</td>
			<td align="right">#numberFormat(int(fields[fieldID][binID]["total"] / 100))#</td>
			<td width="20">&nbsp;</td>
			<td align="center">#fields[fieldID][binID]["trucks"]#</td>
		</tr>
	  </cfif>
	</cfloop>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td><b>TOTAL</b></td>
		<td width="20">&nbsp;</td>
		<td align="right">#numberFormat(int(fields[fieldID]["total"] / 100))#</td>
		<td width="20">&nbsp;</td>
		<td align="center">#fields[fieldID]["trucks"]#</td>
	</tr>
  </cfif>
  </cfloop>
  <tr><td colspan="7">&nbsp;</td></tr>
  <tr>
  	<td><b>ALL FIELDS</b></td>
	<td width="20">&nbsp;</td>
	<td><b>TOTAL</b></td>
	<td width="20">&nbsp;</td>
	<td align="right"><b>#numberFormat(int(fields["total"] / 100))#</b></td>
	<td width="20">&nbsp;</td>
	<td align="center"><b>#fields["trucks"]#</b></td>
  </tr>
<!--- load counts by truck
  <tr><td colspan="5" style="border-bottom:2x solid black;">&nbsp;</td></tr>
  <tr>
  	<td><b>TRUCK COUNT</b></td>
	<td width="20">&nbsp;</td>
	<td><b>Truck</b></td>
	<td width="20">&nbsp;</td>
	<td><b>Count</b></td>
  </tr>
  <cfloop list="#truckList#" index="truckID">
  <cfif trucks[truckID]["count"] GT 0>
    <tr>
	  <td colspan='2'>&nbsp;</td>
	  <td>#trucks[truckID]["name"]#</td>
	  <td width="20">&nbsp;</td>
	  <td>#trucks[truckID]["count"]#</td>
	</tr>
  </cfif>
  </cfloop>
 --->
  </cfif><!--- cfif NOT(cbxDate EQ "allFields") --->
<cfelse>
	<tr>
		<td colspan="11" valign="top">
			&nbsp;<br>&nbsp;No loads to summarize<br>&nbsp;
		</td>
	</tr>
</cfif><!--- cfif qryLoads.recordCount GT 0 --->
</cfoutput>
<!--- END load report --->
			
</table>
</td>
</tr>
</FORM>

<!--- end layout table --->
</table>
--->
</body>
</html>
