<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry CMS Plugin.

    FarCry CMS Plugin is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry CMS Plugin is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with FarCry CMS Plugin.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: Display page child links --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset oNav = CreateObject("component", application.stcoapi.dmNavigation.packagepath) /> 


<!--- assumes existance of request.navid  --->
<cfparam name="request.navid">


<!--- get the children of this object --->
<cfset qGetChildren = application.factory.oTree.getChildren(objectid=stObj.refobjectid) />

<cfoutput>
<div class="module">
</cfoutput>

	<cfif len(trim(stObj.label))>
		<cfoutput><h3 class="heading">#stObj.label#</h3></cfoutput>
	</cfif>
	
	<cfoutput>
		<div class="inner">
	</cfoutput>
	
	<cfif len(trim(stObj.intro))>
		<cfoutput><p class="intro">#stObj.intro#</p></cfoutput>
	</cfif>
	
	
<cfif qGetChildren.recordcount GT 0>
	<!--- loop over children --->
	<cfloop query="qGetChildren">
	
		<!--- get child nav details --->
		<cfset stCurrentNav = oNav.getData(objectid=qGetChildren.objectID) />
		
		<!--- check for sim link --->
		<cfif len(stCurrentNav.externalLink)>
			<!--- get sim link details --->
			<cftry>
				<cfset stCurrentNav = oNav.getData(objectid=stCurrentNav.externalLink) />
				
				<cfcatch><!--- Ignore if the object doesnt exist ---></cfcatch>
			</cftry>
		</cfif>
		
		<cfquery datasource="#application.dsn#" name="qNavPages">
		SELECT * FROM dmNavigation_aObjectIDs
		where parentid = '#stCurrentNav.objectid#'
		order by seq
		</cfquery>
	
		<cfif qNavPages.recordCount>
			<!--- loop over child/sim link nav node --->	
			<cfloop query="qNavPages">
				<cfset o = createObject("component", application.stcoapi[qNavPages.typename].packagepath) />
				<cfset stObjTemp = o.getData(objectid=qNavPages.data) />
				
				<!--- request.lValidStatus is approved, or draft, pending, approved in SHOWDRAFT mode --->
				<cfif StructKeyExists(stObjTemp,"status") AND ListContains(request.mode.lValidStatus, stObjTemp.status) AND StructKeyExists(stObjTemp,"displayMethod")>
				
					<!--- if in draft mode grab underlying draft page --->			
					<cfif IsDefined("stObjTemp.versionID") AND request.mode.showdraft>
						<cfquery datasource="#application.dsn#" name="qHasDraft">
							SELECT objectID,status from #application.dbowner##stObjTemp.typename# where versionID = '#stObjTemp.objectID#' 
						</cfquery>
						
						<cfif qHasDraft.recordcount gt 0>
							<cfset stObjTemp = o.getData(objectid=qHasDraft.objectid) />
						</cfif>
					</cfif>
					
					<skin:view objectid="#stObjTemp.objectid#" webskin="#stObj.displaymethod#" />
	
					<cfbreak>
				</cfif>
			</cfloop>
		<cfelse>
			<skin:view objectid="#stCurrentNav.objectid#" webskin="#stObj.displaymethod#" alternateHTML="" />
		</cfif>
		
	</cfloop>
	
</cfif>
	
<cfoutput>
	</div>
</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />