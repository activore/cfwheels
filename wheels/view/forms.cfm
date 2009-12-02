<cffunction name="endFormTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing the closing `form` tag."
	examples=
	'
		<!--- view code --->
		<cfoutput>
		    ##startFormTag(action="create")##
		        <!--- your form controls --->
		    ##endFormTag()##
		</cfoutput>
	'
	categories="view-helper,forms-general" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,submitTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfscript>
		if (StructKeyExists(request.wheels, "currentFormMethod"))
			StructDelete(request.wheels, "currentFormMethod");
	</cfscript>
	<cfreturn "</form>">
</cffunction>

<cffunction name="startFormTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing the opening form tag. The form's action will be built according to the same rules as `URLFor`."
	examples=
	'
		<!--- view code --->
		<cfoutput>
		    ##startFormTag(action="create", spamProtection=true)##
		        <!--- your form controls --->
		    ##endFormTag()##
		</cfoutput>
	'
	categories="view-helper,forms-general" chapters="form-helpers-and-showing-errors" functions="URLFor,endFormTag,submitTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="method" type="string" required="false" default="#application.wheels.functions.startFormTag.method#" hint="The type of method to use in the form tag, `get` and `post` are the options.">
	<cfargument name="multipart" type="boolean" required="false" default="#application.wheels.functions.startFormTag.multipart#" hint="Set to `true` if the form should be able to upload files.">
	<cfargument name="spamProtection" type="boolean" required="false" default="#application.wheels.functions.startFormTag.spamProtection#" hint="Set to `true` to protect the form against spammers (done with JavaScript).">
	<cfargument name="route" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="controller" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="action" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="key" type="any" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="params" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="anchor" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="onlyPath" type="boolean" required="false" default="#application.wheels.functions.startFormTag.onlyPath#" hint="See documentation for @URLFor.">
	<cfargument name="host" type="string" required="false" default="#application.wheels.functions.startFormTag.host#" hint="See documentation for @URLFor.">
	<cfargument name="protocol" type="string" required="false" default="#application.wheels.functions.startFormTag.protocol#" hint="See documentation for @URLFor.">
	<cfargument name="port" type="numeric" required="false" default="#application.wheels.functions.startFormTag.port#" hint="See documentation for @URLFor.">
	<cfscript>
		var loc = {};
		$insertDefaults(name="startFormTag", input=arguments);

		// sets a flag to indicate whether we use get or post on this form, used when obfuscating params
		request.wheels.currentFormMethod = arguments.method;

		// set the form's action attribute to the URL that we want to send to
		arguments.action = URLFor(argumentCollection=arguments);

		// make sure we return XHMTL compliant code
		arguments.action = Replace(arguments.action, "&", "&amp;", "all");

		// deletes the action attribute and instead adds some tricky javascript spam protection to the onsubmit attribute
		if (arguments.spamProtection)
		{
			loc.onsubmit = "this.action='#Left(arguments.action, int((Len(arguments.action)/2)))#'+'#Right(arguments.action, ceiling((Len(arguments.action)/2)))#';";
			arguments.onsubmit = $addToJavaScriptAttribute(name="onsubmit", content=loc.onsubmit, attributes=arguments);
			StructDelete(arguments, "action");
		}

		// set the form to be able to handle file uploads
		if (!StructKeyExists(arguments, "enctype") && arguments.multipart)
			arguments.enctype = "multipart/form-data";

		loc.skip = "multipart,spamProtection,route,controller,key,params,anchor,onlyPath,host,protocol,port";
		if (Len(arguments.route))
			loc.skip = ListAppend(loc.skip, $routeVariables(argumentCollection=arguments)); // variables passed in as route arguments should not be added to the html element
		if (ListFind(loc.skip, "action"))
			loc.skip = ListDeleteAt(loc.skip, ListFind(loc.skip, "action")); // need to re-add action here even if it was removed due to being a route variable above

		loc.returnValue = $tag(name="form", skip=loc.skip, attributes=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="submitTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a submit button `form` control."
	examples=
	'
		!--- view code --->
		<cfoutput>
		    ##startFormTag(action="something")##
		        <!--- form controls go here --->
		        ##submitTag()##
		    ##endFormTag()##
		</cfoutput>
	'
	categories="view-helper,forms-general" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="value" type="string" required="false" default="#application.wheels.functions.submitTag.value#" hint="Message to display in the button form control.">
	<cfargument name="image" type="string" required="false" default="#application.wheels.functions.submitTag.image#" hint="File name of the image file to use in the button form control.">
	<cfargument name="disable" type="any" required="false" default="#application.wheels.functions.submitTag.disable#" hint="Whether to disable the button upon clicking (prevents double-clicking).">
	<cfscript>
		var loc = {};
		$insertDefaults(name="submitTag", reserved="type,src", input=arguments);
		if (Len(arguments.disable))
		{
			loc.onclick = "this.disabled=true;";
			if (!Len(arguments.image) && !IsBoolean(arguments.disable))
				loc.onclick = loc.onclick & "this.value='#arguments.disable#';";
			loc.onclick = loc.onclick & "this.form.submit();";
			arguments.onclick = $addToJavaScriptAttribute(name="onclick", content=loc.onclick, attributes=arguments);
		}
		if (Len(arguments.image))
		{
			// create an img tag and then just replace "img" with "input"
			arguments.type = "image";
			arguments.source = arguments.image;
			StructDelete(arguments, "value");
			StructDelete(arguments, "image");
			StructDelete(arguments, "disable");
			loc.returnValue = imageTag(argumentCollection=arguments);
			loc.returnValue = Replace(loc.returnValue, "<img", "<input");
		}
		else
		{
			arguments.type = "submit";
			loc.returnValue = $tag(name="input", close=true, skip="image,disable", attributes=arguments);
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$formValue" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfscript>
		var loc = {};
		if (IsStruct(arguments.objectName))
		{
			loc.returnValue = arguments.objectName[arguments.property];
		}
		else
		{
			loc.object = Evaluate(arguments.objectName);
			if (application.wheels.showErrorInformation && !IsObject(loc.object))
				$throw(type="Wheels.IncorrectArguments", message="The `#arguments.objectName#` variable is not an object.");
			if (StructKeyExists(loc.object, arguments.property))
				loc.returnValue = loc.object[arguments.property];
			else
				loc.returnValue = "";
		}
	</cfscript>
	<cfreturn HTMLEditFormat(loc.returnValue)>
</cffunction>

<cffunction name="$maxLength" returntype="any" access="public">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfscript>
		var loc = {};
		
		// if the developer passed in a maxlength value, use it
		if (StructKeyExists(arguments, "maxlength"))
			return arguments.maxlength;
		
		// explicity return void so the property does not get set	
		if (IsStruct(arguments.objectName))
			return;
			
		loc.object = Evaluate(arguments.objectName);
		
		// if objectName does not represent an object, explicity return void so the property does not get set
		if (not IsObject(loc.object))
			return;
			
		if (StructKeyExists(loc.object, arguments.property)) {
			loc.propertyInfo = loc.object.$propertyInfo(arguments.property);
			if (ListFindNoCase("cf_sql_char,cf_sql_varchar", loc.propertyInfo.type))
				return loc.propertyInfo.size;
		}
	</cfscript>
	<cfreturn />
</cffunction>

<cffunction name="$formHasError" returntype="boolean" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = false;
		if (!IsStruct(arguments.objectName))
		{
			loc.object = Evaluate(arguments.objectName);
			if (application.wheels.showErrorInformation && !IsObject(loc.object))
				$throw(type="Wheels.IncorrectArguments", message="The `#arguments.objectName#` variable is not an object.");
			if (ArrayLen(loc.object.errorsOn(arguments.property)))
				loc.returnValue = true;
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$createLabel" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="label" type="string" required="true">
	<cfargument name="prependToLabel" type="string" required="true">
	<cfargument name="$appendToFor" type="string" required="false" default="">
	<cfscript>
		var loc = {};
		loc.returnValue = arguments.prependToLabel;
		loc.attributes = {};
		for (loc.key in arguments)
		{
		 if (Left(loc.key, 5) == "label" && Len(loc.key) > 5 && loc.key != "labelPlacement")
			loc.attributes[Replace(loc.key, "label", "")] = arguments[loc.key];
		}
		if (StructKeyExists(arguments, "id"))
			loc.attributes.for = arguments.id;
		else
			loc.attributes.for = $tagId(arguments.objectName, arguments.property);
		if (Len(arguments.$appendToFor))
			loc.attributes.for = loc.attributes.for & "-" & arguments.$appendToFor;
		loc.returnValue = loc.returnValue & $tag(name="label", attributes=loc.attributes);
		loc.returnValue = loc.returnValue & arguments.label;
		loc.returnValue = loc.returnValue & "</label>";
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$formBeforeElement" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="label" type="string" required="true">
	<cfargument name="labelPlacement" type="string" required="true">
	<cfargument name="prepend" type="string" required="true">
	<cfargument name="append" type="string" required="true">
	<cfargument name="prependToLabel" type="string" required="true">
	<cfargument name="appendToLabel" type="string" required="true">
	<cfargument name="errorElement" type="string" required="true">
	<cfargument name="$appendToFor" type="string" required="false" default="">
	<cfscript>
		var loc = {};
		loc.returnValue = "";
		if ($formHasError(argumentCollection=arguments))
			loc.returnValue = loc.returnValue & $tag(name=arguments.errorElement, class="field-with-errors");
		if (Len(arguments.label) && arguments.labelPlacement != "after")
		{
			loc.returnValue = loc.returnValue & $createLabel(argumentCollection=arguments);
			if (arguments.labelPlacement == "around")
				loc.returnValue = Replace(loc.returnValue, "</label>", "");
			else
				loc.returnValue = loc.returnValue & arguments.appendToLabel;

		}
		loc.returnValue = loc.returnValue & arguments.prepend;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$formAfterElement" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="label" type="string" required="true">
	<cfargument name="labelPlacement" type="string" required="true">
	<cfargument name="prepend" type="string" required="true">
	<cfargument name="append" type="string" required="true">
	<cfargument name="prependToLabel" type="string" required="true">
	<cfargument name="appendToLabel" type="string" required="true">
	<cfargument name="errorElement" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = arguments.append;
		if (Len(arguments.label) && arguments.labelPlacement != "before")
		{
			if (arguments.labelPlacement == "after")
				loc.returnValue = loc.returnValue & $createLabel(argumentCollection=arguments);
			else if (arguments.labelPlacement == "around")
				loc.returnValue = loc.returnValue & "</label>";
			loc.returnValue = loc.returnValue & arguments.appendToLabel;
		}
		if ($formHasError(argumentCollection=arguments))
			loc.returnValue = loc.returnValue & "</" & arguments.errorElement & ">";
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>