<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->
<!--- @@timeout: 0 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset oUtility = request.fcbObjectBucket.create(fullPath='farcry.plugins.fcblib.packages.custom.utility') />	
<!--- Decode HTML entity upon edit --->
<cfset stObj = oUtility.decodeHTMLEntity(stObj, this.getTypeName()) />		

<cfset setLock(stObj=stObj,locked=true) />

<cfset onExit = structNew() />
<cfset onExit.Type = "HTML" />
<cfsavecontent variable="onExit.Content">
	<!--- get parent to update tree --->
	<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
	
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
	
	<cfoutput>
		<script type="text/javascript">
			parent['content'].location.href = '#application.url.webtop#/edittabOverview.cfm?objectid=#stObj.ObjectID#';
		</script>
	</cfoutput>
</cfsavecontent>

<ft:processForm action="Save,Manage">
	<cfset setLock(stObj=stObj,locked=false) />
	<cfif arraylen(stObj.aObjectIDs)>
		<ft:processFormObjects typename="#stobj.typename#" />
	<cfelse>
		<ft:processFormObjects typename="#stobj.typename#">
			<cfif arraylen(stProperties.aObjectIDs)>
				<cfset newtypename = application.coapi.coapiadmin.findType(stProperties.aObjectIDs[1]) />
				<cfset oType = createobject("component",application.stCOAPI[newtypename].packagepath) />
				<cfset oType.setData(stProperties=oType.getData(objectid=stProperties.aObjectIDs[1],bUseInstanceCache=true)) />
				
				<cfset onExit.type = "html" />
				<cfsavecontent variable="onExit.content">
					<!--- get parent to update tree --->
					<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
					
					<!--- update tree --->
					<nj:updateTree objectId="#parentID#">
					
					<cfoutput>
						<script type="text/javascript">
							parent['content'].location.href = "#application.url.webtop#/edittabEdit.cfm?objectid=#stProperties.aObjectIDs[1]#&ref=overview&typename=#newtypename#";
						</script>
					</cfoutput>
				</cfsavecontent>
			</cfif>
		</ft:processFormObjects>
	</cfif>
</ft:processForm>

<ft:processForm action="Save" Exit="true" />

<ft:processForm action="Manage">
	
	<!--- get parent to update tree --->
	<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
	
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
		
	<cfif structKeyExists(form, "selectedObjectID")>
		<cfoutput>
			<script type="text/javascript">
				parent['content'].location.href = '#application.url.webtop#/edittabOverview.cfm?objectid=#form.selectedObjectID#';
			</script>
		</cfoutput>		
	</cfif>
</ft:processForm>

<ft:processForm action="Cancel" Exit="true">
	<cfset setLock(stObj=stObj,locked=false) />
</ft:processForm>

<ft:form>
	<cfoutput><h1>#stobj.label#</h1></cfoutput>
	
	<ft:object stObject="#stObj#" lFields="title,lNavIDAlias" legend="General Details" />
	
	<cfif not arraylen(stObj.aObjectIDs)>
		
		<cfoutput>
		<div style="margin-left:50px;padding:5px;border:1px solid ##A4C8E5;">
			<p class="highlight">You do not currently have any content under this navigation item. You have three options:</p>
		</cfoutput>				
			
			<cfset stPropMetadata = structnew() />
			<cfset stPropMetadata.aObjectIDs.ftLabel = "Content Type" />
			<cfset stPropMetadata.aObjectIDs.ftHint = "Select a content type to create as a child of this navigation item. If you select this option, you will be automatically redirected to edit the new content item." />
			<ft:object stObject="#stObj#" lFields="aObjectIDs" legend="OPTION 1: Create Content" stPropMetadata="#stPropMetadata#" bShowLibraryLink="false" />
			
			<cfset stPropMetadata = structnew() />
			<cfset stPropMetadata.ExternalLink.ftHint = "Select a navigation alias to redirect to when this navigation item is browsed too." />
	
			<ft:object stObject="#stObj#" lFields="ExternalLink" legend="OPTION 2: Redirect"  stPropMetadata="#stPropMetadata#"  />

			<cfset stPropMetadata = structnew() />
			<cfset stPropMetadata.ExternalURL.ftHint = "Key in an external URL. This will open the link in a new window." />
			<ft:object stObject="#stObj#" lFields="ExternalURL" legend="OPTION 3: External URL"  stPropMetadata="#stPropMetadata#"  />	
		
		<cfoutput>
		</div>
		</cfoutput>
		
	<cfelse>
		<cfoutput>
		<fieldset class="formSection ">
			<legend class="">Attached Content</legend>

			<div class="fieldSection field ">
				<label class="fieldsectionlabel ">
					&nbsp;
				</label>

				<div class="fieldAlign">
		</cfoutput>
		
						<cfloop from="1" to="#arrayLen(stobj.aObjectIDs)#" index="i">
							<cfset contentTypename = application.coapi.coapiAdmin.findType(objectid="#stobj.aObjectIDs[i]#") />
							<skin:view typename="#contentTypename#" objectid="#stobj.aObjectIDs[i]#" webskin="displayLabel" r_html="htmlContentLabel" />
							<cfoutput>
							<div style="margin-bottom:10px;padding:5px;border:1px solid ##A4C8E5;">				
								<table class="layout">								
								<tr>
									<td><img src="#application.url.webtop#/facade/icon.cfm?type=#contentTypename#" alt="" class="icon" style="float: right; padding: 10px;" /></td>
									<td style="vertical-align:middle;">
										#htmlContentLabel#
										<ft:button value="Manage" size="small" selectedObjectID="#stobj.aObjectIDs[i]#" />
									</td>
								</tr>
								</table>
							</div>								
							</cfoutput>
						</cfloop>	
		<cfoutput>		

					
				</div>
				<br class="clearer" />
			</div>
		</fieldset>

		</cfoutput>
	</cfif>
	
	<ft:buttonPanel>
		<ft:button value="Save" color="orange" /> 
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />