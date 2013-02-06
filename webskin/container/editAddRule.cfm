<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Add a new rule to the container --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfparam name="url.lRules" default="" />
<cfparam name="url.lExcludedRules" default="" />

<cfset qRules = createObject("component","#application.packagepath#.rules.rules").getRules(url.lRules,url.lExcludedRules) />

<cfset containerID = replace(stobj.objectid,'-','','ALL') />

<ft:processform action="Cancel" bHideForms="true">
	<skin:onReady>
		<cfoutput>parent.$j('###containerID#-dialog').dialog('close');</cfoutput>	
	</skin:onReady>
</ft:processform>

<ft:processform action="Add Rule" bHideForms="true">
	<cfparam name="stObj.aRules" default="#arraynew(1)#" />	

	<!--- Setup New Rule --->
	<cfset stDefaultObject = application.fapi.getNewContentObject(form.selectedObjectID) />
	<cfset application.fapi.getContentType("#form.selectedObjectID#").setData(stProperties=stDefaultObject) />
	
	<!--- Append new rule to the array of rules in the current container --->
	<cfset arrayappend(stObj.aRules,stDefaultObject.objectID) />
	<cfset setData(stProperties=stObj)>

	<!--- Locate off to the edit the rule. --->
	<skin:location href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stDefaultObject.objectid#&typename=#stDefaultObject.typename#&method=editInPlace&iframe=1&refobjectid=#url.objectid#" addtoken="false" />
</ft:processform>



<ft:form>


	<cfoutput>
		<fieldset class="fieldset">
			
			<cfloop query="qRules">
				<cfif not qRules.rulename eq "container">
					<div class="ctrlHolder blockLabels">
						<label class="label" for="newrule">
							<ft:button value="Add Rule" text="#qRules.displayName#"  rendertype="link"  selectedObjectID="#qRules.rulename#" />						
						</label>
						
						<div class="multiField">
							<cfif structKeyExists(application.rules['#qRules.rulename#'],'hint')>
								
								
							</cfif>			
							
						</div>
						<p class="formHint">#application.rules[qRules.rulename].hint#</p>
					</div>
				</cfif>
			</cfloop>
		</fieldset>
	</cfoutput>

</ft:form>


<cfsetting enablecfoutputonly="false" />