<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display first child --->

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- check for sim link --->
<cfif len(stObj.externalLink) gt 0>
	
	<cfsavecontent variable="sURL"><skin:buildLink objectid="#stObj.externalLink#" urlOnly="1" /></cfsavecontent>
	
	<cfif len(trim(sURL)) GT 0>
		<cflocation url="#sURL#" addtoken="false" />
	</cfif>

<cfelseif structKeyExists(stObj,"aObjectIds") AND arrayLen(stObj.aObjectIds)>

	<cfloop index="idIndex" from="1" to="#arrayLen(stObj.aObjectIds)#">
		<q4:contentobjectget objectid="#stObj.aObjectIds[idIndex]#" r_stobject="stObjTemp" />
		
		<!--- request.mode.lValidStatus is typically approved, or draft, pending, approved in SHOWDRAFT mode --->
		<cfif StructKeyExists(stObjTemp,"status") AND ListContains(request.mode.lValidStatus, stObjTemp.status)>
		
			<!--- Otherwise just show this one --->
			<nj:display objectid="#stObjTemp.objectid#" typename="#stObjTemp.typename#" />
			<cfsetting enablecfoutputonly="false" />
			<cfexit method="exittemplate">
			
		<cfelseif stObjTemp.typename neq "dmCSS">
		
			<!--- no status so just show object --->
			<!--- set the navigation point for the child obj --->
			<cfif isDefined("URL.navid")>
				<cfset request.navid = URL.navid>
				<cftrace var="stobj.objectid" text="object type not CSS,URL.navid exists - setting navid = url.navid" />
			<cfelse>
				<cfset request.navid = stObj.objectID>		
				<cftrace var="stobj.objectid" text="object type not CSS - setting navid = stobj.objectid" />
			</cfif>
			
			<!--- reset stObj to appropriate object to be displayed --->
			<nj:display objectid="#stObjTemp.objectid#" typename="#stObjTemp.typename#" />
			<cfsetting enablecfoutputonly="false" />
			<cfexit method="exittemplate" />
			
		</cfif>
		
	</cfloop>
	
</cfif>

<!--- If we get to this point, this object doesn't have any children --->
<cfif NOT isDefined("request.navid")>
	<cfset request.navid = stobj.objectid />
</cfif>

<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displayBody" />


<cfsetting enablecfoutputonly="false" />