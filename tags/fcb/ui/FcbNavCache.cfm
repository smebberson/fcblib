<cfsetting enablecfoutputonly="yes" />

<!--- allow developers to close custom tag by exiting on end --->
<cfif thistag.ExecutionMode eq "end">
	<cfexit method="exittag" />
</cfif>

<cfif isDefined("request.ver") and request.ver>
	<cfoutput><!-- _FcbNav $Revision: 0.1 $ --></cfoutput>
</cfif>

<!--- params --->
<cfparam name="attributes.navID" default="#request.navID#">
<cfparam name="attributes.depth" default="1">
<cfparam name="attributes.startLevel" default="2">
<cfparam name="attributes.id" default="">
<cfparam name="attributes.bFirst" default="1">
<cfparam name="attributes.bLast" default="1">
<cfparam name="attributes.bActive" default="1">
<cfparam name="attributes.bIncludeHome" default="0">
<cfparam name="attributes.sectionObjectID" default="#request.navID#">
<cfparam name="attributes.functionMethod" default="getDescendants">
<cfparam name="attributes.functionArgs" default="depth=attributes.depth">
<cfparam name="attributes.bDump" default="0">
<cfparam name="attributes.class" default="">
<cfparam name="attributes.style" default="">
<cfparam name="request.sectionObjectID" default="#request.navID#">
<cfparam name="attributes.displayStyle" default="unorderedList">
<cfparam name="attributes.bHideSecuredNodes" default="0"><!--- MJB: check if option to Hide Nav Node Items that user does't have permission to access: default to 0 for backward compatibility --->
<cfparam name="attributes.afilter" default="#arrayNew(1)#">


<cfif application.config.plugins.fu>
	<cfset fu = createObject("component","#application.packagepath#.farcry.fu")>
</cfif>


		
<!--- // get navigation items --->
<cfif listFindNoCase(request.mode.lvalidstatus,"draft")>
	<cfset o = createObject("component", "farcry.core.packages.farcry.tree")>
<cfelse>
	<cfset o = createObject("component", "farcry.plugins.fcblib.packages.farcry.tree")>
</cfif>

<cfset navFilter=duplicate(attributes.afilter)>
<cfset arrayAppend(navFilter, "status IN (#listQualify(request.mode.lvalidstatus, '''')#)") />
<cfset qNav = evaluate("o."&attributes.functionMethod&"(objectid=attributes.navID, lColumns='externallink', "&attributes.functionArgs&", afilter=navFilter)")>

<!--- // get ansestors of attributes.navID --->
<cfset qAncestors = o.getAncestors(attributes.sectionObjectID)>
<cfset lAncestors = valuelist(qAncestors.objectid)>

<cfif attributes.bIncludeHome>
	<!--- // get application.navid.home objectName --->
	<cfset homeNode = o.getNode(objectID=#application.navid.home#)>
</cfif>

<cfif attributes.bLast>
	<!--- here we get the most right nav so we can add a last class to it if needed --->
	<cfquery name="qMaxRight" dbtype="query">
		select max(nRight) as maxRight from qNav
	</cfquery>
</cfif>
<cffunction name="dump">
	<cfargument name="arg">
	<cfdump var="#arg#">
	<cfabort/>
</cffunction>

<cfoutput>
<div id="navMain" class="clearfix">
</cfoutput>

<cfif attributes.displayStyle EQ "aLink">
	<cfloop query="qNav">
		<cfif application.config.plugins.fu>
			<cfset strhref = application.fc.factory.farFU.getFU(qNav.objectid)>
		<cfelse>
			<cfset strhref = application.url.conjurer & "?objectid=" & qNav.objectid>
		</cfif>
		<cfif qNav.currentRow GT 1>
			<cfoutput> | </cfoutput>		
		</cfif>
		<cfoutput><a href="#strhref#" title="#qNav.objectName#">#qNav.objectName#</a></cfoutput>
	</cfloop>
<cfelse>

<cfscript>
	// initialise counters
	currentlevel=0; // nLevel counter
	ul=0; // nested list counter
	bHomeFirst = false; // used to stop the first node being flagged as first if home link is inserted.
	bFirstNodeInLevel = true; // used to track the first node in each level.						
	// build menu [bb: this relies on nLevels, starting from nLevel 2]
	for(i=1; i lt incrementvalue(qNav.recordcount); i=i+1){
		
		
		if (attributes.bHideSecuredNodes EQ 0) {
			iHasViewPermission = 1;
		}
		else{
			iHasViewPermission = application.security.checkPermission(object=qNav.ObjectID[i],permission="View");
		}
		
		if (iHasViewPermission EQ 1)
		{
		
					
			if(qNav.nLevel[i] gte attributes.startLevel){
				//dump("test");
				//check external links
				if(structkeyexists(qNav,'externallink') and len(qNav.externallink[i])){
					object = trim(qNav.externallink[i]);
				}
				else{
					object = trim(qNav.ObjectID[i]);
				}
				//check for friendly urls
				if(application.config.plugins.fu){
					href = application.fc.factory.farFU.getFU(object);
				}
				else{
					href = application.url.conjurer & "?objectid=" & object;
				}
				itemclass='';
				
				if(qNav.nLevel[i] lt attributes.startlevel+attributes.depth - 1  and qNav.nRight[i]-qNav.nleft[i] neq 1) {
					itemclass=itemclass & 'parent ';	
				}
				

				//this means it is the last column in nav
				if(attributes.bLast and qNav.nRight[i] eq qMaxRight.maxRight){
					itemclass=itemclass & 'last ';
				}
				if(attributes.bActive and (trim(qNav.ObjectID[i]) eq request.sectionObjectID or listfind(lAncestors, trim(qNav.ObjectID[i])))){
					itemclass=itemclass & 'active ';
				}
				// update counters
				previouslevel=currentlevel;
				currentlevel=qNav.nLevel[i];
				// build nested list
				// if first item, open first list
				if(previouslevel eq 0) {
					writeOutput("<ul");
					// add id or class if specified
					if(len(attributes.id)){
						writeOutput(" id=""#attributes.id#""");
					}
					if(len(attributes.class)){
						writeOutput(" class=""#attributes.class#""");
					}
					if(len(attributes.style)){
						writeOutput(" style=""#attributes.style#""");
					}
					writeOutput(">");
					//include home if requested
					if(attributes.bIncludeHome){
						homeclass = 'home ';
						
						if(attributes.bFirst){
							homeclass=homeclass & ' first ';
							bHomeFirst = true;
						}				
						
						writeOutput("<li");
						if(request.sectionObjectID eq application.navid.home){
							homeclass=homeclass & ' active ';
						}
						writeOutput(" class="""&trim(homeclass)&"""");
						writeOutput("><a href=""#application.url.webroot#/""><span class=""toplevel"">#homeNode.objectName#</span></a></li>");
					}
					ul=ul+1;
				}
				else if(currentlevel gt previouslevel){
					// if new level, open new list
					writeOutput("<ul>");
					ul=ul+1;
					bFirstNodeInLevel = true;
				}
				else if(currentlevel lt previouslevel){
					// if end of level, close current item
					writeOutput("</li>");
					// close lists until at correct level
					writeOutput(repeatString("</ul></li>",previousLevel-currentLevel));
					ul=ul-(previousLevel-currentLevel);
				}
				else{
					// close item
					writeOutput("</li>");
				}
				if(attributes.bFirst){
					if(previouslevel eq 0 AND bHomeFirst) {
						//top level and home link is first
					} else {
						if(bFirstNodeInLevel){
							itemclass=itemclass & 'first ';
							bFirstNodeInLevel=false;
						}
					}
					
				}
				// open a list item
				writeOutput("<li");
				if(len(trim(itemclass))){
					// add a class
					writeOutput(" class="""&trim(itemclass)&"""");
				}
				// write the link
				
				if (qNav.nLevel[i] eq attributes.startlevel) {
				    writeOutput("><a href="""&href&"""><span class=""toplevel"">"&trim(qNav.ObjectName[i]) & "</span></a>");
				} else {
				    writeOutput("><a href="""&href&""">"&trim(qNav.ObjectName[i]));
				    if(qNav.nLevel[i] lt attributes.startlevel+attributes.depth - 1  and qNav.nRight[i]-qNav.nleft[i] neq 1) {
				    	 writeOutput(" <span class=""indicator"">&##187;</span>");
				    }
				    writeOutput("</a>");
				}
			}
		}
	}
	// end of data, close open items and lists
	writeOutput(repeatString("</li></ul>",ul));
	

	if (attributes.bIncludeHome AND ul EQ 0)
		{
			writeOutput("<ul");
			
			// add id or class if specified
			if(len(attributes.id))
			{
				writeOutput(" id=""#attributes.id#""");
			}
			if(len(attributes.class))
			{
				writeOutput(" class=""#attributes.class#""");
			}
			writeOutput(">");
						
			writeOutput("<li");
			if(request.sectionObjectID eq application.navid.home)
			{
				writeOutput(" class=""active""");
			}
			writeOutput("><a href=""#application.url.webroot#/"">#homeNode.objectName#</a></li></ul>");
		}
			
</cfscript>
</cfif>
<cfoutput>
	</div>
</cfoutput>
<cfsetting enablecfoutputonly="no" />