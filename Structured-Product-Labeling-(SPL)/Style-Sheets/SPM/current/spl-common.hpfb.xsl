<?xml version="1.0" encoding="us-ascii"?>
<!DOCTYPE html>
<!--
**************************
@Health Canada:
Jeffrey: This XSL should be able to render all text for the 2004/2016 templates.
We did not receive test files other than the 2004 Standard so I cannot confirm it
it will work 100% without any bugs. From the test files that we did receive,
ALL data from the XMLs are displayed as they are ordered, with all tables
and attributes preserved as well.

The main rendering is done at line 185, which renders the XML tags according to the
XSL:templates available in THIS file.

DONE: Rednering Data, Tables, Numbering, Table of Documents

LAST THING WORKED ON: Section numbering, should be completed
****************************

The contents of this file are subject to the Health Level-7 Public
License Version 1.0 (the "License"); you may not use this file
except in compliance with the License. You may obtain a copy of the
License at http://www.hl7.org/HPL/hpl.txt.

Software distributed under the License is distributed on an "AS IS"
basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
the License for the specific language governing rights and
limitations under the License.

The Original Code is all this file.

The Initial Developer of the Original Code is Gunther Schadow.
Portions created by Initial Developer are Copyright (C) 2002-2013
Health Level Seven, Inc. All Rights Reserved.

Contributor(s): Steven Gitterman, Brian Keller, Brian Suggs

TODO: footnote styleCode Footnote, Endnote not yet obeyed
TODO: Implementation guide needs to define linkHtml styleCodes.
-->
<!-- Health Canada Change added xmlns:gc-->

<!-- HPFB Changes:
Created a HPFB Variant as there are simply to many small changes 
to try to maintain a single code base, the main reason for this is that the 
labels are not extracted but inline in the code 
-->
<xsl:transform version="1.0"
							 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
							 xmlns:v3="urn:hl7-org:v3"
							 xmlns:v="http://validator.pragmaticdata.com/result"
							 xmlns:str="http://exslt.org/strings"
							 xmlns:exsl="http://exslt.org/common"
							 xmlns:msxsl="urn:schemas-microsoft-com:xslt"
							 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
							 xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
							 exclude-result-prefixes="exsl msxsl v3 xsl xsi str v">
	<xsl:import href="xml-verbatim.xsl"/>
	<xsl:import href="mixin.xsl"/>
	<xsl:import href="substance.xsl"/>
	<xsl:import href="epa.xsl"/>
	<xsl:param name="show-subjects-xml" select="1"/>
	<xsl:param name="show-data" select="/.."/>
	<xsl:param name="show-section-numbers" select="/.."/>
	<xsl:param name="update-check-url-base" select="/.."/>
	<xsl:param name="standardSections" select="document('plr-sections.xml')/*"/>
	<xsl:param name="itemCodeSystems" select="document('item-code-systems.xml')/*"/>
	<xsl:param name="disclaimers" select="document('disclaimers.xml')/*"/>
	<xsl:param name="documentTypes" select="document('doc-types.xml')/*"/>
	<xsl:param name="indexingDocumentTypes" select="document('indexing-doc-types.xml')/*"/>
	<xsl:param name="root" select="/"/>
	<xsl:param name="css" select="'./spl.css'"/>
	<xsl:param name="process-mixins" select="/.."/>
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="no" doctype-public="-"/>
	<xsl:strip-space elements="*"/>
	<!-- The indication secction variable contains the actual Indication Section node-->
	<xsl:variable name="indicationSection" select="/v3:document/v3:component/v3:structuredBody/v3:component//v3:section [v3:code [descendant-or-self::* [(self::v3:code or self::v3:translation) and @codeSystem='2.16.840.1.113883.6.1' and @code='34067-9'] ] ]"/>
	<xsl:variable name="indicationSectionCode">34067-9</xsl:variable>
	<xsl:variable name="dosageAndAdministrationSectionCode">34068-7</xsl:variable>
	<xsl:variable name="PEST_STAGE">
		<code code="P0001" displayName="Adults"/>
		<code code="P0002" displayName="Eggs"/>
		<code code="P0003" displayName="Larva"/>
		<code code="P0004" displayName="Not specified"/>
		<code code="P0005" displayName="Pre-conception"/>
		<code code="P0006" displayName="Spores"/>
	</xsl:variable>
	<xsl:variable name="PESTICIDE_ACTION">
		<code code="PA0001" displayName="Attracts"/>
		<code code="PA0002" displayName="Defoliates"/>
		<code code="PA0003" displayName="Disinfects"/>
		<code code="PA0004" displayName="Disrupts"/>
		<code code="PA0005" displayName="Dries"/>
		<code code="PA0006" displayName="Inactivates"/>
		<code code="PA0007" displayName="Inhibits growth"/>
		<code code="PA0008" displayName="Kills"/>
		<code code="PA0009" displayName="Prevents"/>
		<code code="PA0010" displayName="Reduces"/>
		<code code="PA0011" displayName="Regulates"/>
		<code code="PA0012" displayName="Repels"/>
		<code code="PA0013" displayName="Sterilizes"/>
	</xsl:variable>
	<xsl:variable name="remsActivity">
		<code code="C0P00" displayName="REMS program"/>
		<code code="C0P01" displayName="all activity"/>
		<code code="C0P02" displayName="overall treatment"/>
		<code code="C0P03" displayName="prescription"/>
		<code code="C0P04" displayName="dispensing"/>
		<code code="C0P05" displayName="administration"/>
		<code code="C0P06" displayName="continuation"/>
	</xsl:variable>
	<xsl:variable name="EPA_Equivalence">
		<code code="C0001" displayName="Identical"/>
		<code code="C0002" displayName="No Equivalence"/>
		<code code="C0003" displayName="Repack"/>
		<code code="C0004" displayName="Substantially Similar"/>
	</xsl:variable>
	<xsl:variable name="ucumList">
		<unitsMapping>
			<unit UCUM="s" singular="second" plural="seconds"/>
			<unit UCUM="min" singular="minute" plural="minutes"/>
			<unit UCUM="h" singular="hour" plural="hours"/>
			<unit UCUM="d" singular="day" plural="days"/>
			<unit UCUM="wk" singular="week" plural="weeks"/>
			<unit UCUM="mo" singular="month" plural="months"/>
			<unit UCUM="a" singular="year" plural="years"/>
		</unitsMapping>
	</xsl:variable>
	<xsl:variable name="maxStdSectionNumber">
		<xsl:call-template name="max">
			<xsl:with-param name="sequence" select="$standardSections/v3:section[@code = $root/v3:document/v3:component/v3:structuredBody/v3:component/v3:section/v3:code/@code]/@number[. &lt;= 17]" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="maxSection17" select="$standardSections/v3:section[@number = $maxStdSectionNumber]" />
	<xsl:variable name="drugNotificationList">
		<code code="C121834" displayName="Counterfeit"/>
		<code code="C121835" displayName="Diverted"/>
		<code code="C121836" displayName="Stolen"/>
		<code code="C121837" displayName="Intentional adulteration"/>
		<code code="C121838" displayName="Unfit for distribution"/>
		<code code="C121839" displayName="Fraudulent transaction"/>
	</xsl:variable>
	<xsl:variable name="drugUseList">
		<code code="C121840" displayName="Human use"/>
		<code code="C121841" displayName="Other"/>
	</xsl:variable>
	<xsl:variable name="companyCategoryList">
		<code code="CC0001" displayName="Manufacturer"/>
		<code code="CC0002" displayName="Wholsale distributor"/>
		<code code="CC0003" displayName="Dispenser (Pharmacy)"/>
		<code code="CC0004" displayName="Repackager"/>
	</xsl:variable>
	<xsl:variable name="indicationSection1" select="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section/v3:subject/v3:manufacturedProduct/v3:manufacturedProduct/v3:instanceOfKind/v3:productInstance/v3:ingredient/v3:subjectOf"/>
	<xsl:variable name="indicationSection2" select="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section/v3:subject/v3:manufacturedProduct/v3:manufacturedProduct"/>
	<!--  HPFB: Change added all variables below -->
	<xsl:variable name="scheduling-symbol-oid" select="'2.16.840.1.113883.2.20.6.2'"/>
	<xsl:variable name="dosage-form-oid" select="'2.16.840.1.113883.2.20.6.3'"/>
	<xsl:variable name="telecom-use-oid" select="'2.16.840.1.113883.2.20.6.4'"/>
	<xsl:variable name="pharmaceutical-standard-oid" select="'2.16.840.1.113883.2.20.6.5'"/>
	<xsl:variable name="therapeutic-class-oid" select="'2.16.840.1.113883.2.20.6.6'"/>
	<xsl:variable name="route-of-administration-oid" select="'2.16.840.1.113883.2.20.6.7'"/>
	<xsl:variable name="section-id-oid" select="'2.16.840.1.113883.2.20.6.8'"/>
	<xsl:variable name="template-id-oid" select="'2.16.840.1.113883.2.20.6.9'"/>
	<xsl:variable name="document-id-oid" select="'2.16.840.1.113883.2.20.6.10'"/>
	<xsl:variable name="marketing-category-oid" select="'2.16.840.1.113883.2.20.6.11'"/>
	<xsl:variable name="equivalence-codes-oid" select="'2.16.840.1.113883.2.20.6.12'"/>
	<xsl:variable name="identifier-type-oid" select="'2.16.840.1.113883.2.20.6.13'"/>
	<xsl:variable name="ingredient-id-oid" select="'2.16.840.1.113883.2.20.6.14'"/>
	<xsl:variable name="units-of-measure-oid" select="'2.16.840.1.113883.2.20.6.15'"/>
	<xsl:variable name="form-code-oid" select="'2.16.840.1.113883.2.20.6.16'"/>
	<xsl:variable name="country-code-oid" select="'2.16.840.1.113883.2.20.6.17'"/>
	<xsl:variable name="marketing-status-oid" select="'2.16.840.1.113883.2.20.6.18'"/>
	<xsl:variable name="telecom-capability-oid" select="'2.16.840.1.113883.2.20.6.19'"/>
	<xsl:variable name="product-item-code-oid" select="'2.16.840.1.113883.2.20.6.20'"/>
	<xsl:variable name="information-disclosure-oid" select="'2.16.840.1.113883.2.20.6.21'"/>
	<xsl:variable name="schedule-oid" select="'2.16.840.1.113883.2.20.6.22'"/>
	<xsl:variable name="product-characteristics-oid" select="'2.16.840.1.113883.2.20.6.23'"/>
	<xsl:variable name="color-oid" select="'2.16.840.1.113883.2.20.6.24'"/>
	<xsl:variable name="shape-oid" select="'2.16.840.1.113883.2.20.6.25'"/>
	<xsl:variable name="flavor-oid" select="'2.16.840.1.113883.2.20.6.26'"/>
	<xsl:variable name="product-classification-oid" select="'2.16.840.1.113883.2.20.6.27'"/>
	<xsl:variable name="submission-tracking-system-oid" select="'2.16.840.1.113883.2.20.6.28'"/>
	<xsl:variable name="language-code-oid" select="'2.16.840.1.113883.2.20.6.29'"/>
	<xsl:variable name="combination-product-type-oid" select="'2.16.840.1.113883.2.20.6.30'"/>
	<xsl:variable name="company-id-oid" select="'2.16.840.1.113883.2.20.6.31'"/>
	<xsl:variable name="pack-type-oid" select="'2.16.840.1.113883.2.20.6.32'"/>
	<xsl:variable name="organization-role-oid" select="'2.16.840.1.113883.2.20.6.33'"/>
	<xsl:variable name="product-source-oid" select="'2.16.840.1.113883.2.20.6.34'"/>
	<xsl:variable name="derived-source-oid" select="'2.16.840.1.113883.2.20.6.35'"/>
	<xsl:variable name="structure-aspects-oid" select="'2.16.840.1.113883.2.20.6.36'"/>
	<xsl:variable name="term-status-oid" select="'2.16.840.1.113883.2.20.6.37'"/>
	<xsl:variable name="units-of-presentation-oid" select="'2.16.840.1.113883.2.20.6.38'"/>
	<xsl:variable name="ingredient-role-oid" select="'2.16.840.1.113883.2.20.6.39'"/>
	<xsl:variable name="notice-type-oid" select="'2.16.840.1.113883.2.20.6.40'"/>
	<xsl:variable name="related-documents-oid" select="'2.16.840.1.113883.2.20.6.41'"/>
	<xsl:variable name="din-oid" select="'2.16.840.1.113883.2.20.6.42'"/>
	<xsl:variable name="doctype" select="/v3:document/v3:code/@code" />
	<xsl:variable name="oid_loc" select="'https://raw.githubusercontent.com/HealthCanada/HPFB/master/Controlled-Vocabularies/Content/'"/>
	<xsl:variable name="file-prefix" select="'hpfb-'"/>
	<xsl:variable name="file-suffix" select="'.gc.xml'"/>
	<xsl:variable name="codeLookup" select="document(concat($oid_loc,$file-prefix,$structure-aspects-oid,$file-suffix))"/>
	
	<!-- pbx: for testng hard code language to eng, later read from docuemnt and convert to lowercase -->
	<xsl:variable name="doc_language" select="'eng'"/>
	<xsl:variable name="display_language" select="concat('name-',$doc_language)"/>
	
	
	<!-- Process mixins if they exist -->
	<xsl:template match="/" priority="1">

		<xsl:choose>
			<xsl:when test="boolean($process-mixins) and *[v3:relatedDocument[@typeCode='APND' and v3:relatedDocument[v3:id/@root or v3:setId/@root]]]">
				<xsl:variable name="mixinRtf">
					<xsl:apply-templates mode="mixin" select="."/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="function-available('exsl:node-set')">
						<xsl:apply-templates select="exsl:node-set($mixinRtf)/*"/>
					</xsl:when>
					<xsl:when test="function-available('msxsl:node-set')">
						<xsl:apply-templates select="msxsl:node-set($mixinRtf)/*"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- XSLT 2 would be thus: xsl:apply-templates select="$mixinRtf/*"/ -->
						<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not(/v3:document/v3:code/@code = '77289-7|user-profile')">
					<xsl:if test="not(/v3:document/v3:code/@code = 'XXXXX-2')">
						<xsl:apply-templates select="*"/>
					</xsl:if>
					<xsl:if test="/v3:document/v3:code/@code = 'XXXXX-2'">
						<xsl:apply-templates mode="EPA" select="/v3:document"/>
					</xsl:if>
				</xsl:if>
				<xsl:if test="/v3:document/v3:code/@code = '77289-7'">
					<xsl:apply-templates mode="form3911" select="/v3:document"/>
				</xsl:if>
				 <xsl:apply-templates mode="user-management" select="/v3:document[v3:code/@code = 'user-profile']"/>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Health Canada rendering the whole XML doc MAIN MODE based on the deep null-transform -->
	<xsl:template match="@*|node()">

			<xsl:apply-templates select="*"/>

	</xsl:template>





	<!-- GS: the document title should not be processed in normal mode.
			 This is really should be revisited when the top-level template gets refactored. -->
	<xsl:template match="/v3:document/v3:title" priority="1"/>

	<xsl:template mode="form3911" match="/v3:document">
		<!-- GS: this template needs thorough refactoring -->
		<html>
			<head>
				<meta name="documentId" content="{/v3:document/v3:id/@root}"/>
				<meta name="documentSetId" content="{/v3:document/v3:setId/@root}"/>
				<meta name="documentVersionNumber" content="{/v3:document/v3:versionNumber/@value}"/>
				<meta name="documentEffectiveTime" content="{/v3:document/v3:effectiveTime/@value}"/>
				<title><!-- GS: this isn't right because the title can have markup -->
					<xsl:value-of select="v3:title"/>
				</title>
				<link rel="stylesheet" type="text/css" href="{$css}"/>
			</head>

		</html>
	</xsl:template>
	<xsl:template match="/v3:document">
		<!-- GS: this template needs thorough refactoring -->
		<html>
			<head>
				<meta name="documentId" content="{/v3:document/v3:id/@root}"/>
				<meta name="documentSetId" content="{/v3:document/v3:setId/@root}"/>
				<meta name="documentVersionNumber" content="{/v3:document/v3:versionNumber/@value}"/>
				<meta name="documentEffectiveTime" content="{/v3:document/v3:effectiveTime/@value}"/>
				<title><!-- GS: this isn't right because the title can have markup -->
					<xsl:value-of select="v3:title"/>
				</title>
				<link rel="stylesheet" type="text/css" href="{$css}"/>
				<xsl:call-template name="include-custom-items"/>
				<xsl:if test="boolean($show-subjects-xml)">
					<xsl:call-template name="xml-verbatim-setup"/>
				</xsl:if>
			</head>
			<body class="spl" id="spl">
				<xsl:attribute name="onload"><xsl:text>if(typeof convertToTwoColumns == "function")convertToTwoColumns();</xsl:text></xsl:attribute>
				<xsl:apply-templates mode="title" select="."/>
				<xsl:choose>
					<xsl:when test="//v3:excerpt/v3:highlight">
						<xsl:variable name="highlightsRtf">
							<xsl:apply-templates mode="highlights" select="."/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="function-available('exsl:node-set')">
								<xsl:apply-templates mode="twocolumn" select="exsl:node-set($highlightsRtf)">
									<xsl:with-param name="class">Highlights</xsl:with-param>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="function-available('msxsl:node-set')">
								<xsl:apply-templates mode="twocolumn" select="msxsl:node-set($highlightsRtf)">
									<xsl:with-param name="class">Highlights</xsl:with-param>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
						<!-- Generate the Table of Contents only if the SPL is PLR. -->
						<xsl:variable name="indexRtf">
							<xsl:apply-templates mode="index" select="."/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="function-available('exsl:node-set')">
								<xsl:apply-templates mode="twocolumn" select="exsl:node-set($indexRtf)">
									<xsl:with-param name="class">Index</xsl:with-param>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="function-available('msxsl:node-set')">
								<xsl:apply-templates mode="twocolumn" select="msxsl:node-set($indexRtf)">
									<xsl:with-param name="class">Index</xsl:with-param>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<h1 id="H1ID"><xsl:apply-templates mode="mixed" select="v3:title"/></h1>
					</xsl:otherwise>
				</xsl:choose>

				<div class="Contents">
					<xsl:if test="//v3:excerpt/v3:highlight">
						<h1>FULL PRESCRIBING INFORMATION</h1>
					</xsl:if>
					<xsl:apply-templates select="@*|node()[not(self::v3:relatedDocument[@typeCode = 'DRIV' or @typeCode = 'RPLC'])]"/>
				</div>

				<xsl:if test="boolean($show-data)">
					<div class="DataElementsTable">
						<!-- HPFB: pbx: re-enabled the Product Data aspect --> 
							<xsl:call-template name="PLRIndications"/>

						<xsl:if test="//v3:*[self::v3:ingredientSubstance[starts-with(../@classCode,'ACTI')] or self::v3:identifiedSubstance[not($root/v3:document/v3:code/@code = '64124-1')]]">
							<xsl:call-template name="PharmacologicalClass"/>
						</xsl:if>
						<xsl:apply-templates mode="subjects" select="//v3:section/v3:subject/*[self::v3:manufacturedProduct or self::v3:identifiedSubstance]"/>
						<xsl:if test="$root/v3:document/v3:code/@code = '75031-5'">
							<xsl:apply-templates mode="subjects" select="v3:component/v3:structuredBody/v3:component/v3:section[v3:code/@code ='48780-1' and not(v3:subject/v3:manufacturedProduct)]"/>
						</xsl:if>
						<xsl:apply-templates mode="subjects" select="v3:author/v3:assignedEntity/v3:representedOrganization"/>
						<xsl:apply-templates mode="subjects" select="v3:author/v3:assignedEntity/v3:representedOrganization/v3:assignedEntity/v3:assignedOrganization"/>
						<xsl:apply-templates mode="subjects" select="v3:author/v3:assignedEntity/v3:representedOrganization/v3:assignedEntity/v3:assignedOrganization/v3:assignedEntity/v3:assignedOrganization"/>
					<!-- End of comment-->
					</div>
				</xsl:if>
				<xsl:apply-templates select="v3:relatedDocument[/v3:document/v3:code[@code = 'X9999-4']][@typeCode = 'RPLC']"/>
				<p>
					<xsl:call-template name="effectiveDate"/>
					<xsl:text>&#160;</xsl:text>
					<xsl:call-template name="distributorName"/>
				</p>

				<xsl:if test="boolean($show-subjects-xml)">
					<hr/>
					<div class="Subject" onclick="xmlVerbatimClick(event);" ondblclick="xmlVerbatimDblClick(event);">
						<xsl:apply-templates mode="xml-verbatim" select="node()"/>
					</div>
				</xsl:if>
			</body>
		</html>
	</xsl:template>
	<!--For REMS -->
	<xsl:template match="v3:relatedDocument[/v3:document/v3:code[@code = 'X9999-4']][@typeCode = 'XCRPT']">
		<b>
			<xsl:text>Related Label Set Id: </xsl:text>
			<a href="{concat('../', ., '.view')}"><xsl:value-of select="v3:relatedDocument/v3:setId/@root"/></a>
		</b>
	</xsl:template>
	<!--INDEXING - PESTICIDE RESIDUE TOLERANCE Start -->
	<xsl:template match="v3:subject[v3:identifiedSubstance][/v3:document/v3:code/@code = '3565717']">
			<table class="contentTablePetite" cellSpacing="0" cellPadding="3" width="100%">
				<tr>
					<td class="formHeadingTitle">
						<xsl:value-of select="v3:identifiedSubstance/v3:identifiedSubstance/v3:name"/>
						<xsl:text>(</xsl:text>
							<xsl:value-of select="v3:identifiedSubstance/v3:identifiedSubstance/v3:code/@code"/>
						<xsl:text>)</xsl:text>
					</td>
				</tr>
				<tr>
					<td>
						<table class="contentTablePetite" cellSpacing="0" cellPadding="3" width="100%">
							<tr>
								<td>
									<table width="100%" cellpadding="5" cellspacing="0" class="formTablePetite">
											<xsl:apply-templates mode="substance" select="v3:identifiedSubstance/v3:identifiedSubstance/v3:asNamedEntity"/>
									</table>
								</td>
							</tr>
							<tr>
								<td>
									<table width="100%" cellpadding="5" cellspacing="0" class="formTablePetite">

										<tr>
											<td colspan="2" class="formHeadingTitle">
												<xsl:text>Environmental Residue Observation - </xsl:text>
												<xsl:value-of select="v3:identifiedSubstance/v3:subjectOf/v3:substanceSpecification/v3:component/v3:observation/v3:code/@displayName"/>
												<xsl:text>(</xsl:text>
													<xsl:value-of select="v3:identifiedSubstance/v3:subjectOf/v3:substanceSpecification/v3:component/v3:observation/v3:code/@code"/>
												<xsl:text>)</xsl:text>
											</td>
										</tr>
										<xsl:apply-templates select="v3:identifiedSubstance/v3:subjectOf/v3:substanceSpecification/v3:component/v3:observation/v3:analyte[position() mod 2 = 1]" mode="twoColumn"/>
									</table>
								</td>
							</tr>
							<tr>
								<td>
									<table width="100%" cellpadding="5" cellspacing="0" class="formTablePetite">
										<tr>
											<th class="formTitle" scope="col">Commodity</th>
											<th class="formTitle" scope="col">Tolerance value</th>
											<th class="formTitle" scope="col">Application Type</th>
											<th class="formTitle" scope="col">Expiration/Revocation date</th>
											<th class="formTitle" scope="col">Annotation/Comment</th>
										</tr>
										<xsl:apply-templates select="v3:identifiedSubstance/v3:subjectOf/v3:substanceSpecification/v3:component/v3:observation/v3:referenceRange/v3:observationCriterion"/>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
	</xsl:template>
	<xsl:template match="v3:observationCriterion">
			<tr>
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
						<xsl:otherwise>formTableRowAlt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<td class="formItem">
					<xsl:value-of select="v3:subject/v3:presentSubstance/v3:presentSubstance/v3:code/@displayName"/>
				</td>
				<td class="formItem">
					<xsl:value-of select="v3:value/v3:high/@value"/>
				</td>
				<td class="formItem">
					<xsl:value-of select="v3:subjectOf/v3:approval/v3:code/@displayName"/>
				</td>
				<td class="formItem">
					<xsl:value-of select="v3:subjectOf/v3:approval/v3:effectiveTime/v3:high/@value"/>
				</td>
				<td class="formItem">
					<xsl:value-of select="v3:subjectOf/v3:approval/v3:text"/>
				</td>
			</tr>
	</xsl:template>
	<xsl:template mode="twoColumn" match="v3:analyte">
		<tr>
			<xsl:if test="position() = 1">
				<td class="formTitle" colspan="2">Substance Measured</td>
			</xsl:if>
		</tr>
		<tr>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="position() mod 2 = 1">formTableRow</xsl:when>
					<xsl:otherwise>formTableRowAlt</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="."></xsl:apply-templates>
			<xsl:apply-templates select="following-sibling::v3:analyte[1]"></xsl:apply-templates>
		</tr>
	</xsl:template>
	<xsl:template match="v3:analyte">
		<xsl:if test="v3:identifiedSubstance/v3:identifiedSubstance/v3:name/text()[string-length(.) > 0]">
			<td class="formItem" style="width: 50%;">
				<xsl:value-of select="v3:identifiedSubstance/v3:identifiedSubstance/v3:name/text()"/>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="v3:identifiedSubstance/v3:identifiedSubstance/v3:code/@code"/>
				<xsl:text>)</xsl:text>
			</td>
		</xsl:if>
	</xsl:template>
	<!--INDEXING - PESTICIDE RESIDUE TOLERANCE End -->
	<!-- Pesticide Labeling Start-->
	<xsl:template match="v3:subject/v3:manufacturedProduct/v3:manufacturedProduct[/v3:document/v3:code/@code = '3565715'] | v3:subject/v3:substanceAdministration1[/v3:document/v3:code/@code = '3565715']">
		<table class="contentTablePetite" cellSpacing="0" cellPadding="3" width="100%">
			<xsl:if test="../../../v3:code/@code = '3144190'">
			    <tr>
					<td>
						<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
							<tr>
								<th class="formTitle">Information</th>
								<th class="formTitle">Value</th>
							</tr>
							<tr>
								<td class="formItem">EPA Registration No.</td>
								<td class="formItem">
									<xsl:value-of select="v3:code/@code"/>
								</td>
							</tr>
							<tr>
								<td class="formItem">Primary Brand Name</td>
								<td class="formItem">
									<xsl:value-of select="v3:name"/>
								</td>
							</tr>
							<tr>
								<td class="formItem">Alternate Brand Name</td>
								<td class="formItem">
									<xsl:value-of select="v3:asNamedEntity/v3:name"/>
								</td>
							</tr>
							<tr>
								<td class="formItem">Pesticide Classification</td>
								<td class="formItem">
									<xsl:for-each select="v3:asSpecializedKind/v3:generalizedMaterialKind/v3:code[@codeSystem='2.16.840.1.113883.6.303']">
										<xsl:value-of select="@displayName"/>
										<xsl:if test="position()!=last()"> , </xsl:if>
									</xsl:for-each>
								</td>
							</tr>
							<tr>
								<td class="formItem">Form as Packaged</td>
								<td class="formItem">
									<xsl:value-of select="v3:formCode/@displayName"/>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="../../../v3:code/@code = '3144244'">
				<tr>
					<td>
						<table width="100%" class="formTablePetite">
							<tr>
								<th scope="col" class="formTitle">Container Types</th>
							</tr>
							<tr class="formTableRowAlt">
								<td class="formItem">
									<xsl:value-of select="v3:asContent/v3:containerPackagedProduct/v3:formCode/@displayName"/>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="../../../v3:code/@code = 'X9136-6'">
				<tr>
					<td>
						<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
							<tr>
								<th class="formTitle">Information</th>
								<th class="formTitle">Value</th>
							</tr>
							<tr>
								<td class="formItem">Signal Word</td>
								<td class="formItem">
									<xsl:value-of select="v3:asSpecializedKind/v3:generalizedMaterialKind/v3:code/@displayName"/>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="../../../v3:code/@code = '3144198'">
				<tr>
					<td>
						<table width="100%" class="formTablePetite">
							<tr>
								<th scope="col" class="formTitle">Ingredient Type</th>
								<th scope="col" class="formTitle">Name and Code</th>
							</tr>
							<xsl:for-each select="v3:ingredient[@classCode='ACTIM']">
								<tr>
									<td class="formItem">Active</td>
									<td class="formItem"><xsl:value-of select="v3:ingredientSubstance/v3:name"/>
										(<xsl:value-of select="v3:ingredientSubstance/v3:code/@code"/>)
									</td>
								</tr>
							</xsl:for-each>
						</table>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="../../../v3:code/@code = '3144195'">
				<tr>
					<td>
						<table width="100%" class="formTablePetite">
							<tr>
								<th scope="col" class="formTitle">Seal and Certification Name</th>
								<th scope="col" class="formTitle">Text Description</th>
							</tr>
							<xsl:for-each select="../v3:subjectOf/v3:approval[v3:code/v3:originalText]">
								<tr>
									<td class="formItem"><xsl:value-of select="v3:code/@displayName"/></td>
									<td class="formItem"><xsl:value-of select="v3:code/v3:originalText"/></td>
								</tr>
							</xsl:for-each>
						</table>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="../../../v3:code/@code = '3144210'">
				<tr>
					<td>
						<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
							<tr>
								<th class="formTitle">Information</th>
								<th class="formTitle">Value</th>
							</tr>
							<tr>
								<td class="formItem">Environmental Hazards</td>
								<td class="formItem">
									<xsl:for-each select="../v3:consumedIn/v3:substanceAdministration1/v3:subjectOf/v3:issue">
										<xsl:value-of select="v3:code/@displayName"/>
										<xsl:if test="position()!=last()"> , </xsl:if>
									</xsl:for-each>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="../../v3:code/@code = '3144234'">
				<tr>
					<td>
						<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
							<tr>
								<th class="formTitle">Use Site</th>
								<th class="formTitle">Location</th>
							</tr>
							<xsl:for-each select="v3:participation[@typeCode='SBJ']/v3:role">
								<tr>
									<td class="formItem"><xsl:value-of select="v3:player/v3:name"/></td>
									<td class="formItem"><xsl:value-of select="v3:scoper/v3:code/@code"/></td>
								</tr>
							</xsl:for-each>
						</table>
					</td>
				</tr>
				<br/>
				<tr>
					<td>
						<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
							<tr>
								<th class="formTitle">Pest</th>
								<th class="formTitle">Stage</th>
								<th class="formTitle">Action</th>
							</tr>
							<xsl:for-each select="v3:outboundRelationship[@typeCode='OBJT']/v3:targetAct/v3:participation[@typeCode='SBJ']">
								<tr>
									<td class="formItem"><xsl:value-of select="v3:role/v3:player/v3:name"/></td>
									<td class="formItem">
										<xsl:choose>
											<xsl:when test="function-available('exsl:node-set')">
												<xsl:value-of select="exsl:node-set($PEST_STAGE)/code[@code = current()/v3:role/v3:subjectOf/v3:characteristic/v3:value/@code]/@displayName"/>
											</xsl:when>
											<xsl:when test="function-available('msxsl:node-set')">
												<xsl:value-of select="msxsl:node-set($PEST_STAGE)/code[@code = current()/v3:role/v3:subjectOf/v3:characteristic/v3:value/@code]/@displayName"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
											</xsl:otherwise>
										</xsl:choose>
									</td>
									<td class="formItem">
										<xsl:choose>
											<xsl:when test="function-available('exsl:node-set')">
												<xsl:value-of select="exsl:node-set($PESTICIDE_ACTION)/code[@code = current()/../v3:code/@code]/@displayName"/>
											</xsl:when>
											<xsl:when test="function-available('msxsl:node-set')">
												<xsl:value-of select="msxsl:node-set($PESTICIDE_ACTION)/code[@code = current()/../v3:code/@code]/@displayName"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</tr>
							</xsl:for-each>
						</table>
					</td>
				</tr>
			</xsl:if>
		</table>
	</xsl:template>
	<!-- Pesticide Labeling End-->
	<!-- REMS templates start -->
	<xsl:template match="v3:subject2[v3:substanceAdministration/v3:subjectOf/v3:issue]">
		<xsl:if test="count(//v3:issue[v3:subject[v3:substanceAdministrationCriterion]]) > 0 or count(//v3:issue[not(v3:subject) and v3:risk]) > 0">
			<table class="contentTablePetite" cellSpacing="0" cellPadding="3" width="100%">
				<tbody>
					<tr>
						<td class="contentTableTitle">Interactions and Adverse Reactions</td>
					</tr>
					<tr class="formTableRowAlt">
						<td class="formItem">
							<table class="formTablePetite" cellSpacing="0" cellPadding="3" width="100%">
								<tbody>
									<tr>
										<td class="formTitle" colSpan="4">INTERACTIONS</td>
									</tr>
									<tr>
										<td class="formTitle">Contributing Factor</td>
										<td class="formTitle">Type of Consequence</td>
										<td class="formTitle">Consequence</td>
										<td class="formTitle">Labeling Section</td>
									</tr>
									<!-- only select those issues that have the proper interactions code of 'C54708' -->
									<!-- all others will be placed in a table with a title "UN-CODED INTERACTIONS OR ADVERSE REACTIONS" -->
									<xsl:apply-templates mode="interactions" select="//v3:issue[v3:code/@code = 'C54708']"/>
								</tbody>
							</table>
						</td>
					</tr>
					<tr class="formTableRowAlt">
						<td class="formItem">
							<table class="formTablePetite" cellSpacing="0" cellPadding="3" width="100%">
								<tbody>
									<tr>
										<td class="formTitle" colSpan="4">ADVERSE REACTIONS</td>
									</tr>
									<tr>
										<td class="formTitle">Type of Consequence</td>
										<td class="formTitle">Consequence</td>
										<td class="formTitle">Labeling Section</td>
									</tr>
									<!-- only select those issues that have the proper adverse reactions code of 'C41332' -->
									<!-- all others will be placed in a table with a title "UN-CODED INTERACTIONS OR ADVERSE REACTIONS" -->
									<xsl:apply-templates mode="adverseReactions" select="//v3:issue[v3:code/@code = 'C41332']"/>
								</tbody>
							</table>
						</td>
					</tr>
					<tr class="formTableRowAlt">
						<td class="formItem">
							<table class="formTablePetite" cellSpacing="0" cellPadding="3" width="100%">
								<tbody>
									<tr>
										<td class="formTitle" colSpan="4">UN-CODED INTERACTIONS OR ADVERSE REACTIONS</td>
									</tr>
									<tr>
										<td class="formTitle">Name</td>
										<td class="formTitle">Type of Consequence</td>
										<td class="formTitle">Consequence</td>
										<td class="formTitle">Labeling Section</td>
									</tr>
									<!-- apply the interaction sections that are improperly coded -->
									<xsl:apply-templates mode="otherInteraction" select="//v3:issue[v3:code/@code != 'C54708' and v3:code/@code != 'C41332']"/>
									<!-- apply the adverse reaction sections that are imprperly code -->
								</tbody>
							</table>
						</td>
					</tr>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<xsl:template mode="rems" match="v3:subject2[v3:substanceAdministration/v3:componentOf/v3:protocol and not(preceding-sibling::v3:subject2)]">
		<xsl:for-each select="ancestor::v3:component[1]/v3:section">
			<table class="formTablePetite" width="100%" cellpadding="3" cellspacing="0" style="border:solid 1px;text-align: left;">
				<tbody>
					<tr style="border:solid 1px;">
						<th scope="col" class="formTitle">Before/During/After</th>
						<th scope="col" class="formTitle">Activity</th>
						<th scope="col" class="formTitle">Stakeholder</th>
						<th scope="col" class="formTitle">Requirement</th>
						<th scope="col" class="formTitle">Document</th>
					</tr>
					<xsl:apply-templates mode="remsDisplay" select="v3:subject2/v3:substanceAdministration/v3:componentOf/v3:protocol/v3:component"/>
				</tbody>
			</table>
		</xsl:for-each>
	</xsl:template>
	<xsl:template mode="remsDisplay" match="v3:component">
		<tr style="border:solid 1px;">
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
					<xsl:otherwise>formTableRowAlt</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<td class="formItem">
				<xsl:choose>
					<xsl:when test="number(v3:sequenceNumber/@value) &lt; number(ancestor::v3:componentOf[1]/v3:sequenceNumber/@value)">before</xsl:when>
					<xsl:when test="v3:sequenceNumber/@value = ancestor::v3:componentOf[1]/v3:sequenceNumber/@value">
						<xsl:if test="v3:requirement/v3:effectiveTime/v3:period|v3:monitoringObservation/v3:effectiveTime/v3:period">
							<xsl:text> </xsl:text>
							<xsl:text>every</xsl:text>
							<xsl:text> </xsl:text>
							<xsl:value-of select="v3:requirement/v3:effectiveTime/v3:period/@value|v3:monitoringObservation/v3:effectiveTime/v3:period/@value"/>
							<xsl:text> </xsl:text>
							<xsl:call-template name="get-ucum-unit-text">
								<xsl:with-param name="ucum" select="v3:requirement/v3:effectiveTime/v3:period|v3:monitoringObservation/v3:effectiveTime/v3:period"/>
							</xsl:call-template>
							<xsl:text> </xsl:text>
						</xsl:if>
						<xsl:text>during</xsl:text>
						<xsl:if test="v3:pauseQuantity/@value">,
							<xsl:text> </xsl:text>
							<xsl:value-of select="v3:pauseQuantity/@value"/>
							<xsl:text> </xsl:text>
							<xsl:call-template name="get-ucum-unit-text">
								<xsl:with-param name="ucum" select="v3:pauseQuantity" />
							</xsl:call-template>
							<xsl:text> after start of </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="number(v3:sequenceNumber/@value) > number(ancestor::v3:componentOf[1]/v3:sequenceNumber/@value)">
						<xsl:value-of select="v3:pauseQuantity/@value"/>
						<xsl:text> </xsl:text>
						<xsl:call-template name="get-ucum-unit-text">
							<xsl:with-param name="ucum" select="v3:pauseQuantity" />
						</xsl:call-template>
						<xsl:text> </xsl:text>
						<xsl:text>after</xsl:text>
					</xsl:when>
				</xsl:choose>
			</td >
			<td class="formItem">
				<xsl:choose>
					<xsl:when test="function-available('exsl:node-set')">
						<xsl:value-of select="exsl:node-set($remsActivity)/code[@code = current()/ancestor::v3:componentOf[1]/v3:protocol/v3:code/@code]/@displayName"/>
					</xsl:when>
					<xsl:when test="function-available('msxsl:node-set')">
						<xsl:value-of select="msxsl:node-set($remsActivity)/code[@code = current()/ancestor::v3:componentOf[1]/v3:protocol/v3:code/@code]/@displayName"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td class="formItem">
				<xsl:for-each select="v3:requirement/v3:participation[@typeCode='PPRF'] | v3:monitoringObservation/v3:participation[@typeCode='PPRF'] ">
					<xsl:value-of select="v3:stakeholder/v3:code/@displayName|v3:stakeholder/v3:code/@displayName"/>
					<xsl:if test="position()!=last()"> , </xsl:if>
				</xsl:for-each>
			</td>
			<td class="formItem">
				<xsl:if test="v3:requirement">
					<xsl:variable name="referencedValue" select="v3:requirement/v3:code/v3:originalText/v3:reference/@value"/>
					<a>
						<xsl:attribute name="href">
							<xsl:value-of select="$referencedValue"/>
						</xsl:attribute>
						<xsl:attribute name="title">
							<xsl:for-each select="/v3:document//v3:content[@ID]">
								<xsl:variable name="contentId" select="@ID"/>
								<xsl:variable name="contentID" select="concat('#',$contentId)"/>
								<xsl:if test=" $contentID = $referencedValue ">
									<xsl:value-of select="text()"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:attribute>
						<xsl:value-of select="v3:requirement/v3:code/@displayName"/>
					</a>
				</xsl:if>
				<xsl:if test="v3:monitoringObservation">
					<xsl:variable name="referencedValue" select="v3:monitoringObservation/v3:code/v3:originalText/v3:reference/@value"/>
					<a>
						<xsl:attribute name="href">
							<xsl:value-of select="$referencedValue"/>
						</xsl:attribute>
						<xsl:attribute name="title">
							<xsl:for-each select="/v3:document//v3:content[@ID]">
								<xsl:variable name="contentId" select="@ID"/>
								<xsl:variable name="contentID" select="concat('#',$contentId)"/>
								<xsl:if test=" $contentID = $referencedValue ">
									<xsl:value-of select="text()"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:attribute>
						<xsl:text>Monitor </xsl:text>
						<xsl:value-of select="v3:monitoringObservation/v3:code/@displayName"/>
					</a>
				</xsl:if>
			</td>
			<td class="formItem">
				<xsl:for-each select="v3:requirement/v3:subject/v3:documentReference|v3:monitoringObservation/v3:subject/v3:documentReference">
					<xsl:variable name="referencedDocument" select="/v3:document//v3:manufacturedProduct/v3:subjectOf/v3:document[v3:id/@root=current()/v3:id/@root]"/>
					<a>
						<xsl:attribute name="href">
							<xsl:choose>
								<xsl:when test="function-available('exsl:node-set')">
									<xsl:value-of select="exsl:node-set($referencedDocument)/v3:text/v3:reference/@value"/>
								</xsl:when>
								<xsl:when test="function-available('msxsl:node-set')">
									<xsl:value-of select="msxsl:node-set($referencedDocument)/v3:text/v3:reference/@value"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:choose>
							<xsl:when test="function-available('exsl:node-set')">
								<xsl:value-of select="exsl:node-set($referencedDocument)/v3:title/text()"/>
								<xsl:if test="position()!=last()">, </xsl:if>
							</xsl:when>
							<xsl:when test="function-available('msxsl:node-set')">
								<xsl:value-of select="msxsl:node-set($referencedDocument)/v3:title/text()"/>
								<xsl:if test="position()!=last()">, </xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
					</a>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>
	<xsl:template name="get-ucum-unit-text">
		<xsl:param name="ucum"/>
		<xsl:choose>
			<xsl:when test="number($ucum/@value) = 1">
				<xsl:choose>
					<xsl:when test="function-available('exsl:node-set')">
						<xsl:value-of select="exsl:node-set($ucumList)/unitsMapping/unit[@UCUM = $ucum/@unit]/@singular"/>
					</xsl:when>
					<xsl:when test="function-available('msxsl:node-set')">
						<xsl:value-of select="msxsl:node-set($ucumList)/unitsMapping/unit[@UCUM = $ucum/@unit]/@singular"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="number($ucum/@value) &gt; 1">
				<xsl:choose>
					<xsl:when test="function-available('exsl:node-set')">
						<xsl:value-of select="exsl:node-set($ucumList)/unitsMapping/unit[@UCUM = $ucum/@unit]/@plural"/>
					</xsl:when>
					<xsl:when test="function-available('msxsl:node-set')">
						<xsl:value-of select="msxsl:node-set($ucumList)/unitsMapping/unit[@UCUM = $ucum/@unit]/@plural"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- REMS templates end -->
	<!-- helper templates -->
	<xsl:template priority="2" match="v3:highlight//@width[not(contains(.,'%'))]" /> <!-- This would avoid things moving out of 2-column view -->
	<xsl:template mode="twocolumn" match="/|node()|@*">
		<xsl:param name="class"/>
		<xsl:copy>
			<xsl:apply-templates mode="twocolumn" select="@*|node()">
				<xsl:with-param name="class" select="$class"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	<xsl:template name="include-custom-items">
		<script src="{$resourcesdir}spl.js" type="text/javascript" charset="utf-8">/* */</script>
	</xsl:template>

	<xsl:template name="string-lowercase">
		<!--** Convert the input text that is passed in as a parameter to lower case  -->
		<xsl:param name="text"/>
		<xsl:value-of select="translate($text,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
	</xsl:template>
	<xsl:template name="string-uppercase">
		<!--** Convert the input text that is passed in as a parameter to upper case  -->
		<xsl:param name="text"/>
		<xsl:value-of select="translate($text,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
	</xsl:template>
	<xsl:template name="printSeperator">
		<xsl:param name="lastDelimiter"><xsl:if test="last() > 2">,</xsl:if> and </xsl:param>
		<xsl:choose>
			<xsl:when test="position() = last() - 1"><xsl:value-of select="$lastDelimiter"/></xsl:when>
			<xsl:when test="position() &lt; last() - 1">, </xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="string-to-date">
		<xsl:param name="text"/>
		<xsl:param name="displayMonth">true</xsl:param>
		<xsl:param name="displayDay">true</xsl:param>
		<xsl:param name="displayYear">true</xsl:param>
		<xsl:param name="delimiter">/</xsl:param>
		<xsl:if test="string-length($text) > 7">
			<xsl:variable name="year" select="substring($text,1,4)"/>
			<xsl:variable name="month" select="substring($text,5,2)"/>
			<xsl:variable name="day" select="substring($text,7,2)"/>
			<!-- changed by Brian Suggs 11-13-05.  Changes made to display date in MM/DD/YYYY format instead of DD/MM/YYYY format -->
			<xsl:if test="$displayMonth = 'true'">
				<xsl:value-of select="$month"/>
				<xsl:value-of select="$delimiter"/>
			</xsl:if>
			<xsl:if test="$displayDay = 'true'">
				<xsl:value-of select="$day"/>
				<xsl:value-of select="$delimiter"/>
			</xsl:if>
			<xsl:if test="$displayYear = 'true'">
				<xsl:value-of select="$year"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template name="recent-effectiveDate">
		<xsl:param name="effectiveDateSequence" />
		<xsl:for-each select="$effectiveDateSequence[string-length(.) &gt; 7]">
			<xsl:sort select="." order="descending"/>
			<xsl:if test="position() = 1">
				<v3:effectiveTime value="{.}" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="max">
		<xsl:param name="sequence" />
		<xsl:for-each select="$sequence">
			<xsl:sort select="." data-type="number" order="descending" />
			<xsl:if test="position()=1">
				<xsl:value-of select="." />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template mode="format" match="*/v3:addr">
		<table>
			<tr><td>Address:</td><td><xsl:value-of select="./v3:streetAddressLine"/></td></tr>
			<tr><td>City, State, Zip:</td>
				<td>
					<xsl:value-of select="./v3:city"/>
					<xsl:if test="string-length(./v3:state)>0">,&#160;<xsl:value-of select="./v3:state"/></xsl:if>
					<xsl:if test="string-length(./v3:postalCode)>0">,&#160;<xsl:value-of select="./v3:postalCode"/></xsl:if>
				</td>
			</tr>
			<tr><td>Country:</td><td><xsl:value-of select="./v3:country"/></td></tr>
		</table>
	</xsl:template>

	<!-- MODE HIGHLIGHTS -->
	<!-- Requirements: there used to be a lot of content created from data, now that is less and more is just written.
			 certain rearrangements are still made. sequence:
			 - frontmatter (material that is before any section)
			 - highlights title: "HIGHLIGHTS OF PRESCRIBING INFORMATION" -> generated title
			 - highlights limitation statement: "these highlights do not ..." -> from document title (FIXME)
			 - highlights drug title: "Cifidipan for immersion in bathtub" -> from document title
			 - initial US approval year: "Initial U.S. Approval: 2099" -> from document title
			 - recent major changes -> pulled up from recent major changes section
			 - microbiology advisory "To reduce ... drug-resistant ..." -> microbiology highlight pulled up
			 - what gets pulled up into the frontmatter is determined by $standardSection/*[@highlightfrontmatter]
			 - boxed warning section (no title shown, and the box)
			 - all others (except frontmatter pull-up)
			 - backmatter
			 - BPCA pediatric advisory like microbiology but pulled last at the end of the highlights (after the revision date.)
			 - patient counseling information reference 34076-0 text based on what other sections are ther
			 * 38056-8 supplemental patient material
			 * 42231-1 medguide
			 * 42230-3 patient package insert
			 [reverse engineered requirements
			 - -42231-1 -38056-8 -42230-3 => See 17 for PATIENT COUNSELING INFORMATION
			 - -42231-1 +38056-8|+42230-3 => See 17 for PCI and FDA-approved patient labeling
			 - +42231-1 -38056-8|-42230-3 => See 17 for PCI and Medication Guide
			 - +42231-1 +38056-8 +42230-3 => See 17 for PCI and Medication Guide]
			 if 42231-1 is subsection of 34076-0 add "and Medication Guide"
			 if 42231-1 is not there but patient package insert add "and FDA-approved patient labeling"
			 just make reference to any of these 3 sub-sections - any $standardSection/*[@patsec]
			 it should not labeled as section "17" if it isn't 17
	-->
	<xsl:template mode="highlights" match="/|@*|node()">
		<xsl:apply-templates mode="highlights" select="@*|node()"/>
	</xsl:template>
	<xsl:template mode="highlights" match="/v3:document">
		<div id="Highlights" class="Highlights">
			<table cellspacing="5" cellpadding="5" width="100%" style="table-layout:fixed">
				<tr>
					<td width="50%" align="left" valign="top">
						<div/>
					</td>
					<td width="50%" align="left" valign="top">
						<div>
							<h1>HIGHLIGHTS OF PRESCRIBING INFORMATION</h1>
							<xsl:apply-templates mode="highlights" select="@*|node()" />
						</div>
					</td>
				</tr>
			</table>
		</div>
	</xsl:template>
	<xsl:template mode="highlights" match="/v3:document/v3:title">
		<div class="HighlightsDisclaimer">
			<xsl:apply-templates mode="mixed" select="."/>
		</div>
	</xsl:template>
	<xsl:template mode="highlights" match="v3:structuredBody">
		<!-- here is where we undertake some hard re-ordering -->
		<xsl:variable name="body" select="."/>
		<xsl:variable name="pullUpSections" select="$standardSections//v3:section[@highlightfrontmatter]"/>
		<xsl:variable name="pullDownSections" select="$standardSections//v3:section[@highlightbackmatter]"/>
		<xsl:for-each select="$pullUpSections">
			<xsl:sort select="@highlightfrontmatter"/>
			<xsl:apply-templates mode="highlights" select="$body//v3:section[v3:excerpt][not(ancestor::v3:section[v3:excerpt])][v3:code/@code = current()/@code]">
				<xsl:with-param name="suppressTitle" select="@suppressTitle"/>
				<xsl:with-param name="doNotSuppressFrontOrBackMatter" select="1"/>
			</xsl:apply-templates>
		</xsl:for-each>
		<xsl:apply-templates mode="highlights" select="$body/*"/>
		<xsl:call-template name="patientLabelReference"/>
		<xsl:call-template name="flushDocumentTitleFootnotes"/>
		<xsl:call-template name="effectiveDateHighlights"/>
		<xsl:for-each select="$pullDownSections">
			<xsl:sort select="@highlightbackmatter"/>
			<xsl:apply-templates mode="highlights" select="$body//v3:section[v3:excerpt][v3:code/@code = current()/@code]">
				<xsl:with-param name="suppressTitle" select="@suppressTitle"/>
				<xsl:with-param name="doNotSuppressFrontOrBackMatter" select="1"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="patientLabelReference">
		<xsl:variable name="std-patsecs" select="$standardSections//v3:section[@patsec]"/>
		<xsl:variable name="patsecs" select=".//v3:section[v3:code[@code = $std-patsecs/@code]]" />
		<xsl:variable name="patsecs1" select=".//v3:section[v3:code[@code = $std-patsecs/@code and not(@code = '42230-3')]]" />

		<xsl:choose>
			<xsl:when test=".//v3:section[v3:code/@code = '42231-1'] and .//v3:section[v3:code/@code = '42230-3']">
				<xsl:call-template name="processPatientLabelReference">
					<xsl:with-param name="patsecs" select="$patsecs1" />
					<xsl:with-param name="std-patsecs" select="$std-patsecs" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="processPatientLabelReference">
					<xsl:with-param name="patsecs" select="$patsecs" />
					<xsl:with-param name="std-patsecs" select="$std-patsecs" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="processPatientLabelReference">
		<xsl:param name="patsecs" select="/.." />
		<xsl:param name="std-patsecs" select="/.." />
		<xsl:if test="$patsecs">
			<p class="HighlightsSeeReference">
				<xsl:text>See </xsl:text>
				<!-- XXX: this hard reference to section 17 is not always right,
						 but we got pushback on our attempt to use the actual reference,
						 hence I am moving it back to hard coded "17" for now. -->
				<xsl:text>17</xsl:text>
				<!-- xsl:for-each select="$patsecs">
						 <xsl:variable name="sectionNumber">
						 <xsl:apply-templates mode="sectionNumber" select="."/>
						 </xsl:variable>
						 <xsl:choose>
						 <xsl:when test="position() = 2 and count($patsecs) = 2">
						 <xsl:text> and </xsl:text>
						 </xsl:when>
						 <xsl:when test="position() > 1 and position() = count($patsecs)">
						 <xsl:text>, and </xsl:text>
						 </xsl:when>
						 <xsl:when test="position() > 1">
						 <xsl:text>, </xsl:text>
						 </xsl:when>
						 </xsl:choose>
						 <a href="#section-{substring($sectionNumber,2)}">
						 <xsl:value-of select="substring($sectionNumber,2)"/>
						 </a>
						 </xsl:for-each -->
				<xsl:text> for </xsl:text>
				<xsl:for-each select="$patsecs">
					<xsl:if test="not($patsecs[generate-id(.) = generate-id(current()/../..)])">
						<!-- preventing sub-sections in a patient section to be mentioned -->
						<xsl:choose>
							<xsl:when test="position() > 1 and  position() = last()">
								<xsl:text> and </xsl:text>
							</xsl:when>
							<xsl:when test="position() > 1">
								<xsl:text>, </xsl:text>
							</xsl:when>
						</xsl:choose>
						<xsl:value-of select="$std-patsecs[@code = current()/v3:code/@code]/v3:title"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:text>.</xsl:text>
			</p>
		</xsl:if>
	</xsl:template>
	<xsl:template name="effectiveDateHighlights">
		<xsl:if test="/v3:document/v3:effectiveTime[@value != '']">
			<xsl:variable name="recent-contentOfLabeling-effectiveDate">
				<xsl:call-template name="recent-effectiveDate">
					<xsl:with-param name="effectiveDateSequence" select="/v3:document/v3:component/v3:structuredBody/v3:component[not(preceding-sibling::v3:component/v3:section/v3:code/@code = $maxSection17/@code) and not(v3:section/v3:code/@code = '48780-1')]/v3:section/v3:effectiveTime/@value"/>
				</xsl:call-template>
			</xsl:variable>
			<p class="HighlightsRevision">
				<xsl:text>Revised: </xsl:text>
				<xsl:choose>
					<xsl:when test="function-available('exsl:node-set')">
						<xsl:apply-templates mode="data" select="exsl:node-set($recent-contentOfLabeling-effectiveDate)/v3:effectiveTime">
							<xsl:with-param name="displayMonth">true</xsl:with-param>
							<xsl:with-param name="displayDay">false</xsl:with-param>
							<xsl:with-param name="displayYear">true</xsl:with-param>
							<xsl:with-param name="delimiter">/</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="function-available('msxsl:node-set')">
						<xsl:apply-templates mode="data" select="msxsl:node-set($recent-contentOfLabeling-effectiveDate)/v3:effectiveTime">
							<xsl:with-param name="displayMonth">true</xsl:with-param>
							<xsl:with-param name="displayDay">false</xsl:with-param>
							<xsl:with-param name="displayYear">true</xsl:with-param>
							<xsl:with-param name="delimiter">/</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes">required function node-set is not available, this XSLT processor cannot handle the transform</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$update-check-url-base">
					<xsl:variable name="url" select="concat($update-check-url-base, v3:document/v3:setId/@root)"/>
					<xsl:text> </xsl:text>
					<a href="{$url}">
						<xsl:text>Click here to check for updated version.</xsl:text>
					</a>
				</xsl:if>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="highlights" match="v3:section">
		<xsl:param name="suppressTitle" select="/.."/>
		<xsl:param name="doNotSuppressFrontOrBackMatter" select="/.."/>

		<xsl:if test="$doNotSuppressFrontOrBackMatter or not($standardSections//v3:section[@code = current()/v3:code/@code][@highlightfrontmatter or @highlightbackmatter])">
			<div>
				<xsl:if test="v3:excerpt and not($suppressTitle)">
					<xsl:call-template name="styleCodeAttr">
						<xsl:with-param name="styleCode" select="@styleCode"/>
						<xsl:with-param name="additionalStyleCode">Highlight<xsl:if test="ancestor::v3:section[v3:excerpt]">Sub</xsl:if>Section</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<xsl:apply-templates mode="highlights" select="@*|v3:excerpt">
					<xsl:with-param name="suppressTitle" select="$suppressTitle"/>
				</xsl:apply-templates>
				<xsl:apply-templates mode="highlights" select="node()[not(self::v3:excerpt)]">
					<xsl:with-param name="suppressTitle" select="$suppressTitle"/>
				</xsl:apply-templates>
			</div>
		</xsl:if>
	</xsl:template>
	<xsl:template mode="highlights" match="v3:section[v3:code[@codeSystem='2.16.840.1.113883.6.1' and @code='34066-1']][v3:excerpt]">	<!-- BOXED WARNING -->
		<xsl:param name="doNotSuppressFrontOrBackMatter" select="/.."/>
		<xsl:if test="$doNotSuppressFrontOrBackMatter">
			<div class="Warning">
				<xsl:apply-templates mode="highlights" select="@*|v3:excerpt">
					<xsl:with-param name="suppressTitle" select="1"/>
				</xsl:apply-templates>
				<xsl:apply-templates mode="highlights" select="node()[not(self::v3:excerpt)]">
					<xsl:with-param name="suppressTitle" select="1"/>
				</xsl:apply-templates>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="highlights" match="v3:excerpt">
		<xsl:param name="suppressTitle" select="/.."/>
		<xsl:variable name="currentCode" select="parent::v3:section/v3:code/@code"/>
		<xsl:variable name="standardSection" select="$standardSections//v3:section[@code=$currentCode]"/>
		<xsl:variable name="sectionNumber" select="$standardSection/@number"/>
		<xsl:variable name="currentSectionNum">
			<xsl:apply-templates mode="sectionNumber" select="ancestor-or-self::v3:section"/>
		</xsl:variable>
		<xsl:if test="not($suppressTitle)">
			<h1 class="Highlights">
				<span>
					<xsl:variable name="standardTitle" select="$standardSection[1]/v3:title"/>
					<xsl:choose>
						<xsl:when test="$standardTitle">
							<xsl:value-of select="translate($standardTitle,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="translate(v3:code/@displayName,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
						</xsl:otherwise>
					</xsl:choose>
				</span>
			</h1>
		</xsl:if>
		<div>
			<xsl:apply-templates mode="mixed" select="@*|node()[not(self::v3:title)]"/>
		</div>
	</xsl:template>

	<xsl:template mode="mixed" match="v3:section[v3:code[@codeSystem='2.16.840.1.113883.6.1' and @code='34066-1']]/v3:excerpt/v3:highlight//v3:paragraph[position() &lt; 3]" priority="1">
		<h1 class="Warning">
			<xsl:apply-templates mode="mixed" select="node()[not(self::v3:caption)]"/>
		</h1>
	</xsl:template>

	<xsl:template name="highlightsAutoLink">
		<xsl:if test="ancestor::v3:text[1][not(descendant::v3:linkHtml)][not(v3:paragraph[substring(normalize-space(text()), string-length(normalize-space(text()))-1) = ')'])] and not(ancestor::v3:section[v3:code/@code = $unnumberedSectionCodes])">
			<xsl:variable name="reference" select="ancestor::v3:highlight[1]/v3:reference"/>
			<xsl:apply-templates mode="reference" select=".|//v3:section[v3:id/@root=$reference/v3:section/v3:id/@root and not(ancestor::v3:reference)]"/>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="mixed" match="v3:highlight//v3:paragraph">
		<p class="Highlights{@styleCode}">
			<!-- TESTME!!! The above funky class literal was here, why? It should have been call template to styleCodeAttr -->
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode" select="'Highlighta'"/>
			</xsl:call-template>
			<xsl:apply-templates select="v3:caption"/>
			<xsl:apply-templates mode="mixed" select="node()[not(self::v3:caption)]"/>
			<xsl:text> </xsl:text>
			<xsl:call-template name="highlightsAutoLink"/>
		</p>
	</xsl:template>
	<xsl:template mode="mixed" match="v3:highlight//v3:paragraph[@styleCode='Bullet']" priority="2">
		<p class="HighlightsHanging">
			<span class="Exdent">&#x2022;</span>
			<xsl:apply-templates select="v3:caption"/>
			<xsl:apply-templates mode="mixed" select="node()[not(self::v3:caption)]"/>
			<xsl:text> </xsl:text>
			<xsl:call-template name="highlightsAutoLink"/>
		</p>
	</xsl:template>

	<!-- MODE index -->
	<xsl:template mode="index" match="/|@*|node()">
		<xsl:apply-templates mode="index" select="@*|node()"/>
	</xsl:template>
	<xsl:template mode="index" match="v3:document" priority="0">
		<div id="Index" class="Index">
			<table cellspacing="5" cellpadding="5" width="100%" style="table-layout:fixed">
				<tr>
					<td width="50%" align="left" valign="top">
						<div/>
					</td>
					<td width="50%" align="left" valign="top">
						<div>
							<h1 class="Colspan">FULL PRESCRIBING INFORMATION: CONTENTS<!-- do not allow a space here
            --><a href="#footnote-content" name="footnote-reference-content">*</a></h1>
							<xsl:apply-templates mode="index" select="@*|node()" />
							<dl class="Footnote">
								<dt>
									<a href="#footnote-reference-content" name="footnote-content">*</a>
								</dt>
								<dd>Sections or subsections omitted from the full prescribing information are not listed.</dd>
							</dl>
						</div>
					</td>
				</tr>
			</table>
		</div>
	</xsl:template>
	<xsl:template mode="index" match="v3:section/v3:component/v3:section/v3:component/v3:section" priority="1">
		<!-- per FDA PCR 575: only include sections and first level of subsections in the contents -->
	</xsl:template>
	<xsl:template mode="index" match="v3:section[v3:title and descendant::v3:text[parent::v3:section]]" priority="0">
		<xsl:param name="sectionLevel" select="count(ancestor::v3:section)+1"/>
		<xsl:param name="sectionNumber" select="/.."/>
		<xsl:param name="standardSection" select="$standardSections//v3:section[@code=current()/v3:code/descendant-or-self::*[(self::v3:code or self::v3:translation) and @codeSystem='2.16.840.1.113883.6.1']/@code]"/>
		<xsl:variable name="sectionNumberSequence">
			<xsl:apply-templates mode="sectionNumber" select="ancestor-or-self::v3:section"/>
		</xsl:variable>
		<xsl:variable name="pastSection17" select="../preceding-sibling::v3:component[parent::v3:structuredBody]/v3:section[v3:code/@code = $maxSection17/@code]"/>
		<xsl:if test="not($pastSection17)">
			<xsl:element name="h{$sectionLevel}">
				<a href="#section-{substring($sectionNumberSequence,2)}">
					<xsl:attribute name="class">toc</xsl:attribute>
					<xsl:apply-templates select="@*"/>
					<!-- PCR 601 Not displaying foonote mark inside a table of content -->
					<xsl:apply-templates mode="mixed" select="./v3:title/node()">
						<xsl:with-param name="isTableOfContent" select="'yes'"/>
					</xsl:apply-templates>
				</a>
			</xsl:element>
		</xsl:if>
		<xsl:apply-templates mode="index" select="@*|node()"/>
	</xsl:template>

	<!-- MODE: reference -->
	<!-- Create a section number reference such as (13.2) -->
	<xsl:template mode="reference" match="/|@*|node()">
		<xsl:text> (</xsl:text>
		<xsl:variable name="sectionNumberSequence">
			<xsl:apply-templates mode="sectionNumber" select="ancestor-or-self::v3:section"/>
		</xsl:variable>
		<a href="#section-{substring($sectionNumberSequence,2)}">
			<xsl:value-of select="substring($sectionNumberSequence,2)"/>
		</a>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<!-- styleCode processing: styleCode can be a list of tokens that
			 are being combined into a single css class attribute. To
			 come to a normalized combination we sort the tokens.

Step 1: combine the attribute supplied codes and additional
codes in a single token list.

Step 2: split the token list into XML elements

Step 3: sort the elements and turn into a single combo
token.
	-->
	<xsl:template match="@styleCode" name="styleCodeAttr">
		<xsl:param name="styleCode" select="."/>
		<xsl:param name="additionalStyleCode" select="/.."/>
		<xsl:param name="allCodes" select="normalize-space(concat($additionalStyleCode,' ',$styleCode))"/>
		<xsl:param name="additionalStyleCodeSequence" select="/.."/>
		<xsl:variable name="splitRtf">
			<xsl:if test="$allCodes">
				<xsl:call-template name="splitTokens">
					<xsl:with-param name="text" select="$allCodes"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:for-each select="$additionalStyleCodeSequence">
				<token value="{concat(translate(substring(current(),1,1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring(current(),2))}"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="class">
			<xsl:choose>
				<xsl:when test="function-available('exsl:node-set')">
					<xsl:variable name="sortedTokensRtf">
						<xsl:for-each select="exsl:node-set($splitRtf)/token">
							<xsl:sort select="@value"/>
							<xsl:copy-of select="."/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:call-template name="uniqueStyleCodes">
						<xsl:with-param name="in" select="exsl:node-set($sortedTokensRtf)"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="function-available('msxsl:node-set')">
					<xsl:variable name="sortedTokensRtf">
						<xsl:for-each select="msxsl:node-set($splitRtf)/token">
							<xsl:sort select="@value"/>
							<xsl:copy-of select="."/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:call-template name="uniqueStyleCodes">
						<xsl:with-param name="in" select="msxsl:node-set($sortedTokensRtf)"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- this one below should work for all parsers as it is using exslt but will keep the above code for msxsl for now -->
					<xsl:message>WARNING: missing required function node-set, this xslt processor may not work correctly</xsl:message>
					<xsl:for-each select="str:tokenize($allCodes, ' ')">
						<xsl:sort select="."/>
						<xsl:copy-of select="."/>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($class) > 0">
				<xsl:attribute name="class">
					<xsl:value-of select="normalize-space($class)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="string-length($allCodes) > 0">
				<xsl:attribute name="class">
					<xsl:value-of select="normalize-space($allCodes)"/>
				</xsl:attribute>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="additionalStyleAttr">
		<xsl:if test="self::*[self::v3:paragraph]//v3:content[@styleCode[contains(.,'xmChange')]] or v3:content[@styleCode[contains(.,'xmChange')]] and not(ancestor::v3:table)">
			<xsl:attribute name="style">
				<xsl:choose>
					<xsl:when test="ancestor::v3:section[v3:code[@code = '34066-1']]">margin-left:-2em; padding-left:2em; border-left:1px solid; position:relative; zoom: 1;</xsl:when>
					<xsl:when test="self::*//v3:content/@styleCode[contains(.,'xmChange')] or v3:content/@styleCode[contains(.,'xmChange')]">border-left:1px solid;</xsl:when>
					<xsl:otherwise>margin-left:-1em; padding-left:1em; border-left:1px solid;</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>
	<xsl:template name="uniqueStyleCodes">
		<xsl:param name="in" select="/.."/>
		<xsl:for-each select="$in/token[not(preceding::token/@value = @value)]">
			<xsl:value-of select="@value"/><xsl:text> </xsl:text>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="splitTokens">
		<xsl:param name="text" select="."/>
		<xsl:param name="firstCode" select="substring-before($text,' ')"/>
		<xsl:param name="restOfCodes" select="substring-after($text,' ')"/>
		<xsl:choose>
			<xsl:when test="$firstCode">
				<token
						value="{concat(translate(substring($firstCode,1,1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring($firstCode,2))}"/>
				<xsl:if test="string-length($restOfCodes) > 0">
					<xsl:call-template name="splitTokens">
						<xsl:with-param name="text" select="$restOfCodes"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<token value="{concat(translate(substring($text,1,1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring($text,2))}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- DOCUMENT MODEL -->

	<xsl:template mode="title" match="/|@*|node()"/>
	<xsl:template mode="title" match="v3:document">
		<div class="DocumentTitle">
			<p class="DocumentTitle">
				<xsl:if test="/v3:document/v3:code/@code = $indexingDocumentTypes/v3:code/@code">
					<xsl:value-of select="/v3:document/v3:code/@displayName"/>
					<br/>
				</xsl:if>
				<xsl:if test="/v3:document/v3:code/@code = 'user-profile'">
					<xsl:text>User Profile</xsl:text>
				</xsl:if>


				<!-- Health Canada Added these 3 lines to render the ToC-->
				<span class='formHeadingTitle'>
					<xsl:apply-templates select="v3:component" mode="tableOfContents" />
				</span>




				</p>

			<xsl:variable name="marketingCategories" select="//v3:manufacturedProduct/v3:subjectOf/v3:approval/v3:code"/>
			<xsl:for-each select="$disclaimers/document[code/@code = $root/v3:document/v3:code/@code]/disclaimer[code/@code = $marketingCategories/@code]/text">
				<p class="disclaimer">Disclaimer: <xsl:copy-of select="node()"/></p>
			</xsl:for-each>
			<xsl:if test="not(//v3:manufacturedProduct) and /v3:document/v3:code/@displayName">
				<xsl:value-of select="/v3:document/v3:code/@displayName"/>
				<br/>
			</xsl:if>
			<xsl:if test="/v3:document/v3:code/@code = 'X9999-4'">
				<xsl:variable name="REMSdate" select="/v3:document/v3:effectiveTime/@value"/>
				<b>
					<xsl:text>Most Recent Version: </xsl:text>
					<xsl:value-of select="substring($REMSdate,5,2)"/>/<xsl:value-of select="substring($REMSdate,7,2)"/>/<xsl:value-of select="substring($REMSdate,1,4)"/>
				</b>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="v3:relatedDocument[not(/v3:document/v3:code/@code = 'X9999-4')][@typeCode = 'DRIV' or @typeCode = 'RPLC']/v3:relatedDocument/v3:setId/@root[string-length(.) = 36]">
		<xsl:text>Reference Label Set Id: </xsl:text>
		<a href="{concat('../', ., '.view')}"><xsl:value-of select="."/></a>
		<br/>
	</xsl:template>

	<xsl:template match="v3:relatedDocument[@typeCode = 'XFRM']/v3:relatedDocument/v3:id/@extension">
		<xsl:text>Docket Number: </xsl:text>
			<xsl:value-of select="."/>
		<br/>
	</xsl:template>


	<xsl:template name="headerString">
		<xsl:param name="curProduct">.</xsl:param>
		<xsl:value-of select="$curProduct/v3:name"/>
		<xsl:value-of select="$curProduct/v3:formCode/@code"/>
		<xsl:choose>
			<xsl:when test="$curProduct/v3:part">
				<xsl:value-of select="$curProduct/v3:asEntityWithGeneric/v3:genericMedicine/v3:name"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$curProduct/*[self::v3:ingredient[starts-with(@classCode, 'ACTI')] or self::v3:activeIngredient]">
					<xsl:call-template name="string-lowercase">
						<xsl:with-param name="text" select="(v3:ingredientSubstance|v3:activeIngredientSubstance)/v3:name"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Health Canada Add Jason Addition - Was added by last student before, not sure if this is used -->
	<xsl:template name="IDRootAndExtension">
		<xsl:param name="root" />
		<xsl:param name="extension" />
		<xsl:choose>
			<xsl:when test="($root=$organization-role-oid) and ($extension='1')">
				<xsl:text>DIN OWNER</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- End Jason Addition -->
<!-- possibly delete -->


<xsl:template mode="specialCus" match="v3:name">
	<xsl:value-of select="text()"/>
</xsl:template>

<xsl:template name="titleNumerator">
	<xsl:for-each
			select="./v3:activeIngredient[(./v3:quantity/v3:numerator/@unit or ./v3:quantity/v3:denominator/@unit) and (./v3:quantity/v3:numerator/@unit != '' or ./v3:quantity/v3:denominator/@unit != '') and (./v3:quantity/v3:numerator/@unit != '1' or ./v3:quantity/v3:denominator/@unit != '1')]">
		<xsl:if test="position() = 1">&#160;</xsl:if>
		<xsl:if test="position() > 1">&#160;/&#160;</xsl:if>
		<xsl:value-of select="./v3:quantity/v3:numerator/@value"/>
		<xsl:if test="./v3:quantity/v3:numerator/@unit">&#160;<xsl:value-of select="./v3:quantity/v3:numerator/@unit"/></xsl:if>
		<xsl:if test="./v3:quantity/v3:denominator/@unit != '' and ./v3:quantity/v3:denominator/@unit != '1'">
			<xsl:text>&#160;per&#160;</xsl:text>
			<xsl:value-of select="./v3:quantity/v3:denominator/@value"/>
			<xsl:text>&#160;</xsl:text>
			<xsl:value-of select="./v3:quantity/v3:denominator/@unit"/>
		</xsl:if>
	</xsl:for-each>
</xsl:template>
<xsl:template name="consumedIn">
	<xsl:for-each select="../v3:consumedIn">
		<span class="titleCase">
			<xsl:call-template name="string-lowercase">
				<xsl:with-param name="text" select="./v3:substanceAdministration/v3:routeCode/@displayName"/>
			</xsl:call-template>
		</span>
		<xsl:call-template name="printSeperator"/>
	</xsl:for-each>
</xsl:template>




	<!-- FOOTNOTES -->
	<xsl:param name="footnoteMarks" select="'*&#8224;&#8225;&#167;&#182;#&#0222;&#0223;&#0224;&#0232;&#0240;&#0248;&#0253;&#0163;&#0165;&#0338;&#0339;&#0393;&#0065;&#0066;&#0067;&#0068;&#0069;&#0070;&#0071;&#0072;&#0073;&#0074;&#0075;&#0076;&#0077;&#0078;&#0079;&#0080;&#0081;&#0082;&#0083;&#0084;&#0085;&#0086;&#0087;&#0088;&#0089;&#0090;'"/>
	<xsl:template name="footnoteMark">
		<xsl:param name="target" select="."/>
		<xsl:for-each select="$target[1]">
		<xsl:choose>
				<xsl:when test="ancestor::v3:title[parent::v3:document]">
					<!-- innermost table - FIXME: does not work for the constructed tables -->
					<xsl:variable name="number" select="count(preceding::v3:footnote)+1"/>
					<xsl:value-of select="substring($footnoteMarks,$number,1)"/>
				</xsl:when>
				<xsl:when test="ancestor::v3:table">
					<!-- innermost table - FIXME: does not work for the constructed tables -->
					<xsl:variable name="number">
						<xsl:number level="any" from="v3:table" count="v3:footnote"/>
					</xsl:variable>
					<xsl:value-of select="substring($footnoteMarks,$number,1)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(preceding::v3:footnote[not(ancestor::v3:table or ancestor::v3:title[parent::v3:document])])+1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<!-- changed by Brian Suggs 11-16-05.  Added the [name(..) != 'text']  -->
	<!-- PCR 601 Not displaying foonote mark inside a  table of content -->


	<xsl:template name="flushSectionTitleFootnotes">
		<xsl:variable name="footnotes" select="./v3:title/v3:footnote[not(ancestor::v3:table)]"/>
		<xsl:if test="$footnotes">
			<hr class="Footnoterule"/>
			<dl class="Footnote">
				<xsl:apply-templates mode="footnote" select="$footnotes"/>
			</dl>
		</xsl:if>
	</xsl:template>
	<xsl:template name="flushDocumentTitleFootnotes">
		<xsl:variable name="footnotes" select="/v3:document/v3:title//v3:footnote"/>
		<xsl:if test="$footnotes">
			<br/>
			<dl class="Footnote">
				<xsl:apply-templates mode="footnote" select="$footnotes"/>
			</dl>
		</xsl:if>
	</xsl:template>
	<!-- comment added by Brian Suggs on 11-11-05: The flushfootnotes template is called at the end of every section -->
	<xsl:template match="v3:flushfootnotes" name="flushfootnotes">
		<xsl:variable name="footnotes" select=".//v3:footnote[not(ancestor::v3:table)]"/>
		<xsl:if test="$footnotes">
			<hr class="Footnoterule"/>
			<dl class="Footnote">
				<xsl:apply-templates mode="footnote" select="$footnotes"/>
			</dl>
		</xsl:if>
	</xsl:template>

	<xsl:variable name="unnumberedSectionCodes" select="$standardSections//v3:section[not(number(@number) > 0) and not(@numbered='yes')]/@code"/>

	<!-- SECTION MODEL -->
	<!-- Health Canada New addition template Table of Contents - Connor Vacheresse $toctemp-->
	<xsl:template match="v3:section" mode="tableOfContents">
		<!-- Health Canada Import previous prefix level -->
		<xsl:param name="parentPrefix" select="''" />
		<xsl:variable name="code" select="v3:code/@code" />
		<xsl:variable name="validCode" select="$section-id-oid" />
		<!-- Health Canada Lookup whether CODE is included in Table of Contents and find Heading level -->
		<xsl:variable name="included" select="$codeLookup/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code' and SimpleValue=$code]/../Value[@ColumnRef=concat($doctype,'-toc')]/SimpleValue" />
		<xsl:variable name="heading" select="$codeLookup/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code' and SimpleValue=$code]/../Value[@ColumnRef=concat($doctype,'-level')]/SimpleValue" />
		<!-- Determine most right prefix. -->
		<xsl:variable name="prefix">
			<xsl:choose>
				<!-- Health Canada Heading level 2 nesting can change based on the structure of the XML document. You also have to
					 count the number of siblings in the other sections and then add them. (For example the third element
					 in part #2 needs to also count the number of elements that are in part #1. -->
				<xsl:when test="$heading='2'">
					<xsl:choose>
						<xsl:when test="name(../parent::node())='structuredBody'">
							<xsl:value-of select="1 + count(../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) - count($root/v3:document/v3:component/v3:structuredBody/v3:component[v3:section/v3:code[@code=20]]/preceding-sibling::*) - count(../preceding-sibling::v3:component[v3:section/v3:code[@code='30' or @code='40' or @code='480']])" />
						</xsl:when>
						<xsl:when test="name(../parent::node())='section'">
							<xsl:value-of select="1 + count(../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + count(../../../preceding-sibling::v3:component[v3:section/v3:code[@code='20' or @code='30' or @code='40']]/v3:section/child::v3:component[v3:section/v3:code[@codeSystem=$validCode]])" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="count(../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + 1" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- Health Canada  Heading level 3,4,5 are properly nested and resets for each H2 element.
					 You can simply count the sibling elements to determine the prefix. -->
				<xsl:when test="$heading='3' or $heading='4' or $heading='5'">
					<xsl:value-of select="count(../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + 1" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- Health Canada Draw the Heading element only if it should be included in TOC -->
		<xsl:if test="$included='T'">
			<xsl:choose>
				<!-- Health Canada Heading level 1 (part1,2,3) doesn't have a prefix -->
				<xsl:when test="$heading='1'">
					<a href="#{$code}"><h1 id="{$code}h" style="text-transform:uppercase; font-size:1.5em;">
						<xsl:value-of select="v3:title" />
					</h1></a>
				</xsl:when>
				<!-- Health Canada Heading level 2 doesn't havent any parent prefix -->
				<xsl:when test="$heading='2'">
					<a href="#{$code}"><h2 id="{$code}h" style="text-transform:uppercase;padding-left:2em;margin-top:1.5ex;font-size:1.4em;">
						<xsl:value-of select="concat($prefix,'. ')" />
						<xsl:value-of select="v3:title" />
					</h2></a>
				</xsl:when>
				<!-- Health Canada  Heading level 3,4,5 you concatenate the parent prefix with the prefix -->
				<xsl:when test="$heading='3'">
					<a href="#{$code}"><h3 id="{$code}h" style="padding-left:4.5em;margin-top:1.3ex;font-size:1.3em;">
						<xsl:value-of select="concat($parentPrefix,'.')" />
						<xsl:value-of select="concat($prefix,' ')" />
						<xsl:value-of select="v3:title" />
					</h3></a>
				</xsl:when>
				<xsl:when test="$heading='4'">
					<a href="#{$code}"><h4 id="{$code}h" style="padding-left:6em;margin-top:1ex;font-size:1.2em;">
						<xsl:value-of select="concat($parentPrefix,'.')" />
						<xsl:value-of select="concat($prefix,' ')" />
						<xsl:value-of select="v3:title" />
					</h4></a>
				</xsl:when>
				<xsl:when test="$heading='5'">
					<a href="#{$code}"><h5 id="{$code}h" style="padding-left:7.5em;margin-top:0.8ex;margin-bottom:0.8ex;font-size:1.1em;">
						<xsl:value-of select="concat($parentPrefix,'.')" />
						<xsl:value-of select="concat($prefix,' ')" />
						<xsl:value-of select="v3:title" />
					</h5></a>
				</xsl:when>
				<xsl:otherwise>
					Error: <xsl:value-of select="$code" />/<xsl:value-of select="$heading" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<!--Health Canada Call the template for the subsequent sections -->
		<xsl:apply-templates select="v3:component/v3:section" mode="tableOfContents">
			<xsl:with-param name="parentPrefix">
				<!--Health Canada  Send the rendered prefix down to nested elements. -->
				<xsl:choose>
					<xsl:when test="$heading='1' or $heading='2'">
						<xsl:value-of select="$prefix" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($parentPrefix,'.',$prefix)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
<!-- Health Canada Change-->
	<xsl:template match="v3:section">
		<xsl:param name="standardSection" select="$standardSections//v3:section[@code=current()/v3:code/descendant-or-self::*[(self::v3:code or self::v3:translation) and @codeSystem='2.16.840.1.113883.6.1']/@code]"/>
		<xsl:param name="sectionLevel" select="count(ancestor-or-self::v3:section)"/>
		<xsl:variable name="sectionNumberSequence">
			<xsl:apply-templates mode="sectionNumber" select="ancestor-or-self::v3:section"/>
		</xsl:variable>
		<xsl:variable name="code" select="v3:code/@code" />
		<!-- Health Canada Added new var, line below-->
		<xsl:variable name="heading" select="$codeLookup/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code' and SimpleValue=$code]/../Value[@ColumnRef=concat($doctype,'-level')]/SimpleValue" />

		<xsl:if test="not(v3:code/@code = '48780-1')">
			<div class="Section">
				<xsl:for-each select="v3:code">
					<xsl:attribute name="data-sectionCode"><xsl:value-of select="@code"/></xsl:attribute>
				</xsl:for-each>
				<xsl:call-template name="styleCodeAttr">
					<xsl:with-param name="styleCode" select="@styleCode"/>
					<xsl:with-param name="additionalStyleCode" select="'Section'"/>
				</xsl:call-template>
				<!-- Health Canada Changed the below line to get code of section for anchors-->
				<xsl:for-each select="v3:code/@code">
					<a name="{.}"/>
				</xsl:for-each>
				<!-- Health Canada commented this bottom section out to reduce clutter when rendering (inspect element on browser)-->
				<!--<a name="section-{substring($sectionNumberSequence,2)}"/>-->
				<p/>

				<xsl:apply-templates select="v3:title">
					<xsl:with-param name="sectionLevel" select="$heading"/>
					<xsl:with-param name="sectionNumber" select="substring($sectionNumberSequence,2)"/>
				</xsl:apply-templates>
				<xsl:if test="boolean($show-data)">
					<xsl:apply-templates mode="data" select="."/>
				</xsl:if>
				<xsl:apply-templates select="@*|node()[not(self::v3:title)]"/>
				<xsl:call-template name="flushSectionTitleFootnotes"/>
			</div>
		</xsl:if>
	</xsl:template>
	<xsl:template match="v3:section[v3:code[descendant-or-self::*[self::v3:code or self::v3:translation][@codeSystem='2.16.840.1.113883.6.1' and @code='34066-1']]]" priority="2">
		<!-- boxed warning -->
		<xsl:param name="standardSection" select="$standardSections//v3:section[@code=current()/v3:code/descendant-or-self::*[(self::v3:code or self::v3:translation) and @codeSystem='2.16.840.1.113883.6.1']/@code]"/>
		<xsl:param name="sectionLevel" select="count(ancestor-or-self::v3:section)"/>
		<xsl:variable name="sectionNumberSequence">
			<xsl:apply-templates mode="sectionNumber" select="ancestor-or-self::v3:section"/>
		</xsl:variable>

		<div>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode" select="'Warning'"/>
			</xsl:call-template>
			<xsl:for-each select="@ID">
				<a name="{.}"/>
			</xsl:for-each>
			<a name="section-{substring($sectionNumberSequence,2)}"/>
			<p/>
			<!-- this funny p is used to prevent melting two sub-sections together in condensed style -->
			<xsl:apply-templates select="v3:title">
				<xsl:with-param name="sectionLevel" select="$sectionLevel"/>
				<xsl:with-param name="sectionNumber" select="substring($sectionNumberSequence,2)"/>
			</xsl:apply-templates>

			<xsl:apply-templates select="@*|node()[not(self::v3:title)]"/>
		</div>
	</xsl:template>
	<xsl:template match="v3:section[v3:code[descendant-or-self::*[(self::v3:code or self::v3:translation) and @codeSystem='2.16.840.1.113883.6.1' and @code='43683-2']]]" priority="2">
		<!-- don't display the Recent Major Change section within the FPI -->
	</xsl:template>
	<!-- Health Canada Change -->
	<xsl:template match="v3:title">
		<xsl:param name="sectionLevel" select="count(ancestor::v3:section)"/>
		<xsl:param name="sectionNumber" select="/.."/>

		<xsl:variable name="code" select="../v3:code/@code" />
		<xsl:variable name="validCode" select="$section-id-oid" />
		<xsl:variable name="tocObject" select="$codeLookup/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code' and SimpleValue=$code]/../Value[@ColumnRef=concat($doctype,'-toc')]/SimpleValue" />
		<!-- Health Canada Change Draw H3,H4,H5 elements as H3 because they are too small otherwise -->
		<xsl:variable name="eleSize"><xsl:choose><xsl:when test="$sectionLevel > 3"><xsl:value-of select="'3'" /></xsl:when><xsl:otherwise><xsl:value-of select="$sectionLevel" /></xsl:otherwise></xsl:choose>
		</xsl:variable>
		<xsl:for-each select=".">
		</xsl:for-each>
		<!-- Health Canada Changed variable name to eleSize-->
		<xsl:element name="h{$eleSize}">
			<xsl:if test="$eleSize = '1'">
				<xsl:attribute name="style">font-size:1.5em;</xsl:attribute>
			</xsl:if>
			<xsl:if test="$eleSize = '2'">
				<xsl:attribute name="style">font-size:1.3em;</xsl:attribute>
			</xsl:if>
			<xsl:if test="$eleSize = '3'">
				<xsl:attribute name="style">font-size:1.2em;</xsl:attribute>
			</xsl:if>
			<xsl:if test="$root/v3:document[v3:code/@code = '3565717']">
				<xsl:attribute name="style">display: inline;</xsl:attribute>
			</xsl:if>
			<!-- Health Canada Change-->
			<!--This code generates the prefix that matches what is shown in the Table of Contents -->
			<xsl:if test="$tocObject = 'T' and not($sectionLevel ='1')">
				<xsl:if test="$sectionLevel = 2">
				<!--Health Canada Have to draw 2 -->
					<xsl:choose>
						<xsl:when test="name(../../parent::node())='structuredBody'">
							<xsl:value-of select="1 + count(../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) - count($root/v3:document/v3:component/v3:structuredBody/v3:component[v3:section/v3:code[@code=20]]/preceding-sibling::*) - count(../../preceding-sibling::v3:component[v3:section/v3:code[@code='30' or @code='40' or @code='480']])" />
						</xsl:when>
						<xsl:when test="name(../../parent::node())='section'">
							<xsl:value-of select="1 + count(../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + count(../../../../preceding-sibling::v3:component[v3:section/v3:code[@code='20' or @code='30' or @code='40']]/v3:section/child::v3:component[v3:section/v3:code[@codeSystem=$validCode]])" />
						</xsl:when>
					</xsl:choose>
					<xsl:value-of select="'.'" />
				</xsl:if>
				<xsl:if test="$sectionLevel = 3" >
				<!--Health Canada Have to draw 2,3 -->
					<xsl:choose>
						<xsl:when test="name(../../../../parent::node())='structuredBody'">
							<xsl:value-of select="1 + count(../../../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) - count($root/v3:document/v3:component/v3:structuredBody/v3:component[v3:section/v3:code[@code=20]]/preceding-sibling::*) - count(../../../../preceding-sibling::v3:component[v3:section/v3:code[@code='30' or @code='40' or @code='480']])" />
						</xsl:when>
						<xsl:when test="name(../../../../parent::node())='section'">
							<xsl:value-of select="1 + count(../../../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + count(../../../../../../preceding-sibling::v3:component[v3:section/v3:code[@code='20' or @code='30' or @code='40']]/v3:section/child::v3:component[v3:section/v3:code[@codeSystem=$validCode]])" />
						</xsl:when>
					</xsl:choose>
					<xsl:value-of select="concat('.',count(../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + 1)" />
				</xsl:if>
				<xsl:if test="$sectionLevel = 4" >
				<!--Health Canada Have to draw 2,3,4 -->
					<xsl:choose>
						<xsl:when test="name(../../../../../../parent::node())='structuredBody'">
							<xsl:value-of select="1 + count(../../../../../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) - count($root/v3:document/v3:component/v3:structuredBody/v3:component[v3:section/v3:code[@code=20]]/preceding-sibling::*) - count(../../../../../../preceding-sibling::v3:component[v3:section/v3:code[@code='30' or @code='40' or @code='480']])" />
						</xsl:when>
						<xsl:when test="name(../../../../../../parent::node())='section'">
							<xsl:value-of select="1 + count(../../../../../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + count(../../../../../../../../preceding-sibling::v3:component[v3:section/v3:code[@code='20' or @code='30' or @code='40']]/v3:section/child::v3:component[v3:section/v3:code[@codeSystem=$validCode]])" />
						</xsl:when>
					</xsl:choose>
					<xsl:value-of select="concat('.',count(../../../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + 1)" />
					<xsl:value-of select="concat('.',count(../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + 1)" />
				</xsl:if>
				<xsl:if test="$sectionLevel = 5" >
				<!--Health Canada Have to draw 2,3,4,5 -->
					<xsl:choose>
						<xsl:when test="name(../../../../../../../../parent::node())='structuredBody'">
							<xsl:value-of select="1 + count(../../../../../../../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) - count($root/v3:document/v3:component/v3:structuredBody/v3:component[v3:section/v3:code[@code=20]]/preceding-sibling::*) - count(../../../../../../../../preceding-sibling::v3:component[v3:section/v3:code[@code='30' or @code='40' or @code='480']])" />
						</xsl:when>
						<xsl:when test="name(../../../../../../../../parent::node())='section'">
							<xsl:value-of select="1 + count(../../../../../../../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + count(../../../../../../../../../../preceding-sibling::v3:component[v3:section/v3:code[@code='20' or @code='30' or @code='40']]/v3:section/child::v3:component[v3:section/v3:code[@codeSystem=$validCode]])" />
						</xsl:when>
					</xsl:choose>
					<xsl:value-of select="concat('.',count(../../../../../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + 1)" />
					<xsl:value-of select="concat('.',count(../../../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + 1)" />
					<xsl:value-of select="concat('.',count(../../preceding-sibling::v3:component[v3:section/v3:code[@codeSystem=$validCode]]) + 1)" />
				</xsl:if>
				 <xsl:value-of select="' '" />
			</xsl:if>

			<xsl:apply-templates select="@*"/>
			<xsl:if test="boolean($show-section-numbers) and $sectionNumber">
				<span class="SectionNumber">
					<xsl:value-of select="$sectionNumber"/>
				</span>
			</xsl:if>
			<xsl:call-template name="additionalStyleAttr"/>
			<xsl:apply-templates mode="mixed" select="node()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="v3:text[not(parent::v3:observationMedia)]">
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates mode="mixed" select="node()"/>
		<xsl:apply-templates mode="rems" select="../v3:subject2[v3:substanceAdministration/v3:componentOf/v3:protocol]"/>
		<xsl:call-template name="flushfootnotes">
			<xsl:with-param name="isTableOfContent" select="'no'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="v3:observationMedia/v3:text" priority="2"/>

	<!-- DISPLAY SUBJECT STRUCTURED INFORMATION -->
	<xsl:template match="v3:excerpt|v3:subjectOf"/>

	<xsl:template match="v3:text[not(parent::v3:observationMedia)]">

<!-- Health Canada Change added font size attribute below-->
	<text style="font-size:1.1em;">
	<xsl:apply-templates select="@*"/>
	<xsl:apply-templates mode="mixed" select="node()"/>
	<xsl:apply-templates mode="rems" select="../v3:subject2[v3:substanceAdministration/v3:componentOf/v3:protocol]"/>
	<xsl:call-template name="flushfootnotes">
		<xsl:with-param name="isTableOfContent" select="'no'"/>
	</xsl:call-template>
</text>


	</xsl:template>

<!-- Health Canada Change-->
	<!-- PARAGRAPH MODEL -->
	<xsl:template match="v3:paragraph">
		<!-- Health Canada Change added font size attribute below-->
		<p style="font-size:1.1em;">
			<xsl:if test="$root/v3:document[v3:code/@code = '3565717']">
				<xsl:attribute name="style">display: inline;</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode">
					<xsl:if test="count(preceding-sibling::v3:paragraph)=0">
						<xsl:text>First</xsl:text>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="additionalStyleAttr"/>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<!-- see note anchoring and PCR 793 -->
			<!-- GS: moved this to after the styleCode and othe attribute handling -->
			<xsl:if test="@ID">
				<a name="{@ID}"/>
			</xsl:if>
			<xsl:apply-templates select="v3:caption"/>
			<xsl:apply-templates mode="mixed" select="node()[not(self::v3:caption)]"/>
		</p>
	</xsl:template>
	<!-- the old poor man's footnote -->
	<xsl:template match="v3:paragraph[contains(@styleCode,'Footnote') and v3:caption]">
		<dl class="Footnote">
			<dt>
				<xsl:apply-templates mode="mixed" select="node()[self::v3:caption]"/>
			</dt>
			<dd>
				<xsl:apply-templates mode="mixed" select="node()[not(self::v3:caption)]"/>
			</dd>
		</dl>
	</xsl:template>
	<!-- LIST MODEL -->
	<!-- listType='unordered' is default, if any item has a caption,
			 all should have a caption -->
	<xsl:template match="v3:list[not(v3:item/v3:caption)]">
		<xsl:apply-templates select="v3:caption"/>
		<ul>
			<xsl:apply-templates select="@*|node()[not(self::v3:caption)]"/>
		</ul>
	</xsl:template>
	<xsl:template match="v3:list[@listType='ordered' and        not(v3:item/v3:caption)]" priority="1">
		<xsl:apply-templates select="v3:caption"/>
		<ol>
			<xsl:if test="$root/v3:document[v3:code/@code = 'X9999-4']">
				<xsl:attribute name="start">
					<xsl:value-of select="count(preceding-sibling::v3:list/v3:item) + 1"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="@*|node()[not(self::v3:caption)]"/>
		</ol>
	</xsl:template>
	<xsl:template match="v3:list/v3:item[not(parent::v3:list/v3:item/v3:caption)]">
		<!-- Health Canada added font size attribute -->
		<li style="font-size:1.1em;">
			<xsl:apply-templates select="@*"/>
			<xsl:call-template name="additionalStyleAttr"/>
			<xsl:apply-templates mode="mixed" select="node()"/>
		</li>
	</xsl:template>
	<!-- lists with custom captions -->
	<xsl:template match="v3:list[v3:item/v3:caption]">
		<xsl:apply-templates select="v3:caption"/>
		<dl>
			<xsl:apply-templates select="@*|node()[not(self::v3:caption)]"/>
		</dl>
	</xsl:template>
	<xsl:template match="v3:list/v3:item[parent::v3:list/v3:item/v3:caption]">
		<xsl:apply-templates select="v3:caption"/>
		<dd>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates mode="mixed" select="node()[not(self::v3:caption)]"/>
		</dd>
	</xsl:template>
	<xsl:template match="v3:list/v3:item/v3:caption">
		<dt>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates mode="mixed" select="node()"/>
		</dt>
	</xsl:template>
	<xsl:template match="v3:list/v3:caption">
		<p>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode" select="'ListCaption'"/>
			</xsl:call-template>
			<xsl:call-template name="additionalStyleAttr"/>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<xsl:apply-templates mode="mixed" select="node()"/>
		</p>
	</xsl:template>
	<!-- TABLE MODEL -->
	<!-- Health Canada Change-->
	<xsl:template match="v3:table">
		<!-- see note anchoring and PCR 793 -->
		<xsl:if test="@ID">
			<a name="{@ID}"/>
		</xsl:if>
		<!-- Health Canada Change added attributes for tables-->
		<table width="100%" border="1" style="border:solid 2px;">
			<xsl:apply-templates select="@*|node()"/>
		</table>
	</xsl:template>
	<xsl:template match="v3:table/@summary|v3:table/@width|v3:table/@border|v3:table/@frame|v3:table/@rules|v3:table/@cellspacing|v3:table/@cellpadding">
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="v3:table/v3:caption">
		<caption>
			<xsl:apply-templates select="@*"/>
			<span>
				<xsl:apply-templates mode="mixed" select="node()"/>
			</span>
			<xsl:call-template name="additionalStyleAttr"/>
		</caption>
		<!--xsl:if test="not(preceding-sibling::v3:tfoot) and not(preceding-sibling::v3:tbody)">
				<xsl:call-template name="flushtablefootnotes"/>
				</xsl:if-->
	</xsl:template>
	<xsl:template match="v3:thead">
		<thead>
			<xsl:apply-templates select="@*|node()"/>
		</thead>
	</xsl:template>
	<xsl:template match="v3:thead/@align                       |v3:thead/@char                       |v3:thead/@charoff                       |v3:thead/@valign">
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="v3:tfoot" name="flushtablefootnotes">
		<xsl:variable name="allspan" select="count(ancestor::v3:table[1]/v3:colgroup/v3:col|ancestor::v3:table[1]/v3:col)"/>
		<xsl:if test="self::v3:tfoot or ancestor::v3:table[1]//v3:footnote">
			<tfoot>
				<xsl:if test="self::v3:tfoot">
					<xsl:apply-templates select="@*|node()"/>
				</xsl:if>
				<xsl:if test="ancestor::v3:table[1]//v3:footnote">
					<tr>
						<td colspan="{$allspan}" align="left">
							<dl class="Footnote">
								<xsl:apply-templates mode="footnote" select="ancestor::v3:table[1]/node()"/>
							</dl>
						</td>
					</tr>
				</xsl:if>
			</tfoot>
		</xsl:if>
	</xsl:template>
	<xsl:template match="v3:tfoot/@align                       |v3:tfoot/@char                       |v3:tfoot/@charoff                       |v3:tfoot/@valign">
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="v3:tbody">
		<xsl:if test="not(preceding-sibling::v3:tfoot) and not(preceding-sibling::v3:tbody)">
			<xsl:call-template name="flushtablefootnotes"/>
		</xsl:if>
		<tbody>
			<xsl:apply-templates select="@*|node()"/>
		</tbody>
	</xsl:template>
	<xsl:template match="v3:tbody[not(preceding-sibling::v3:thead)]">
		<xsl:if test="not(preceding-sibling::v3:tfoot) and not(preceding-sibling::tbody)">
			<xsl:call-template name="flushtablefootnotes"/>
		</xsl:if>
		<tbody>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode" select="'Headless'"/>
			</xsl:call-template>
			<xsl:call-template name="additionalStyleAttr"/>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<xsl:apply-templates select="node()"/>
		</tbody>
	</xsl:template>
	<xsl:template match="v3:tbody/@align                       |v3:tbody/@char                       |v3:tbody/@charoff                       |v3:tbody/@valign">
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="v3:tr">
		<tr style="border-collapse: collapse;">
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode">
					<xsl:choose>
						<xsl:when test="contains(ancestor::v3:table/@styleCode, 'Noautorules') or contains(ancestor::v3:section/v3:code/@code, '43683-2') and not(@styleCode)">
							<xsl:text></xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="position()=1">
								<xsl:text>First </xsl:text>
							</xsl:if>
							<xsl:if test="position()=last()">
								<xsl:text>Last </xsl:text>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="additionalStyleAttr"/>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<xsl:apply-templates select="node()"/>
		</tr>
	</xsl:template>
	<xsl:template match="v3:tr/@align|v3:tr/@char|v3:tr/@charoff|v3:tr/@valign">
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="v3:th">
		<!-- determine our position to find out the associated col -->
		<xsl:param name="position" select="1+count(preceding-sibling::v3:td[not(@colspan[number(.) > 0])]|preceding-sibling::v3:th[not(@colspan[number(.) > 0])])+sum(preceding-sibling::v3:td/@colspan[number(.) > 0]|preceding-sibling::v3:th/@colspan[number(.) > 0])"/>
		<xsl:param name="associatedCol" select="(ancestor::v3:table/v3:colgroup/v3:col|ancestor::v3:table/v3:col)[$position]"/>
		<xsl:param name="associatedColgroup" select="$associatedCol/parent::v3:colgroup"/>
		<th>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode">
					<xsl:if test="not(ancestor::v3:tfoot) and ((contains($associatedColgroup/@styleCode,'Lrule') and not($associatedCol/preceding-sibling::v3:col)) or contains($associatedCol/@styleCode, 'Lrule'))">
						<xsl:text> Lrule </xsl:text>
					</xsl:if>
					<xsl:if test="not(ancestor::v3:tfoot) and ((contains($associatedColgroup/@styleCode,'Rrule') and not($associatedCol/following-sibling::v3:col)) or contains($associatedCol/@styleCode, 'Rrule'))">
						<xsl:text> Rrule </xsl:text>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="additionalStyleAttr"/>
			<xsl:copy-of select="$associatedCol/@align"/>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<xsl:apply-templates mode="mixed" select="node()"/>
		</th>
	</xsl:template>
	<xsl:template match="v3:th/@align|v3:th/@char|v3:th/@charoff|v3:th/@valign|v3:th/@abbr|v3:th/@axis|v3:th/@headers|v3:th/@scope|v3:th/@rowspan|v3:th/@colspan">
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="v3:td">
		<!-- determine our position to find out the associated col -->
		<xsl:param name="position" select="1+count(preceding-sibling::v3:td[not(@colspan[number(.) > 0])]|preceding-sibling::v3:th[not(@colspan[number(.) > 0])])+sum(preceding-sibling::v3:td/@colspan[number(.) > 0]|preceding-sibling::v3:th/@colspan[number(.) > 0])"/>


		<xsl:param name="associatedCol" select="(ancestor::v3:table/v3:colgroup/v3:col|ancestor::v3:table/v3:col)[$position]"/>
		<xsl:param name="associatedColgroup" select="$associatedCol/parent::v3:colgroup"/>
		<!-- Health Canada Change added attributes for td-->
		<td style="padding:5px; border: solid 1px;">
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode">
					<xsl:if test="not(ancestor::v3:tfoot) and ((contains($associatedColgroup/@styleCode,'Lrule') and not($associatedCol/preceding-sibling::v3:col)) or contains($associatedCol/@styleCode, 'Lrule'))">
						<xsl:text> Lrule </xsl:text>
					</xsl:if>
					<xsl:if test="not(ancestor::v3:tfoot) and ((contains($associatedColgroup/@styleCode,'Rrule') and not($associatedCol/following-sibling::v3:col)) or contains($associatedCol/@styleCode, 'Rrule'))">
						<xsl:text> Rrule </xsl:text>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="additionalStyleAttr"/>
			<xsl:copy-of select="$associatedCol/@align"/>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<xsl:apply-templates mode="mixed" select="node()"/>
		</td>
	</xsl:template>
	<xsl:template match="v3:td/@align|v3:td/@char|v3:td/@charoff|v3:td/@valign|v3:td/@abbr|v3:td/@axis|v3:td/@headers|v3:td/@scope|v3:td/@rowspan|v3:td/@colspan">
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="v3:colgroup">
		<colgroup>
			<xsl:apply-templates select="@*|node()"/>
		</colgroup>
	</xsl:template>
	<xsl:template match="v3:colgroup/@span|v3:colgroup/@width|v3:colgroup/@align|v3:colgroup/@char|v3:colgroup/@charoff|v3:colgroup/@valign">
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="v3:col">
		<col>
			<xsl:apply-templates select="@*|node()"/>
		</col>
	</xsl:template>
	<xsl:template match="v3:col/@span|v3:col/@width|v3:col/@align|v3:col/@char|v3:col/@charoff|v3:col/@valign">
		<xsl:copy-of select="."/>
	</xsl:template>
	<!-- MIXED MODE: where text is rendered as is, even if nested
			 inside elements that we do not understand  -->
	<!-- based on the deep null-transform -->
	<xsl:template mode="mixed" match="@*|node()">
		<xsl:apply-templates mode="mixed" select="@*|node()"/>
	</xsl:template>
	<xsl:template mode="mixed" match="text()" priority="0">
		<xsl:copy/>
	</xsl:template>
	<xsl:template mode="mixed" match="v3:content">
		<span>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCodeSequence" select="@emphasis|@revised"/>
			</xsl:call-template>
			<xsl:call-template name="additionalStyleAttr"/>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<!-- see note anchoring and PCR 793 -->
			<!-- GS: moved this till after styleCode and other attribute handling -->
			<xsl:choose>
				<xsl:when test="$root/v3:document[v3:code/@code = 'X9999-4']">
					<xsl:if test="not(@ID)">
						<xsl:apply-templates mode="mixed" select="node()"/>
					</xsl:if>
					<xsl:if test="@ID">
						<xsl:variable name="id" select="@ID"/>
						<xsl:variable name="contentID" select="concat('#',$id)"/>
						<xsl:variable name="link" select="/v3:document//v3:subject/v3:manufacturedProduct/v3:subjectOf/v3:document[v3:title/v3:reference/@value = $contentID]/v3:text/v3:reference/@value"/>
						<xsl:if test="$link">
							<a>
								<xsl:attribute name="href">
									<xsl:value-of select="$link"/>
								</xsl:attribute>
								<xsl:apply-templates mode="mixed" select="node()"/>
							</a>
						</xsl:if>
						<xsl:if test="not($link)">
							<a name="{@ID}"/>
							<xsl:apply-templates mode="mixed" select="node()"/>
						</xsl:if>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="@ID">
						<a name="{@ID}"/>
					</xsl:if>
					<xsl:apply-templates mode="mixed" select="node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>
	<xsl:template mode="mixed" match="v3:content[@emphasis='yes']" priority="1">
		<em>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCodeSequence" select="@revised"/>
			</xsl:call-template>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<xsl:apply-templates mode="mixed" select="node()"/>
		</em>
	</xsl:template>
	<xsl:template mode="mixed" match="v3:content[@emphasis]">
		<em>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCodeSequence" select="@emphasis|@revised"/>
			</xsl:call-template>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<xsl:apply-templates mode="mixed" select="node()"/>
		</em>
	</xsl:template>
	<!-- We don't use <sub> and <sup> elements here because IE produces
			 ugly uneven line spacing. -->
	<xsl:template mode="mixed" match="v3:sub">
		<span>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode" select="'Sub'"/>
			</xsl:call-template>
			<xsl:apply-templates mode="mixed" select="@*|node()"/>
		</span>
	</xsl:template>
	<xsl:template mode="mixed" match="v3:sup">
		<span>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode" select="'Sup'"/>
			</xsl:call-template>
			<xsl:apply-templates mode="mixed" select="@*|node()"/>
		</span>
	</xsl:template>
	<xsl:template mode="mixed" match="v3:br">
		<br/>
	</xsl:template>
	<xsl:template mode="mixed" priority="1" match="v3:renderMultiMedia[@referencedObject and (ancestor::v3:paragraph or ancestor::v3:td or ancestor::v3:th)]">
		<xsl:variable name="reference" select="@referencedObject"/>
		<!-- see note anchoring and PCR 793 -->
		<xsl:if test="@ID">
			<a name="{@ID}"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="boolean(//v3:observationMedia[@ID=$reference]//v3:text)">
				<img alt="{//v3:observationMedia[@ID=$reference]//v3:text}" src="{//v3:observationMedia[@ID=$reference]//v3:reference/@value}">
					<xsl:apply-templates select="@*"/>
				</img>
			</xsl:when>
			<xsl:when test="not(boolean(//v3:observationMedia[@ID=$reference]//v3:text))">
				<img alt="Image from Drug Label Content" src="{//v3:observationMedia[@ID=$reference]//v3:reference/@value}">
					<xsl:apply-templates select="@*"/>
				</img>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates mode="notCentered" select="v3:caption"/>
	</xsl:template>
	<xsl:template mode="mixed" match="v3:renderMultiMedia[@referencedObject]">
		<xsl:variable name="reference" select="@referencedObject"/>
		<div>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode" select="'Figure'"/>
			</xsl:call-template>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>

			<!-- see note anchoring and PCR 793 -->
			<xsl:if test="@ID">
				<a name="{@ID}"/>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="boolean(//v3:observationMedia[@ID=$reference]//v3:text)">
					<img alt="{//v3:observationMedia[@ID=$reference]//v3:text}" src="{//v3:observationMedia[@ID=$reference]//v3:reference/@value}">
						<xsl:apply-templates select="@*"/>
					</img>
				</xsl:when>
				<xsl:when test="not(boolean(//v3:observationMedia[@ID=$reference]//v3:text))">
					<img alt="Image from Drug Label Content" src="{//v3:observationMedia[@ID=$reference]//v3:reference/@value}">
						<xsl:apply-templates select="@*"/>
					</img>
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates select="v3:caption"/>
		</div>
	</xsl:template>
	<xsl:template match="v3:renderMultiMedia/v3:caption">
		<p>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode"
												select="'MultiMediaCaption'"/>
			</xsl:call-template>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<xsl:apply-templates mode="mixed" select="node()"/>
		</p>
	</xsl:template>
	<xsl:template mode="notCentered" match="v3:renderMultiMedia/v3:caption">
		<p>
			<xsl:call-template name="styleCodeAttr">
				<xsl:with-param name="styleCode" select="@styleCode"/>
				<xsl:with-param name="additionalStyleCode" select="'MultiMediaCaptionNotCentered'"/>
			</xsl:call-template>
			<xsl:apply-templates select="@*[not(local-name(.)='styleCode')]"/>
			<xsl:apply-templates mode="mixed" select="node()"/>
		</p>
	</xsl:template>
	<xsl:template mode="mixed" match="v3:paragraph|v3:list|v3:table|v3:footnote|v3:footnoteRef|v3:flushfootnotes">
		<xsl:param name="isTableOfContent"/>
		<xsl:choose>
			<xsl:when test="$isTableOfContent='yes'">
				<xsl:apply-templates select=".">
					<xsl:with-param name="isTableOfContent2" select="'yes'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select=".">
					<xsl:with-param name="isTableOfContent2" select="'no'"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- MODE: DATA - deep null transform -->
	<xsl:template mode="data" match="*">
		<xsl:apply-templates mode="data" select="node()"/>
	</xsl:template>
	<xsl:template mode="data" match="text()">
		<xsl:copy/>
	</xsl:template>
	<xsl:template mode="data" match="*[@displayName and not(@code)]">
		<xsl:value-of select="@displayName"/>
	</xsl:template>
	<xsl:template mode="data" match="*[not(@displayName) and @code]">
		<xsl:value-of select="@code"/>
	</xsl:template>
	<xsl:template mode="data" match="*[@displayName and @code]">
		<xsl:value-of select="@displayName"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@code"/>
		<xsl:text>)</xsl:text>
	</xsl:template>
	<!-- add by Brian Suggs on 11-14-05. This will take care of the characteristic unit attribute that wasn't before taken care of -->
	<xsl:template mode="data" match="*[@value and @unit]" priority="1">
		<xsl:value-of select="@value"/>&#160;<xsl:value-of select="@unit"/>
	</xsl:template>
	<xsl:template mode="data" match="*[@value and not(@displayName)]">
		<xsl:value-of select="@value"/>
	</xsl:template>
	<xsl:template mode="data" match="*[@value and @displayName]">
		<xsl:value-of select="@value"/>
		<xsl:text>&#160;</xsl:text>
		<xsl:value-of select="@displayName"/>
	</xsl:template>
	<xsl:template mode="data" match="*[@value and (@xsi:type='TS' or contains(local-name(),'Time'))]" priority="1">
		<xsl:param name="displayMonth">true</xsl:param>
		<xsl:param name="displayDay">true</xsl:param>
		<xsl:param name="displayYear">true</xsl:param>
		<xsl:param name="delimiter">/</xsl:param>
		<xsl:variable name="year" select="substring(@value,1,4)"/>
		<xsl:variable name="month" select="substring(@value,5,2)"/>
		<xsl:variable name="day" select="substring(@value,7,2)"/>
		<!-- changed by Brian Suggs 11-13-05.  Changes made to display date in MM/DD/YYYY format instead of DD/MM/YYYY format -->
		<xsl:if test="$displayMonth = 'true'">
			<xsl:choose>
				<xsl:when test="starts-with($month,'0')">
					<xsl:value-of select="substring-after($month,'0')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$month"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$delimiter"/>
		</xsl:if>
		<xsl:if test="$displayDay = 'true'">
			<xsl:value-of select="$day"/>
			<xsl:value-of select="$delimiter"/>
		</xsl:if>
		<xsl:if test="$displayYear = 'true'">
			<xsl:value-of select="$year"/>
		</xsl:if>
	</xsl:template>
	<xsl:template mode="data" match="*[v3:numerator]">
		<xsl:apply-templates mode="data" select="v3:numerator"/>
		<xsl:if test="v3:denominator[not(@value='1' and (not(@unit) or @unit='1'))]">
			<xsl:text> : </xsl:text>
			<xsl:apply-templates mode="data" select="v3:denominator"/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="effectiveDate">
		<div class="EffectiveDate">
			<!-- changed by Brian Suggs 11-13-05. Added the Effective Date: text back in so that people will know what this date is for. -->
			<!-- changed by Brian Suggs 08-18-06. Modified text to state "Revised:" as per PCR 528 -->
			<!-- GS: adding support for availabilityTime here -->
			<xsl:variable name="revisionTimeCandidates" select="v3:effectiveTime|v3:availabilityTime"/>
			<xsl:variable name="revisionTime" select="$revisionTimeCandidates[@value != ''][last()]"/>
			<xsl:if test="$revisionTime">
				<!--<xsl:text>Revised: </xsl:text>
				<xsl:apply-templates mode="data" select="$revisionTime">
					<xsl:with-param name="displayMonth">true</xsl:with-param>
					<xsl:with-param name="displayDay">false</xsl:with-param>
					<xsl:with-param name="displayYear">true</xsl:with-param>
					<xsl:with-param name="delimiter">/</xsl:with-param>
				</xsl:apply-templates>
				<xsl:if test="$update-check-url-base">
					<xsl:variable name="url" select="concat($update-check-url-base, v3:setId/@root)"/>
					<xsl:text> </xsl:text>
					<a href="{$url}">
						<xsl:text>Click here to check for updated version.</xsl:text>
					</a>
				</xsl:if>
				<div class="DocumentMetadata">
					<div>
						<a href="javascript:toggleMixin();">
							<xsl:text>Document Id: </xsl:text>
						</a>
						<xsl:value-of select="/v3:document/v3:id/@root"/>
					</div>
					<div>
						<xsl:attribute name="id"><xsl:text>setId</xsl:text></xsl:attribute>
						<xsl:text>Set id: </xsl:text>
						<xsl:value-of select="/v3:document/v3:setId/@root"/>
					</div>
					<div>
						<xsl:text>Version: </xsl:text>
						<xsl:value-of select="/v3:document/v3:versionNumber/@value"/>
					</div>
					<div>
						<xsl:text>Effective Time: </xsl:text>
						<xsl:value-of select="/v3:document/v3:effectiveTime/@value"/>
					</div>
					<xsl:for-each select="/v3:document/v3:availabilityTime/@value">
						<div>
							<xsl:text>Availability Time: </xsl:text>
							<xsl:value-of select="."/>
						</div>
					</xsl:for-each>
				</div>-->
			</xsl:if>
		</div>
	</xsl:template>
	<xsl:template name="distributorName">
		<div class="DistributorName">
			<xsl:if test="v3:author/v3:assignedEntity/v3:representedOrganization/v3:name != ''">
				<xsl:value-of select="v3:author/v3:assignedEntity/v3:representedOrganization/v3:name"/>
			</xsl:if>
		</div>
	</xsl:template>
	<!-- block at sections unless handled specially -->
	<xsl:template mode="data" match="v3:section"/>
	<!-- This section will display all of the subject information in one easy to read table. This view is replacing the previous display of the data elements. -->
	<xsl:template mode="subjects" match="/|@*|node()">
		<xsl:apply-templates mode="subjects" select="@*|node()"/>
	</xsl:template>
	<xsl:template mode="subjects" match="v3:section[v3:code/@code ='48780-1'][not(v3:subject/v3:manufacturedProduct)]/v3:text">
		<table class="contentTablePetite" cellSpacing="0" cellPadding="3" width="100%">
			<tbody>
				<xsl:call-template name="ProductInfoBasic"/>
			</tbody>
		</table>
	</xsl:template>
	<!-- Note: This template is also used for top level Product Concept which does not have v3:asEquivalentEntity -->
	<xsl:template mode="subjects" match="v3:section/v3:subject/v3:manufacturedProduct/*[self::v3:manufacturedProduct[v3:name or v3:formCode] or self::v3:manufacturedMedicine][not(v3:asEquivalentEntity/v3:definingMaterialKind[/v3:document/v3:code/@code = '73815-3'])]|v3:section/v3:subject/v3:identifiedSubstance/v3:identifiedSubstance">
		<xsl:if test="not($root/v3:document/v3:code/@code = '3565717') and not($root/v3:document/v3:code/@code = '3565715')">
			<table class="contentTablePetite" cellSpacing="0" cellPadding="3" width="100%">
				<tbody>
					<xsl:if test="$root/v3:document/v3:code/@code = '73815-3'">
						<tr>
							<th align="left" class="formHeadingTitle">
								<xsl:choose>
									<xsl:when test="v3:ingredient">
										<strong>Abstract Product Concept</strong>
									</xsl:when>
									<xsl:otherwise>
										<strong>Application Product Concept</strong>
									</xsl:otherwise>
								</xsl:choose>
							</th>
						</tr>
					</xsl:if>
					<xsl:call-template name="piMedNames"/>

					<xsl:if test="$root/v3:document/v3:code/@code = '64124-1' and v3:asNamedEntity">
						<tr>
							<td>
								<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
									<xsl:apply-templates mode="substance" select="v3:asNamedEntity"/>
								</table>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="$root/v3:document/v3:code/@code = '64124-1'">
						<tr>
							<td>
								<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
									<tr>
										<td colspan="5" class="formHeadingTitle">Substance Information</td>
									</tr>
									<xsl:apply-templates mode="substance" select="v3:asSpecializedKind/v3:generalizedMaterialKind"/>
									<xsl:apply-templates mode="substance" select="v3:asEquivalentSubstance/v3:definingSubstance"/>
									<xsl:apply-templates mode="substance" select="../v3:productOf/v3:derivationProcess"/>
									<xsl:apply-templates mode="substance" select="../v3:interactsIn/v3:interaction"/>
								</table>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="$root/v3:document/v3:code/@code = '64124-1' and ../v3:subjectOf/v3:document">
						<tr>
							<td>
								<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
									<tr class="formTableRowAlt">
										<td class="formLabel">Citation</td>
										<td class="formItem"><xsl:value-of select="../v3:subjectOf/v3:document/v3:bibliographicDesignationText"/></td>
									</tr>
								</table>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="$root/v3:document/v3:code/@code = '64124-1' and ../v3:subjectOf/v3:characteristic">
						<tr>
							<td>
								<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
									<xsl:apply-templates mode="substance" select="../v3:subjectOf/v3:characteristic"/>
								</table>
							</td>
						</tr>
					</xsl:if>
					<xsl:apply-templates mode="substance" select="v3:moiety"/>
					<!--Linkage Table-->
					<xsl:if test="$root/v3:document/v3:code/@code = '64124-1'">
						<tr>
							<td colspan="4">
								<table width="100%" cellpadding="5" cellspacing="0" class="formTablePetite">
									<tr>
										<td colspan="4" class="formHeadingTitle">Molecular Bond Types</td>
									</tr>
									<xsl:apply-templates mode="substance" select="v3:moiety/v3:partMoiety/v3:bond[v3:distalMoiety/v3:id/@extension]"></xsl:apply-templates>
								</table>
							</td>
						</tr>
					</xsl:if>

						<xsl:call-template name="ProductInfoBasic"/>

					<!-- Note: there could be a better way to avoid calling this for substances-->
					<xsl:if test="not($root/v3:document/v3:code/@code = '64124-1')">
						<xsl:choose>
							<!-- if this is a multi-component subject then call to parts template -->
							<xsl:when test="v3:part">
								<xsl:apply-templates mode="subjects" select="v3:part"/>
							</xsl:when>
							<!-- otherwise it is a single product and we simply need to display the ingredients, imprint and packaging. -->
							<xsl:otherwise>
								<xsl:call-template name="ProductInfoIng"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<tr>
						<td>
							<xsl:call-template name="image">
								<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='2']"/>
							</xsl:call-template>
						</td>
					</tr>
					<tr>
						<td class="normalizer">
							<xsl:call-template name="MarketingInfo"/>
						</td>
					</tr>
					<xsl:if test="$root/v3:document/v3:code/@code = '73815-3'">
						<tr>
							<td>
								<xsl:variable name="currCode" select="v3:code/@code"></xsl:variable>
								<xsl:for-each select="ancestor::v3:section[1]/v3:subject/v3:manufacturedProduct/v3:manufacturedProduct[v3:asEquivalentEntity/v3:definingMaterialKind/v3:code/@code = $currCode]">
									<xsl:call-template name="equivalentProductInfo"></xsl:call-template>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:if>
					<!-- FIXME: there seem to be so many different places where the instanceOfKind, that looks somuch like copy&paste and makes maintenance difficult -->
					<xsl:if test="v3:instanceOfKind">
						<tr>
							<td colspan="4">
								<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
									<xsl:apply-templates mode="ldd" select="v3:instanceOfKind"/>
								</table>
							</td>
						</tr>
					</xsl:if>

				</tbody>
			</table>
			<xsl:if test="$root/v3:document/v3:code/@code = '58476-3' and ../v3:subjectOf/v3:characteristic">
				<table cellpadding="3" cellspacing="0" style="border:2px solid">
					<tr>
						<td colspan="3"><span style="font-size: 125%;font-weight: bold;">Supplement Facts</span></td>
					</tr>
					<!-- Health Canada Added attribute below for tables -->
					<tr style="border-bottom:2px solid">
						<xsl:variable name="char" select="../v3:subjectOf/v3:characteristic/v3:value"/>
						<td style="font-size: 100%;font-weight: bold;"><span style=" float: left;">
							Serving Size : <xsl:value-of select="$char[../v3:code/@code = '101.9(b)/1']/v3:translation/@value|$char[../v3:code/@code = '101.9(b)/2']/v3:translation/@value"/><xsl:text> </xsl:text><xsl:value-of select="$char[../v3:code/@code = '101.9(b)/1']/v3:translation/@displayName|$char[../v3:code/@code = '101.9(b)/2']/v3:translation/@displayName"/></span>
						</td>
						<td></td>
						<td style="font-size: 100%;font-weight: bold;"><span style=" float: left;">
							Serving per Container : <xsl:value-of select="$char[../v3:code/@code = '101.9(b)(8)']/@value"/></span>
						</td>
					</tr>
					<tr style="border-bottom:2px solid">
						<th ></th>
						<th style="text-align:center;font-size: 100%;font-weight: bold;">Amount Per Serving</th>
						<th style="text-align:center;font-size: 100%;font-weight: bold;">% Daily Value</th>
					</tr>
					<xsl:for-each select="../v3:subjectOf/v3:characteristic[not(v3:code/@code = '101.9(b)/1') and not(v3:code/@code = '101.9(b)/2') and not(v3:code/@code = '101.9(b)(8)')]">
						<xsl:variable name="def" select="$CHARACTERISTICS/*/*/v3:characteristic[v3:code[@code = current()/v3:code/@code and @codeSystem = current()/v3:code/@codeSystem]][1]"/>
						<tr>
							<td>
								<xsl:variable name="name" select="($def/v3:code/@displayName|$def/v3:code/@p:displayName)[1]" xmlns:p="http://pragmaticdata.com/xforms"/>
								<xsl:value-of select="$name"/>
							</td>
							<td style="text-align:center;">
								<xsl:value-of select="v3:value/@value"/><xsl:text> </xsl:text>
								<xsl:value-of select="v3:value/@unit"/>
							</td>
							<td style="text-align:center;">
								<xsl:if test="$def/v3:value/@unit = v3:value/@unit and number($def/v3:value/@value) > 0 and number(v3:value/@value) > 0">
									<xsl:value-of select="round(number(v3:value/@value) * 100 div number($def/v3:value/@value))"/>
									<xsl:text> %DV</xsl:text>
								</xsl:if>
							</td>
						</tr>
					</xsl:for-each>
				</table>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template name="equivalentProductInfo">
		<tr>
			<td>
				<table style="font-size:100%"  width="100%"  cellpadding="3" cellspacing="0" class="contentTablePetite">
					<tbody>
						<tr>
							<th align="left" class="formHeadingTitle">
								<xsl:choose>
									<xsl:when test="v3:ingredient">
										<strong><xsl:text>Abstract Product Concept</xsl:text></strong>
									</xsl:when>
									<xsl:otherwise>
										<strong><xsl:text>Application Product Concept</xsl:text></strong>
									</xsl:otherwise>
								</xsl:choose>
							</th>
						</tr>
							<xsl:call-template name="ProductInfoBasic"/>
						<tr>
							<td>
								<xsl:call-template name="ProductInfoIng"></xsl:call-template>
							</td>
						</tr>
						<tr>
							<td  class="normalizer">
								<xsl:call-template name="MarketingInfo"></xsl:call-template>
							</td>
						</tr>
						<xsl:variable name="currCode" select="v3:code/@code"></xsl:variable>
						<xsl:for-each select="ancestor::v3:section[1]/v3:subject/v3:manufacturedProduct/v3:manufacturedProduct[v3:asEquivalentEntity/v3:definingMaterialKind/v3:code[not(@code = ../../../v3:code/@code)]/@code = $currCode]">
							<xsl:call-template name="equivalentProductInfo"></xsl:call-template>
						</xsl:for-each>
					</tbody>
				</table>
			</td>
		</tr>
	</xsl:template>

	<!-- XXX: named templates, really not a good idea, but we can't fix the mess all at once
			 These used to be sometimes incompletely defined modes with templates matching everything, leading to default template messes.
			 Now they are all named templates that are to be invoked in exactly one context.
			 Usually any of these templates are to be invoked in the product entity context, that way we avoid so many navigation choices
			 to get to role information and additional information it is easier to just step up.
	-->
	<xsl:template name="piMedNames">
		<xsl:variable name="medName">
			<xsl:call-template name="string-uppercase">
				<xsl:with-param name="text">
					<xsl:copy><xsl:apply-templates mode="specialCus" select="v3:name" /></xsl:copy>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="genMedName">
			<xsl:call-template name="string-uppercase">
				<xsl:with-param name="text" select="v3:asEntityWithGeneric/v3:genericMedicine/v3:name|v3:asSpecializedKind/v3:generalizedMaterialKind/v3:code[@codeSystem = '2.16.840.1.113883.6.276'  or @codeSystem = '2.16.840.1.113883.6.303']/@displayName"/>
			</xsl:call-template>
		</xsl:variable>

		<tr>
			<td class="contentTableTitle">
				<strong>
					<xsl:value-of select="$medName"/>&#160;
					<xsl:call-template name="string-uppercase">
						<xsl:with-param name="text" select="v3:name/v3:suffix"/>
					</xsl:call-template>
				</strong>
				<xsl:apply-templates mode="substance" select="v3:code[@codeSystem = '2.16.840.1.113883.4.9']/@code"/>
				<xsl:if test="not($root/v3:document/v3:code/@code = '73815-3')">
					<br/>
				</xsl:if>
				<span class="contentTableReg">
					<xsl:call-template name="string-lowercase">
						<xsl:with-param name="text" select="$genMedName"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:call-template name="string-lowercase">
						<xsl:with-param name="text" select="v3:formCode/@displayName"/>
					</xsl:call-template>
					<!-- xsl:choose>
							 <xsl:when test="v3:asEntityWithGeneric">
							 <xsl:text> (drug) </xsl:text>
							 </xsl:when>
							 <xsl:when test="v3:asSpecializedKind[v3:generalizedMaterialKind[v3:code[@codeSystem = '2.16.840.1.113883.6.276' or @codeSystem = '2.16.840.1.113883.6.303']]]">
							 <xsl:text> (device) </xsl:text>
							 </xsl:when>
							 </xsl:choose -->
				</span>
			</td>
		</tr>
	</xsl:template>

	<xsl:template name="ProductInfoBasic">
		<tr>
			<td>
				<table width="100%" cellpadding="5" cellspacing="0" class="formTablePetite">
					<tr>
						<td colspan="4" class="formHeadingTitle">Product Information</td>
					</tr>
					<tr class="formTableRowAlt">
						<xsl:if test="not(../../v3:part)">
							<td class="formLabel">Product Type</td>
							<td class="formItem">
								<!-- XXX: can't do in XSLT 1.0: xsl:value-of select="replace($documentTypes/v3:document[@code = $root/v3:document/v3:code/@code]/v3:title,'(^| )label( |$)',' ','i')"/ -->
								<xsl:value-of select="$documentTypes/v3:document[@code = $root/v3:document/v3:code/@code]/v3:title"/>
							</td>
						</xsl:if>
						<xsl:for-each select="v3:code/@code">
							<td class="formLabel">
								<xsl:text>Item Code (Source)</xsl:text>
							</td>
							<td class="formItem">
								<xsl:if test="not(/v3:document/v3:code/@code = '58474-8')">
									<xsl:for-each select="$itemCodeSystems/label[@codeSystem = current()/../@codeSystem][approval/@code = current()/../../../v3:subjectOf/v3:approval/v3:code/@code or @drug = count(current()/../../v3:asEntityWithGeneric)][1]/@name">
										<xsl:value-of select="."/>
										<xsl:text>:</xsl:text>
									</xsl:for-each>
								</xsl:if>
								<xsl:value-of select="."/>
								<xsl:for-each select="../../v3:asEquivalentEntity[v3:code/@code = 'C64637'][1]/v3:definingMaterialKind/v3:code/@code[string-length(.) > 0]">
									<xsl:text>(</xsl:text>
									<xsl:for-each select="$itemCodeSystems/label[@codeSystem = current()/../@codeSystem][approval/@code = current()/../../../v3:subjectOf/v3:approval/v3:code/@code or @drug = count(current()/../../../../v3:asEntityWithGeneric)][1]/@name">
										<xsl:value-of select="."/>
										<xsl:text>:</xsl:text>
									</xsl:for-each>
									<xsl:value-of select="."/>
									<xsl:text>)</xsl:text>
								</xsl:for-each>
							</td>
						</xsl:for-each>
					</tr>
					<xsl:if test="../v3:subjectOf/v3:policy/v3:code/@displayName or  ../v3:consumedIn/*[self::v3:substanceAdministration
					 or self::v3:substanceAdministration1]/v3:routeCode and not(v3:part)">
						<tr class="formTableRow">
							<xsl:if test="../v3:consumedIn/*[self::v3:substanceAdministration or self::v3:substanceAdministration1]/v3:routeCode and not(v3:part)">
								<td width="30%" class="formLabel">Route of Administration</td>
								<td class="formItem">
									<xsl:for-each select="../v3:consumedIn/*[self::v3:substanceAdministration
					 or self::v3:substanceAdministration1]/v3:routeCode">
										<xsl:if test="position() > 1">, </xsl:if>
										<xsl:value-of select="@displayName"/>
									</xsl:for-each>
								</td>
							</xsl:if>
							<xsl:if test="../v3:subjectOf/v3:policy/v3:code/@displayName">
								<td width="30%" class="formLabel">DEA Schedule</td>
								<td class="formItem">
									<xsl:value-of select="../v3:subjectOf/v3:policy/v3:code/@displayName"/>&#160;&#160;&#160;&#160;
								</td>
							</xsl:if>
						</tr>
					</xsl:if>
					<xsl:if test="/v3:document/v3:code/@code = '75031-5' and ../../v3:section[not(v3:subject/v3:manufacturedProduct)]">
						<tr class="formTableRow">
							<td class="formLabel">Product</td>
							<td class="formItem">
								<xsl:value-of select="v3:paragraph"/>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="../../../v3:effectiveTime[v3:low/@value or v3:high/@value]  or  ../v3:effectiveTime[v3:low/@value and v3:high/@value]">
						<tr class="formTableRowAlt">
							<td class="formLabel">Reporting Period</td>
							<td class="formItem">
								<xsl:variable name="range" select="ancestor::v3:section[1]/v3:effectiveTime"/>
								<xsl:value-of select="$range/v3:low/@value"/>
								<xsl:text>-</xsl:text>
								<xsl:value-of select="$range/v3:high/@value"/>
							</td>
							<xsl:if test=" ../../../../v3:section[v3:subject/v3:manufacturedProduct]">
								<td class="formLabel"/>
								<td class="formItem"/>
							</xsl:if>
						</tr>
					</xsl:if>
				</table>
			</td>
		</tr>
	</xsl:template>
	<xsl:template name="ProductInfoIng">
		<xsl:if test="v3:ingredient[starts-with(@classCode,'ACTI')]|v3:activeIngredient">
			<tr>
				<td>
					<xsl:call-template name="ActiveIngredients"/>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="v3:ingredient[@classCode = 'IACT']|v3:inactiveIngredient">
			<tr>
				<td>
					<xsl:call-template name="InactiveIngredients"/>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="v3:ingredient[not(@classCode='IACT' or starts-with(@classCode,'ACTI'))]">
			<tr>
				<td>
					<xsl:call-template name="otherIngredients"/>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="not($root/v3:document/v3:code/@code = '58476-3')">
			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="v3:asEntityWithGeneric and ../v3:subjectOf/v3:characteristic/v3:code[starts-with(@code, 'SPL')]">
							<xsl:call-template name="characteristics-old"/>
						</xsl:when>
						<xsl:when test="../v3:subjectOf/v3:characteristic">
							<xsl:call-template name="characteristics-new"/>
						</xsl:when>
					</xsl:choose>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="v3:asContent">
			<tr>
				<td>
					<xsl:call-template name="packaging">
						<xsl:with-param name="path" select="."/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="v3:instanceOfKind[parent::v3:partProduct]">
			<tr>
				<td colspan="4">
					<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
						<xsl:apply-templates mode="ldd" select="v3:instanceOfKind"/>
					</table>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="subjects" match="v3:part/v3:partProduct|v3:part/v3:partMedicine">
		<!-- only display the outer part packaging once -->
		<xsl:if test="not(../preceding-sibling::v3:part)">
			<xsl:if test="../../v3:asContent">
				<tr>
					<td>
						<xsl:call-template name="packaging">
							<xsl:with-param name="path" select="../.."/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>
			<tr>
				<td>
					<xsl:call-template name="partQuantity">
						<xsl:with-param name="path" select="../.."/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<tr>
			<td>
				<table width="100%" cellspacing="0" cellpadding="5">
					<tr>
						<td class="contentTableTitle">Part <xsl:value-of select="count(../preceding-sibling::v3:part)+1"/> of <xsl:value-of select="count(../../v3:part)"/></td>
					</tr>
					<xsl:call-template name="piMedNames"/>
				</table>
			</td>
		</tr>
			<xsl:call-template name="ProductInfoBasic"/>
			<xsl:call-template name="ProductInfoIng"/>
		<tr>
			<td>
				<xsl:call-template name="image">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='2']"/>
				</xsl:call-template>
			</td>
		</tr>
		<tr>
			<td class="normalizer">
				<xsl:call-template name="MarketingInfo"/>
			</td>
		</tr>
	</xsl:template>

	<!-- display the ingredient information (both active and inactive) -->
	<xsl:template name="ActiveIngredients">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
			<tr>
				<td colspan="3" class="formHeadingTitle">Active Ingredient/Active Moiety</td>
			</tr>
			<tr>
				<th class="formTitle" scope="col">Ingredient Name</th>
				<th class="formTitle" scope="col">Basis of Strength</th>
				<th class="formTitle" scope="col">Strength</th>
			</tr>
			<xsl:if test="not(v3:ingredient[starts-with(@classCode, 'ACTI')]|v3:activeIngredient)">
				<tr>
					<td colspan="3" class="formItem" align="center">No Active Ingredients Found</td>
				</tr>
			</xsl:if>
			<xsl:for-each select="v3:ingredient[starts-with(@classCode, 'ACTI')]|v3:activeIngredient">
				<tr>
					<xsl:attribute name="class">
						<xsl:choose>
							<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
							<xsl:otherwise>formTableRowAlt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:for-each select="(v3:ingredientSubstance|v3:activeIngredientSubstance)[1]">
						<td class="formItem">
							<strong>
								<xsl:value-of select="v3:name"/>
							</strong>
							<xsl:text> (</xsl:text>
							<xsl:for-each select="v3:code/@code">
								<xsl:text>UNII: </xsl:text>
								<xsl:value-of select="."/>
								<xsl:if test="position()!=last()"> and </xsl:if>
							</xsl:for-each>
							<xsl:text>) </xsl:text>
							<xsl:if test="normalize-space(v3:activeMoiety/v3:activeMoiety/v3:name)">
								<xsl:text> (</xsl:text>
								<xsl:for-each select="v3:activeMoiety/v3:activeMoiety/v3:name">
									<xsl:value-of select="."/>
									<xsl:text> - </xsl:text>
									<xsl:text>UNII:</xsl:text>
									<xsl:value-of select="../v3:code/@code"/>
									<xsl:if test="position()!=last()">, </xsl:if>
								</xsl:for-each>
								<xsl:text>) </xsl:text>
							</xsl:if>
							<xsl:for-each select="../v3:subjectOf/v3:substanceSpecification/v3:code[@codeSystem = '2.16.840.1.113883.6.69' or @codeSystem = '2.16.840.1.113883.3.6277']/@code">
								<xsl:text> (Source NDC: </xsl:text>
								<xsl:value-of select="."/>
								<xsl:text>)</xsl:text>
							</xsl:for-each>
						</td>
						<td class="formItem">
							<xsl:choose>
								<xsl:when test="../@classCode='ACTIR'">
									<xsl:value-of select="v3:asEquivalentSubstance/v3:definingSubstance/v3:name"/>
								</xsl:when>
								<xsl:when test="../@classCode='ACTIB'">
									<xsl:value-of select="v3:name"/>
								</xsl:when>
								<xsl:when test="../@classCode='ACTIM'">
									<xsl:value-of select="v3:activeMoiety/v3:activeMoiety/v3:name"/>
								</xsl:when>
							</xsl:choose>
						</td>
					</xsl:for-each>
					<td class="formItem">
						<xsl:value-of select="v3:quantity/v3:numerator/@value"/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:numerator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:numerator/@unit"/></xsl:if>
						<xsl:if test="(v3:quantity/v3:denominator/@value and normalize-space(v3:quantity/v3:denominator/@value)!='1')
													or (v3:quantity/v3:denominator/@unit and normalize-space(v3:quantity/v3:denominator/@unit)!='1')"> &#160;in&#160;<xsl:value-of select="v3:quantity/v3:denominator/@value"
													/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:denominator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:denominator/@unit"/>
							</xsl:if></xsl:if>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>
	<xsl:template name="InactiveIngredients">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
			<tr>
				<!-- see PCR 801, just make the header bigger -->
				<td colspan="2" class="formHeadingTitle">Inactive Ingredients</td>
			</tr>
			<tr>
				<th class="formTitle" scope="col">Ingredient Name</th>
				<th class="formTitle" scope="col">Strength</th>
			</tr>
			<xsl:if test="not(v3:ingredient[@classCode='IACT']|v3:inactiveIngredient)">
				<tr>
					<td colspan="2" class="formItem" align="center">No Inactive Ingredients Found</td>
				</tr>
			</xsl:if>
			<xsl:for-each select="v3:ingredient[@classCode='IACT']|v3:inactiveIngredient">
				<tr>
					<xsl:attribute name="class">
						<xsl:choose>
							<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
							<xsl:otherwise>formTableRowAlt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:for-each select="(v3:ingredientSubstance|v3:inactiveIngredientSubstance)[1]">
						<td class="formItem">
							<strong>
								<xsl:value-of select="v3:name"/>
							</strong>
							<xsl:text> (</xsl:text>
							<xsl:for-each select="v3:code/@code">
								<xsl:text>UNII: </xsl:text>
								<xsl:value-of select="."/>
							</xsl:for-each>
							<xsl:text>) </xsl:text>
						</td>
					</xsl:for-each>
					<td class="formItem">
						<xsl:value-of select="v3:quantity/v3:numerator/@value"/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:numerator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:numerator/@unit"/></xsl:if>
						<xsl:if test="v3:quantity/v3:denominator/@value and normalize-space(v3:quantity/v3:denominator/@unit)!='1'"> &#160;in&#160;<xsl:value-of select="v3:quantity/v3:denominator/@value"
						/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:denominator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:denominator/@unit"/>
							</xsl:if></xsl:if>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>
	<xsl:template name="otherIngredients">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
			<tr>
				<td colspan="3" class="formHeadingTitle">
					<xsl:if test="v3:ingredient[@classCode = 'INGR' or starts-with(@classCode,'ACTI')]">Other </xsl:if>
					<xsl:text>Ingredients</xsl:text>
				</td>
			</tr>
			<tr>
				<th class="formTitle" scope="col">Ingredient Kind</th>
				<th class="formTitle" scope="col">Ingredient Name</th>
				<th class="formTitle" scope="col">Quantity</th>
			</tr>
			<xsl:for-each select="v3:ingredient[not(@classCode='IACT' or starts-with(@classCode,'ACTI'))]">
				<tr>
					<xsl:attribute name="class">
						<xsl:choose>
							<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
							<xsl:otherwise>formTableRowAlt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<td class="formItem">
						<xsl:choose>
							<xsl:when test="@classCode = 'BASE'">Base</xsl:when>
							<xsl:when test="@classCode = 'ADTV'">Additive</xsl:when>
							<xsl:when test="@classCode = 'CNTM' and v3:quantity/v3:numerator/@value='0'">Does not contain</xsl:when>
							<xsl:when test="@classCode = 'CNTM'">May contain</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@classCode"/>
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<xsl:for-each select="(v3:ingredientSubstance|v3:activeIngredientSubstance)[1]">
						<td class="formItem">
							<strong>
								<xsl:value-of select="v3:name"/>
							</strong>
							<xsl:text> (</xsl:text>
							<xsl:for-each select="v3:code/@code">
								<xsl:text>UNII: </xsl:text>
								<xsl:value-of select="."/>
							</xsl:for-each>
							<xsl:text>) </xsl:text>
							<xsl:if test="normalize-space(v3:ingredientSubstance/v3:activeMoiety/v3:activeMoiety/v3:name)"> (<xsl:value-of
							select="v3:ingredientSubstance/v3:activeMoiety/v3:activeMoiety/v3:name"/>) </xsl:if>
						</td>
					</xsl:for-each>
					<td class="formItem">
						<xsl:value-of select="v3:quantity/v3:numerator/@value"/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:numerator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:numerator/@unit"/></xsl:if>
						<xsl:if test="v3:quantity/v3:denominator/@value and normalize-space(v3:quantity/v3:denominator/@unit)!='1'"> &#160;in&#160;<xsl:value-of select="v3:quantity/v3:denominator/@value"
						/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:denominator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:denominator/@unit"/>
							</xsl:if></xsl:if>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>
	<!-- display the imprint information in the specified order.  a apply-template could be used here but then we would not be able to control what order the
			 imprint information is displayed in since there isn't a requirement specifying that the characteristic must be programmed in a certain order-->
	<xsl:template name="characteristics-old">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
			<tr>
				<td colspan="4" class="formHeadingTitle">Product Characteristics</td>
			</tr>
			<tr class="formTableRowAlt">
				<xsl:call-template name="color">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='1']"/>
				</xsl:call-template>
				<xsl:call-template name="score">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='5']"/>
				</xsl:call-template>
			</tr>
			<tr class="formTableRowAlt">
				<xsl:call-template name="image">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='2']"/>
				</xsl:call-template>
				<xsl:call-template name="production_amount">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='6']"/>
				</xsl:call-template>
			</tr>
			<tr class="formTableRow">
				<xsl:call-template name="shape">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='3']"/>
				</xsl:call-template>
				<xsl:call-template name="size">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='11']"/>
				</xsl:call-template>
			</tr>
			<tr class="formTableRowAlt">
				<xsl:call-template name="flavor">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='4']"/>
				</xsl:call-template>
				<xsl:call-template name="imprint">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='12']"/>
				</xsl:call-template>
			</tr>
			<tr class="formTableRowAlt">
				<xsl:call-template name="pharmaceutical_standard">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='13']"/>
				</xsl:call-template>
				<xsl:call-template name="scheduling_symbol">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='14']"/>
				</xsl:call-template>
			</tr>
			<tr class="formTableRowAlt">
				<xsl:call-template name="therapeutic_class">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='15']"/>
				</xsl:call-template>
			</tr>
			<tr class="formTableRow">
				<xsl:call-template name="contains">
					<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='SPLCONTAINS']"/>
				</xsl:call-template>
			</tr>
			<xsl:if test="../v3:subjectOf/v3:characteristic[v3:code/@code='SPLCOATING']|../v3:subjectOf/v3:characteristic[v3:code/@code='SPLSYMBOL']">
				<tr class="formTableRowAlt">
					<xsl:call-template name="coating">
						<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='SPLCOATING']"/>
					</xsl:call-template>
					<xsl:call-template name="symbol">
						<xsl:with-param name="path" select="../v3:subjectOf/v3:characteristic[v3:code/@code='SPLSYMBOL']"/>
					</xsl:call-template>
				</tr>
			</xsl:if>
		</table>
	</xsl:template>
	<xsl:template name="characteristics-new">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
			<tr>
				<td colspan="4" class="formHeadingTitle">Product Characteristics</td>
			</tr>
			<xsl:apply-templates mode="characteristics" select="../v3:subjectOf/v3:characteristic">
				<xsl:sort select="count($CHARACTERISTICS/*/*/v3:characteristic[v3:code[@code = current()/v3:code/@code and @codeSystem = current()/v3:code/@codeSystem]][1]/preceding::*)"/>
			</xsl:apply-templates>
		</table>
	</xsl:template>

	<xsl:template mode="characteristics" match="/|@*|node()">
		<xsl:apply-templates mode="characteristics" select="@*|node()"/>
	</xsl:template>
	<xsl:variable name="CHARACTERISTICS" select="document('characteristic.xml')"/>
	<xsl:template mode="characteristics" match="v3:characteristic">
		<xsl:variable name="def" select="$CHARACTERISTICS/*/*/v3:characteristic[v3:code[@code = current()/v3:code/@code and @codeSystem = current()/v3:code/@codeSystem]][1]"/>
		<tr>
			<td class="formLabel">
				<xsl:variable name="name" select="($def/v3:code/@displayName|$def/v3:code/@p:displayName)[1]" xmlns:p="http://pragmaticdata.com/xforms"/>
				<xsl:value-of select="$name"/>
				<xsl:if test="not($name)">
					<xsl:text>(</xsl:text>
					<xsl:value-of select="v3:code/@code"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</td>
			<xsl:apply-templates mode="characteristics" select="v3:value">
				<xsl:with-param name="def" select="$def"/>
			</xsl:apply-templates>
			<xsl:if test="$def/v3:value/@unit = v3:value/@unit and number($def/v3:value/@value) > 0 and number(v3:value/@value) > 0">
				<td class="formItem">
					<xsl:value-of select="round(number(v3:value/@value) * 100 div number($def/v3:value/@value))"/>
					<xsl:text> %DV</xsl:text>
				</td>
			</xsl:if>
		</tr>
	</xsl:template>
	<xsl:template mode="characteristics" match="v3:value[@xsi:type = 'ST']">
		<td class="formItem" colspan="2"><xsl:value-of select="text()"/></td>
	</xsl:template>
	<xsl:template mode="characteristics" match="v3:value[@xsi:type = 'BL']">
		<td class="formItem" colspan="2"><xsl:value-of select="@value"/></td>
	</xsl:template>
	<xsl:template mode="characteristics" match="v3:value[@xsi:type = 'PQ']">
		<td class="formItem"><xsl:value-of select="@value"/></td>
		<td class="formItem"><xsl:value-of select="@unit"/></td>
	</xsl:template>
	<xsl:template mode="characteristics" match="v3:value[@xsi:type = 'INT']">
		<td class="formItem"><xsl:value-of select="@value"/></td>
		<td class="formItem"/>
	</xsl:template>
	<xsl:template mode="characteristics" match="v3:value[@xsi:type = 'CV' or @xsi:type = 'CE' or @xsi:type = 'CE']">
		<td class="formItem">
			<xsl:value-of select=".//@displayName[1]"/>
		</td>
		<td class="formItem">
			<xsl:value-of select=".//@code[1]"/>
		</td>
	</xsl:template>
	<xsl:template mode="characteristics" match="v3:value[@xsi:type = 'REAL']">
		<td class="formItem"><xsl:value-of select="@value"/></td>
		<td class="formItem"/>
	</xsl:template>
	<xsl:template mode="characteristics" match="v3:value[@xsi:type = 'IVL_PQ' and v3:high/@unit = v3:low/@unit]" priority="2">
		<td class="formItem">
			<xsl:value-of select="v3:low/@value"/>
			<xsl:text>-</xsl:text>
			<xsl:value-of select="v3:high/@value"/>
		</td>
		<td><xsl:value-of select="v3:low/@unit"/></td>
	</xsl:template>
	<xsl:template mode="characteristics" match="v3:value[@xsi:type = 'IVL_PQ' and v3:high/@value and not(v3:low/@value)]">
		<td class="formItem">
			<xsl:text>&lt;</xsl:text>
			<xsl:value-of select="v3:high/@value"/>
		</td>
		<td class="formItem"><xsl:value-of select="v3:high/@unit"/></td>
	</xsl:template>
	<xsl:template mode="characteristics" match="v3:value[@xsi:type = 'IVL_PQ' and v3:low/@value and not(v3:high/@value)]">
		<td class="formItem">
			<xsl:text>></xsl:text>
		<xsl:value-of select="v3:low/@value"/>
	</td>
	<td class="formItem"><xsl:value-of select="v3:low/@unit"/></td>
</xsl:template>


<!-- display the characteristic color -->
<xsl:template name="color">
	<xsl:param name="path" select="."/>
	<td class="formLabel">Color</td>
	<td class="formItem">
		<xsl:for-each select="$path/v3:value">
			<xsl:if test="position() > 1">,&#160;</xsl:if>
			<xsl:value-of select="./@displayName"/>
			<xsl:if test="normalize-space(./v3:originalText)"> (<xsl:value-of select="./v3:originalText"/>) </xsl:if>
		</xsl:for-each>
		<xsl:if test="not($path/v3:value)">&#160;&#160;&#160;&#160;</xsl:if>
	</td>
</xsl:template>
	<!-- display the characteristic production amount -->
	<xsl:template name="production_amount">
		<xsl:param name="path" select="."/>
		<td class="formLabel">Production Amount</td>
		<td class="formItem">
			<xsl:for-each select="$path/v3:value">
				<xsl:if test="position() > 1">,&#160;</xsl:if>
				<xsl:value-of select="./@displayName"/>
				<xsl:if test="normalize-space(./v3:originalText)"> (<xsl:value-of select="./v3:originalText"/>) </xsl:if>
			</xsl:for-each>
			<xsl:if test="not($path/v3:value)">&#160;&#160;&#160;&#160;</xsl:if>
		</td>
	</xsl:template>
<!-- display the characteristic score -->
<xsl:template name="score">
	<xsl:param name="path" select="."/>
	<td class="formLabel">Score</td>
	<td class="formItem">
		<xsl:choose>
			<xsl:when test="$path/v3:value/@nullFlavor='OTH'">score with uneven pieces</xsl:when>
			<xsl:when test="not($path/v3:value)">&#160;&#160;&#160;&#160;</xsl:when>
			<xsl:when test="$path/v3:value/@value = '1'">no score</xsl:when>
			<xsl:otherwise><xsl:value-of select="$path/v3:value/@value"/> pieces</xsl:otherwise>
		</xsl:choose>
	</td>
</xsl:template>
<!-- display the characteristic shape -->
<xsl:template name="shape">
	<xsl:param name="path" select="."/>
	<td class="formLabel">Shape</td>
	<td class="formItem">
		<xsl:value-of select="$path/v3:value/@displayName"/>
		<xsl:if test="normalize-space($path/v3:value/v3:originalText)"> (<xsl:value-of select="$path/v3:value/v3:originalText"/>) </xsl:if>
	</td>
</xsl:template>
<!-- display the characteristic flavor -->
<xsl:template name="flavor">
	<xsl:param name="path" select="."/>
	<td class="formLabel">Flavor</td>
	<td class="formItem">
		<xsl:for-each select="$path/v3:value">
			<xsl:if test="position() > 1">,&#160;</xsl:if>
			<xsl:value-of select="./@displayName"/>
			<xsl:if test="normalize-space(./v3:originalText)"> (<xsl:value-of select="./v3:originalText"/>) </xsl:if>
		</xsl:for-each>
	</td>
</xsl:template>
	<xsl:template name="pharmaceutical_standard">
		<xsl:param name="path" select="."/>
		<td class="formLabel">Pharmaceutical Standard</td>
		<td class="formItem">
			<xsl:for-each select="$path/v3:value">
				<xsl:if test="position() > 1">,&#160;</xsl:if>
				<xsl:value-of select="./@displayName"/>
				<xsl:if test="normalize-space(./v3:originalText)"> (<xsl:value-of select="./v3:originalText"/>) </xsl:if>
			</xsl:for-each>
		</td>
	</xsl:template>
	<xsl:template name="scheduling_symbol">
		<xsl:param name="path" select="."/>
		<td class="formLabel">Scheduling Symbol</td>
		<td class="formItem">
			<xsl:for-each select="$path/v3:value">
				<xsl:if test="position() > 1">,&#160;</xsl:if>
				<xsl:value-of select="./@displayName"/>
				<xsl:if test="normalize-space(./v3:originalText)"> (<xsl:value-of select="./v3:originalText"/>) </xsl:if>
			</xsl:for-each>
		</td>
	</xsl:template>
	<xsl:template name="therapeutic_class">
		<xsl:param name="path" select="."/>
		<td class="formLabel">Therapeutic Class</td>
		<td class="formItem">
			<xsl:for-each select="$path/v3:value">
				<xsl:if test="position() > 1">,&#160;</xsl:if>
				<xsl:value-of select="./@displayName"/>
				<xsl:if test="normalize-space(./v3:originalText)"> (<xsl:value-of select="./v3:originalText"/>) </xsl:if>
			</xsl:for-each>
		</td>
	</xsl:template>
	<!-- display the characteristic imprint -->
<xsl:template name="imprint">
	<xsl:param name="path" select="."/>
	<td class="formLabel">Imprint</td>
	<td class="formItem">
		<xsl:value-of select="$path[v3:value/@xsi:type='ST']"/>
	</td>
</xsl:template>
<!-- display the characteristic size -->
<xsl:template name="size">
	<xsl:param name="path" select="."/>
	<td class="formLabel">Size</td>
	<td class="formItem">
		<xsl:value-of select="$path/v3:value/@value"/>
		<xsl:value-of select="$path/v3:value/@unit"/>
	</td>
</xsl:template>
<!-- display the characteristic symbol -->
<xsl:template name="symbol">
	<xsl:param name="path" select="."/>
	<td class="formLabel">Symbol</td>
	<td class="formItem">
		<xsl:value-of select="$path/v3:value/@value"/>
	</td>
</xsl:template>
<!-- display the characteristic coating -->
<xsl:template name="coating">
	<xsl:param name="path" select="."/>
	<td class="formLabel">Coating</td>
	<td class="formItem">
		<xsl:value-of select="$path/v3:value/@value"/>
	</td>
</xsl:template>
<xsl:template name="image">
	<xsl:param name="path" select="."/>
	<xsl:if test="string-length($path/v3:value/v3:reference/@value) > 0">
		<img alt="Image of Product" style="width:20%;" src="{$path/v3:value/v3:reference/@value}"/>
	</xsl:if>
</xsl:template>

<xsl:template name="contains">
	<xsl:param name="path" select="."/>
	<td class="formLabel">Contains</td>
	<td class="formItem">
		<xsl:for-each select="$path/v3:value">
			<xsl:if test="position() > 1">,&#160;</xsl:if>
			<xsl:value-of select="./@displayName"/>
			<xsl:if test="normalize-space(./v3:originalText)"> (<xsl:value-of select="./v3:originalText"/>) </xsl:if>
		</xsl:for-each>
		<xsl:if test="not($path/v3:value)">&#160;&#160;&#160;&#160;</xsl:if>
	</td>
</xsl:template>
<xsl:template name="partQuantity">
	<xsl:param name="path" select="."/>
	<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
		<tr>
			<td colspan="5" class="formHeadingTitle">Quantity of Parts</td>
		</tr>
		<tr>
			<th scope="col" width="5" class="formTitle">Part&#160;#</th>
			<th scope="col" class="formTitle">Package Quantity</th>
			<th scope="col" class="formTitle">Total Product Quantity</th>
		</tr>
		<xsl:for-each select="$path/v3:part">
			<tr>
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
						<xsl:otherwise>formTableRowAlt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<td width="5" class="formItem">
					<strong>Part <xsl:value-of select="position()"/></strong>
				</td>
				<td class="formItem">
					<xsl:if test="*[self::v3:partProduct or self::v3:partMedicine]/v3:asContent/v3:quantity/v3:numerator/@value">
						<xsl:value-of select="round(v3:quantity/v3:numerator/@value div *[self::v3:partProduct or self::v3:partMedicine]/v3:asContent/v3:quantity/v3:numerator/@value)"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="*[self::v3:partProduct or self::partMedicine]/v3:asContent/*[self::v3:containerPackagedProduct or self::v3:containerPackagedMedicine]/v3:formCode/@displayName"/>
					</xsl:if>
					<xsl:text> </xsl:text>
				</td>
				<td class="formItem">
					<xsl:value-of select="v3:quantity/v3:numerator/@value"/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:numerator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:numerator/@unit"/></xsl:if>
					<xsl:if test="(v3:quantity/v3:denominator/@value and normalize-space(v3:quantity/v3:denominator/@value)!='1')
													or (v3:quantity/v3:denominator/@unit and normalize-space(v3:quantity/v3:denominator/@unit)!='1')"> &#160;in&#160;<xsl:value-of select="v3:quantity/v3:denominator/@value"
													/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:denominator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:denominator/@unit"/>
						</xsl:if></xsl:if>
				</td>
			</tr>
		</xsl:for-each>
	</table>
</xsl:template>
<xsl:template name="packaging">
	<xsl:param name="path" select="."/>
	<table width="100%" cellpadding="3" cellspacing="0" class="formTablePetite">
		<tr>
			<td colspan="5" class="formHeadingTitle">Packaging</td>
		</tr>
		<tr>
			<th scope="col" width="1" class="formTitle">#</th>
			<th scope="col" class="formTitle">Item Code</th>
			<th scope="col" class="formTitle">Package Description</th>
			<th scope="col" class="formTitle">Marketing Start Date</th>
			<th scope="col" class="formTitle">Marketing End Date</th>
		</tr>
		<xsl:for-each select="$path/v3:asContent/descendant-or-self::v3:asContent[not(*/v3:asContent)]">
			<xsl:call-template name="packageInfo">
				<xsl:with-param name="path" select="."/>
				<xsl:with-param name="number" select="position()"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:if test="not($path/v3:asContent)">
			<tr>
				<td colspan="4" class="formTitle">
					<strong>Package Information Not Applicable</strong>
				</td>
			</tr>
		</xsl:if>
	</table>
</xsl:template>
<xsl:template name="packageInfo">
	<xsl:param name="path"/>
	<xsl:param name="number" select="1"/>
	<xsl:for-each select="$path/ancestor-or-self::v3:asContent/*[self::v3:containerPackagedProduct or self::v3:containerPackagedMedicine]">
		<xsl:sort select="position()" order="descending"/>
		<xsl:variable name="current" select="."/>
		<tr>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$number mod 2 = 0">formTableRow</xsl:when>
					<xsl:otherwise>formTableRowAlt</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<th scope="row" class="formItem">
				<xsl:value-of select="$number"/>
			</th>
			<td class="formItem">
				<xsl:for-each select="v3:code[1]/@code">
					<xsl:if test="not(/v3:document/v3:code/@code = '58474-8')">
						<xsl:for-each select="$itemCodeSystems/label[@codeSystem = current()/../@codeSystem][approval/@code = current()/ancestor::*[self::v3:manufacturedProduct or self::v3:manufacturedMedicine or self::v3:partProduct or self::v3:partMedicine][1]/../v3:subjectOf/v3:approval/v3:code/@code or @drug = count(current()/ancestor::*[self::v3:manufacturedProduct or self::v3:manufacturedMedicine or self::v3:partProduct or self::v3:partMedicine][1]/v3:asEntityWithGeneric)][1]/@name">
							<xsl:value-of select="."/>
							<xsl:text>:</xsl:text>
						</xsl:for-each>
					</xsl:if>
					<xsl:value-of select="."/>
				</xsl:for-each>
			</td>
			<td class="formItem">
				<xsl:for-each select="../v3:quantity">
					<xsl:for-each select="v3:numerator">
						<xsl:value-of select="@value"/>
						<xsl:text> </xsl:text>
						<xsl:if test="@unit[. != '1']">
							<xsl:value-of select="@unit"/>
						</xsl:if>
					</xsl:for-each>
					<xsl:text> in </xsl:text>
					<xsl:for-each select="v3:denominator">
						<xsl:value-of select="@value"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:for-each>
				<xsl:value-of select="v3:formCode/@displayName"/>
				<xsl:for-each select="../v3:subjectOf/v3:characteristic">
					<xsl:if test="../../v3:quantity or ../../v3:containerPackagedProduct[v3:formCode[@displayName]] or ../preceding::v3:subjectOf"></xsl:if>
					<xsl:variable name="def" select="$CHARACTERISTICS/*/*/v3:characteristic[v3:code[@code = current()/v3:code/@code and @codeSystem = current()/v3:code/@codeSystem]][1]"/>
					<xsl:variable name="name" select="($def/v3:code/@displayName|$def/v3:code/@p:displayName)[1]" xmlns:p="http://pragmaticdata.com/xforms" />
					<xsl:variable name="cname" select="$CHARACTERISTICS/*/*/v3:characteristic[v3:code[@code = current()/v3:code/@code]]/v3:value[@code = current()/v3:value/@code]/@displayName"/>
					<xsl:choose>
						<xsl:when test="$cname">
							<xsl:text>; </xsl:text>
							<xsl:value-of select="$cname" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>; </xsl:text>
							<xsl:value-of select="$name"/>
							<xsl:text> = </xsl:text>
							<xsl:value-of select="(v3:value[not(../v3:code/@code = 'SPLCMBPRDTP')]/@code|v3:value/@value)[1]"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</td>
			<td class="formItem">
				<xsl:call-template name="string-to-date">
					<xsl:with-param name="text">
						<xsl:value-of select="../v3:subjectOf/v3:marketingAct/v3:effectiveTime/v3:low/@value"/>
					</xsl:with-param>
				</xsl:call-template>
			</td>
			<td class="formItem">
				<xsl:call-template name="string-to-date">
					<xsl:with-param name="text">
						<xsl:value-of select="../v3:subjectOf/v3:marketingAct/v3:effectiveTime/v3:high/@value"/>
					</xsl:with-param>
				</xsl:call-template>
			</td>
		</tr>
	</xsl:for-each>
</xsl:template>


<!-- MODE: ldd - lot distribution data -->
<!-- Note: this is a model how to make these tables right, with apply-templates instead of all these call-template. -->
<xsl:template mode="ldd" match="/|node()|@*">
	<xsl:apply-templates mode="ldd" select="@*|node()"/>
</xsl:template>
<!-- FILL LOT -->
<xsl:template mode="ldd" match="v3:instanceOfKind[not(preceding-sibling::v3:instanceOfKind)]/v3:productInstance" priority="2">
	<tr>
		<td colspan="2" class="formHeadingTitle">Lot Distribution Data</td>
		<td colspan="7" class="formHeadingTitle"></td>
		<td class="formTitle">DUNS</td>
	</tr>
	<xsl:call-template name="next-match-fill-lot"/>
</xsl:template>
<xsl:template mode="ldd" match="v3:instanceOfKind/v3:productInstance" priority="1" name="next-match-fill-lot">
	<tr>
		<td class="formTitle">Fill Lot Number</td>
		<td class="formTitle">Bulk Lot Number</td>
		<td class="formTitle" colspan="5">Substance</td>
		<td class="formTitle">Quantity</td>
		<td class="formTitle">Unit</td>
		<td class="formTitle">DUNS</td>
	</tr>
	<tr>
		<td rowspan="{count(v3:ingredient)+1}" class="formItem"><xsl:value-of select="v3:id/@extension"/></td>
	</tr>
	<xsl:apply-templates mode="ldd" select="v3:ingredient"/>
	<xsl:apply-templates mode="ldd" select="*[not(self::v3:ingredient)]"/>
</xsl:template>
<!-- BULK LOT -->
<xsl:template mode="ldd" name="bulk" match="v3:productInstance/v3:ingredient/v3:ingredientProductInstance" priority="1">
	<tr>
		<td class="formItem"><xsl:value-of select="v3:id/@extension"/></td>
		<td colspan="5" class="formItem"><xsl:value-of select="v3:asInstanceOfKind/v3:kindOfMaterialKind/v3:name"/></td>
		<td class="formItem"><xsl:value-of select="../v3:quantity/v3:numerator/@value"/></td>
		<td class="formItem"><xsl:value-of select="../v3:quantity/v3:numerator/@unit"/></td>
		<td class="formItem"><xsl:value-of select="../v3:subjectOf/v3:productEvent[v3:code[@code='C43360' and @codeSystem='2.16.840.1.113883.3.26.1.1']]/v3:performer/v3:assignedEntity/v3:representedOrganization/v3:id/@extension"/></td>
	</tr>
</xsl:template>
<!-- LABEL LOT -->
<xsl:template mode="ldd" match="v3:productInstance/v3:member[not(preceding-sibling::v3:member)]/v3:memberProductInstance/v3:asContent/v3:container" priority="2">
	<tr>
		<td class="formTitle">Final Container Lot Number</td>
		<td class="formTitle">NDC Package Code</td>
		<td class="formTitle">Container Quantity (Doses)</td>
		<td class="formTitle">Container Form</td>
		<td class="formTitle">Distributed Containers (Doses)</td>
		<td class="formTitle">Distribution Type</td>
		<td class="formTitle">Initial Date</td>
		<td class="formTitle">Expiration Date</td>
		<td class="formTitle">Returned Containers (Doses)</td>
		<td class="formTitle">DUNS</td>
	</tr>
	<xsl:call-template name="next-match-label-lot"/>
</xsl:template>
<xsl:template mode="ldd" match="v3:productInstance/v3:member/v3:memberProductInstance/v3:asContent/v3:container" priority="1" name="next-match-label-lot">
	<tr>
		<td class="formItem"><xsl:value-of select="../../v3:id/@extension"/></td>
		<td class="formItem"><xsl:value-of select="v3:code/@code"/></td>
		<xsl:variable name="quantity" select="../v3:quantity/v3:numerator"/>
		<xsl:variable name="doseQuantity" select="ancestor::*[v3:consumedIn][1]/v3:consumedIn/v3:substanceAdministration1/v3:doseQuantity"/>
		<xsl:variable name="dosesPerContainer" select="number($quantity[@unit = $doseQuantity/@unit]/@value) div number($doseQuantity/@value[number(.) > 0])"/>
		<td class="formItem">
			<xsl:value-of select="$quantity/@value"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="$quantity/@unit[not(. = '1')]"/>
			<xsl:if test="string(number($dosesPerContainer)) != 'NaN'">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="$dosesPerContainer"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</td>
		<td class="formItem"><xsl:value-of select="v3:formCode/@displayName"/></td>
		<td class="formItem">
			<xsl:variable name="qty" select="../v3:subjectOf[v3:productEvent[v3:code[@code = 'C106325' or @code = 'C106326']]]/v3:quantity/@value"/>
			<xsl:value-of select="$qty"/>
			<xsl:if test="string(number(number($qty) * $dosesPerContainer)) != 'NaN'">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="number($qty) * $dosesPerContainer"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</td>
		<td class="formItem"><xsl:value-of select="../v3:subjectOf/v3:productEvent[v3:code[@code = 'C106325' or @code = 'C106326']]/v3:code/@displayName"/></td>
		<td class="formItem"><xsl:value-of select="../v3:subjectOf/v3:productEvent[v3:code[@code = 'C106325' or @code = 'C106326']]/v3:effectiveTime/v3:low/@value"/></td>
		<td class="formItem"><xsl:value-of select="../../v3:expirationTime/v3:high/@value"/></td>
		<td class="formItem">
			<xsl:variable name="qty1" select="../v3:subjectOf[v3:productEvent[v3:code[@code = 'C106328']]]/v3:quantity/@value"/>
			<xsl:if test="$qty1">
				<xsl:value-of select="$qty1"/>
				<xsl:if test="string(number(number($qty1) * $dosesPerContainer)) != 'NaN'">
					<xsl:text> (</xsl:text>
					<xsl:value-of select="number($qty1) * $dosesPerContainer"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:if>
		</td>
		<td class="formItem"><xsl:value-of select="../../../v3:subjectOf/v3:productEvent[v3:code[@code='C43360' and @codeSystem='2.16.840.1.113883.3.26.1.1']]/v3:performer/v3:assignedEntity/v3:representedOrganization/v3:id/@extension"/></td>
	</tr>
</xsl:template>

<xsl:template name="MarketingInfo">
	<xsl:if test="../v3:subjectOf/v3:approval|../v3:subjectOf/v3:marketingAct">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTableMorePetite">
			<tr>
				<td colspan="4" class="formHeadingReg"><span class="formHeadingTitle" >Marketing Information</span></td>
			</tr>
			<tr>
				<th scope="col" class="formTitle">Marketing Category</th>
				<th scope="col" class="formTitle">Application Number or Monograph Citation</th>
				<xsl:if test="not($root/v3:document/v3:code/@code = '73815-3')">
					<th scope="col" class="formTitle">Marketing Start Date</th>
					<th scope="col" class="formTitle">Marketing End Date</th>
				</xsl:if>
			</tr>
			<tr class="formTableRowAlt">
				<td class="formItem">
					<xsl:value-of select="../v3:subjectOf/v3:approval/v3:code/@displayName"/>
				</td>
				<td class="formItem">
					<xsl:value-of select="../v3:subjectOf/v3:approval/v3:id/@extension"/>
				</td>
				<xsl:if test="not($root/v3:document/v3:code/@code = '73815-3')">
					<td class="formItem">
						<xsl:call-template name="string-to-date">
							<xsl:with-param name="text">
								<xsl:value-of select="../v3:subjectOf/v3:marketingAct/v3:effectiveTime/v3:low/@value"/>
							</xsl:with-param>
						</xsl:call-template>
					</td>
					<td class="formItem">
						<xsl:call-template name="string-to-date">
							<xsl:with-param name="text">
								<xsl:value-of select="../v3:subjectOf/v3:marketingAct/v3:effectiveTime/v3:high/@value"/>
							</xsl:with-param>
						</xsl:call-template>
					</td>
				</xsl:if>
			</tr>
		</table>
	</xsl:if>
</xsl:template>


<xsl:template mode="subjects" match="//v3:author/v3:assignedEntity/v3:representedOrganization">
	<xsl:if test="(count(./v3:name)>0)">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTableMorePetite">
			<tr>
				<td colspan="4" class="formHeadingReg"><span class="formHeadingTitle" >DIN Owner -&#160;</span><xsl:value-of select="./v3:name"/>
					<xsl:choose>
						<xsl:when test="./v3:id[@root='1.3.6.1.4.1.519.1']/@extension">
							(<xsl:value-of select="./v3:id[@root='1.3.6.1.4.1.519.1']/@extension"/>)
						</xsl:when>
						<xsl:when  test="./v3:assignedEntity/v3:assignedOrganization/v3:id[@root='1.3.6.1.4.1.519.1']/@extension">
							(<xsl:value-of select="./v3:assignedEntity/v3:assignedOrganization/v3:id[@root='1.3.6.1.4.1.519.1']/@extension"/>)
						</xsl:when>
						<xsl:otherwise/>
					</xsl:choose>
					<xsl:if test="/v3:document/v3:code/@code[. = '51726-8' or . = '72871-7']">
						<span class="formHeadingTitle">NDC Labeler Code: </span>
						<xsl:choose>
							<xsl:when test="./v3:id[@root='2.16.840.1.113883.6.69']/@extension">
								<xsl:value-of select="./v3:id[@root='2.16.840.1.113883.6.69']/@extension"/>
							</xsl:when>
							<xsl:when  test="./v3:assignedEntity/v3:assignedOrganization/v3:id[@root='2.16.840.1.113883.6.69']/@extension">
								<xsl:value-of select="./v3:assignedEntity/v3:assignedOrganization/v3:id[@root='2.16.840.1.113883.6.69']/@extension"/>
							</xsl:when>
							<xsl:otherwise/>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="/v3:document/v3:code/@code[. = '66105-8']">
						<span class="formHeadingTitle">Manufacturer License Number: </span>
						<xsl:choose>
							<xsl:when test="./v3:id[not(@root='1.3.6.1.4.1.519.1')]/@extension">
								<xsl:value-of select="./v3:id[not(@root='1.3.6.1.4.1.519.1')]/@extension"/>
							</xsl:when>
							<xsl:when  test="./v3:assignedEntity/v3:assignedOrganization/v3:id[not(@root='1.3.6.1.4.1.519.1')]/@extension">
								<xsl:value-of select="./v3:assignedEntity/v3:assignedOrganization/v3:id[not(@root='1.3.6.1.4.1.519.1')]/@extension"/>
							</xsl:when>
							<xsl:otherwise/>
						</xsl:choose>
					</xsl:if>
				</td>
			</tr>
			<xsl:call-template name="data-contactParty"/>
		</table>
	</xsl:if>
</xsl:template>
<xsl:template name="data-contactParty">
	<xsl:for-each select="v3:contactParty">
		<xsl:if test="position() = 1">
			<tr>
				<th scope="col" class="formTitle">Contact</th>
				<th scope="col" class="formTitle">Address</th>
				<th scope="col" class="formTitle">Telephone Number</th>
				<th scope="col" class="formTitle">Email Address</th>
			</tr>
		</xsl:if>
		<tr class="formTableRowAlt">
			<td class="formItem">
				<xsl:value-of select="v3:contactPerson/v3:name"/>
			</td>
			<td class="formItem">
				<xsl:apply-templates mode="format" select="v3:addr"/>
			</td>
			<td class="formItem">
				<xsl:value-of select="substring-after(v3:telecom/@value[starts-with(.,'tel:')][1], 'tel:')"/>
				<xsl:for-each select="v3:telecom/@value[starts-with(.,'fax:')]">
					<br/>
					<xsl:text>FAX: </xsl:text>
					<xsl:value-of select="substring-after(., 'fax:')"/>
				</xsl:for-each>
			</td>
			<td class="formItem">
				<xsl:value-of select=" substring-after(v3:telecom/@value[starts-with(.,'mailto:')][1], 'mailto:')"/>
			</td>
		</tr>
	</xsl:for-each>
</xsl:template>

<xsl:template mode="subjects" match="//v3:author/v3:assignedEntity/v3:representedOrganization/v3:assignedEntity/v3:assignedOrganization">
	<xsl:if test="./v3:name">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTableMorePetite">
			<tr>
				<td colspan="4" class="formHeadingReg">
					<span class="formHeadingTitle" >
						<xsl:choose>
							<xsl:when test="/v3:document/v3:code/@code[. = '75030-7']">Reporter -&#160;</xsl:when>
							<xsl:otherwise>Registrant -&#160;</xsl:otherwise>
						</xsl:choose>
					</span><xsl:value-of select="./v3:name"/><xsl:if test="./v3:id/@extension"> (<xsl:value-of select="./v3:id/@extension"/>)</xsl:if>
				</td>
			</tr>
			<xsl:call-template name="data-contactParty"/>
		</table>
	</xsl:if>
</xsl:template>

<xsl:template mode="subjects" match="//v3:author/v3:assignedEntity/v3:representedOrganization/v3:assignedEntity/v3:assignedOrganization/v3:assignedEntity/v3:assignedOrganization">
	<xsl:if test="./v3:name">
		<table width="100%" cellpadding="3" cellspacing="0" class="formTableMorePetite">
			<tr>
				<td colspan="5" class="formHeadingReg">
					<span class="formHeadingTitle" >
						<xsl:choose>
							<!-- replace with HPFB codes -->
							<xsl:when test="/v3:document/v3:code/@code[. = '72090-4' or . = '71743-9' or . = '75030-7']">Facility</xsl:when>
							<xsl:when test="/v3:document/v3:code/@code[. = '51726-8' or . = '72871-7']">Labeler Detail</xsl:when>
							<xsl:otherwise>Other Party</xsl:otherwise>
						</xsl:choose>
					</span>
				</td>
			</tr>
			<tr>
				<th scope="col" class="formTitle">Role</th>
				<th scope="col" class="formTitle">Name</th>
				<th scope="col" class="formTitle">Address</th>
				<th scope="col" class="formTitle">ID/FEI</th>
				<th scope="col" class="formTitle">Business Operations</th>
			</tr>
			<tr class="formTableRowAlt">
				<td class="formItem">
					<!-- replace with the label for the role -->
					<!-- 
					value="(document(concat($oid_loc,$file-prefix,$organization-role-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
					<sch:let name="code-oid-display-name" value="((document(concat($oid_loc,$file-prefix,$din-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$code-code]/Value[@ColumnRef=$display_language]/SimpleValue)"/>  
            
					 -->
					<xsl:variable name="role_id" select="./v3:id[@root=$organization-role-oid]/@extension"/>
					<xsl:variable name="role_name" select="(document(concat($oid_loc,$file-prefix,$organization-role-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$role_id]/Value[@ColumnRef=$display_language]/SimpleValue"/>
					
					<xsl:value-of select="$role_name"/>
				</td>
				<td class="formItem">
					<xsl:value-of select="./v3:name"/>
				</td>
				<td class="formItem">
					<xsl:apply-templates mode="format" select="./v3:addr"/>
				</td>
				<!-- root = "1.3.6.1.4.1.519.1" -->
				<td class="formItem">
					<xsl:value-of select="./v3:id[@root='1.3.6.1.4.1.519.1']/@extension"/><xsl:if test="./v3:id[@root='1.3.6.1.4.1.519.1']/@extension and ./v3:id[not(@root='1.3.6.1.4.1.519.1')]/@extension">/</xsl:if><xsl:value-of select="./v3:id[not(@root='1.3.6.1.4.1.519.1')]/@extension"/>
				</td>
				<td class="formItem">
					<xsl:for-each select="../v3:performance[not(v3:actDefinition/v3:code/@code = preceding-sibling::*/v3:actDefinition/v3:code/@code)]/v3:actDefinition/v3:code">
						<xsl:variable name="code" select="@code"/>
						<xsl:value-of select="@displayName"/>
						<xsl:if test="/v3:document[v3:code/@code = '75030-7'] and ../v3:subjectOf/v3:approval">
							<xsl:text> - </xsl:text>
						</xsl:if>
						<xsl:variable name="itemCodes" select="../../../v3:performance/v3:actDefinition[v3:code/@code = $code]/v3:product/v3:manufacturedProduct/v3:manufacturedMaterialKind/v3:code/@code"/>
						<xsl:if test="$itemCodes">
							<xsl:text>(</xsl:text>
							<xsl:for-each select="$itemCodes">
								<xsl:value-of select="."/>
								<xsl:if test="position()!=last()">, </xsl:if>
							</xsl:for-each>
							<xsl:text>) </xsl:text>
						</xsl:if>
						<xsl:for-each select="../v3:subjectOf/v3:approval/v3:code[@code]">
							<xsl:text>(</xsl:text>
							<xsl:value-of select="@displayName"/>
							<xsl:text>)</xsl:text>
							<xsl:if test="/v3:document/v3:code/@code='75030-7' and ../v3:id[@extension]">
								<xsl:text>, License Info </xsl:text>
								<xsl:text>(</xsl:text>
								<xsl:value-of select="concat('Number: ', ../v3:id/@extension, ', ')"/>
								<xsl:value-of select="concat('State: ', ../descendant::v3:territory/v3:code/@code, ', ')"/>
								<xsl:value-of select="concat('Status: ', ../v3:statusCode/@code)"/>
								<xsl:text>) </xsl:text>
							</xsl:if>
							<xsl:for-each select="../v3:subjectOf/v3:action/v3:code[@code]">
								<xsl:if test="position()!=last()">, </xsl:if>
								<xsl:value-of select="@displayName" />
								<xsl:text>(</xsl:text>
								<xsl:if test="../v3:code[@displayName = 'other']">
									<xsl:text>Text-</xsl:text>
									<xsl:value-of select="../v3:text/text()"/>
									<xsl:if test="../v3:subjectOf/v3:document">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:if>
								<xsl:for-each select="../v3:subjectOf/v3:document/v3:text[@mediaType]/v3:reference">
									<xsl:value-of select="@value" />
									<xsl:if test="position()!=last()">, </xsl:if>
								</xsl:for-each>
								<xsl:text>)</xsl:text>
								<xsl:if test="position()!=last()">, </xsl:if>
							</xsl:for-each>
							<xsl:if test="position()!=last()">, </xsl:if>
						</xsl:for-each>
						<xsl:if test="position()!=last()">, </xsl:if>
					</xsl:for-each>
				</td>
			</tr>
			<xsl:call-template name="data-contactParty"/>
			<xsl:for-each select="./v3:assignedEntity[v3:performance/v3:actDefinition/v3:code/@code='C73330']/v3:assignedOrganization">
				<xsl:if test="position() = 1">
					<tr>
						<th scope="col" class="formTitle">US Agent (ID)</th>
						<th scope="col" class="formTitle">Address</th>
						<th scope="col" class="formTitle">Telephone Number</th>
						<th scope="col" class="formTitle">Email Address</th>
					</tr>
				</xsl:if>
				<tr class="formTableRowAlt">
					<td class="formItem">
						<xsl:value-of select="v3:name"/>
						<xsl:for-each select="v3:id/@extension">
							<xsl:text> (</xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>)</xsl:text>
						</xsl:for-each>
					</td>
					<td class="formItem">
						<xsl:apply-templates mode="format" select="v3:addr"/>
					</td>
					<td class="formItem">
						<xsl:value-of select=" substring-after(v3:telecom/@value[starts-with(.,'tel:')][1], 'tel:')"/>
						<xsl:for-each select="v3:telecom/@value[starts-with(.,'fax:')]">
							<br/>
							<xsl:text>FAX: </xsl:text>
							<xsl:value-of select="substring-after(., 'fax:')"/>
						</xsl:for-each>
					</td>
					<td class="formItem">
						<xsl:value-of select=" substring-after(v3:telecom/@value[starts-with(.,'mailto:')][1], 'mailto:')"/>
					</td>
				</tr>
			</xsl:for-each>
			<!-- 53617 changed to 73599 -->
			<xsl:for-each select="./v3:assignedEntity[v3:performance/v3:actDefinition/v3:code/@code='C73599']/v3:assignedOrganization">
				<xsl:if test="position() = 1">
					<tr>
						<th scope="col" class="formTitle">Importer (ID)</th>
						<th scope="col" class="formTitle">Address</th>
						<th scope="col" class="formTitle">Telephone Number</th>
						<th scope="col" class="formTitle">Email Address</th>
					</tr>
				</xsl:if>
				<tr class="formTableRowAlt">
					<td class="formItem">
						<xsl:value-of select="v3:name"/>
						<xsl:for-each select="v3:id/@extension">
							<xsl:text> (</xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>)</xsl:text>
						</xsl:for-each>
					</td>
					<td class="formItem">
						<xsl:apply-templates mode="format" select="v3:addr"/>
					</td>
					<td class="formItem">
						<xsl:value-of select=" substring-after(v3:telecom/@value[starts-with(.,'tel:')][1], 'tel:')"/>
						<xsl:for-each select="v3:telecom/@value[starts-with(.,'fax:')]">
							<br/>
							<xsl:text>FAX: </xsl:text>
							<xsl:value-of select="substring-after(., 'fax:')"/>
						</xsl:for-each>
					</td>
					<td class="formItem">
						<xsl:value-of select=" substring-after(v3:telecom/@value[starts-with(.,'mailto:')][1], 'mailto:')"/>
					</td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:if>
</xsl:template>


<!-- Start PLR Information templates
			 1. product code
			 2. dosage form
			 3. route of administration
			 4. ingredients
			 5. imprint information
			 6. packaging information
	-->
<xsl:template name="PLRIndications" mode="indication" match="v3:section [v3:code [descendant-or-self::* [(self::v3:code or self::v3:translation) and @codeSystem='2.16.840.1.113883.6.1' and @code='34067-9'] ] ]">
	<xsl:if test="count(//v3:reason) > 0">
		<table class="contentTablePetite" cellSpacing="0" cellPadding="3" width="100%">
			<tbody>
				<tr>
					<td class="contentTableTitle">Indications and Usage</td>
				</tr>
				<tr>
					<td>
						<table class="formTablePetite" cellSpacing="0" cellPadding="3" width="100%">
							<tbody>
								<tr>
									<td class="formTitle" colSpan="2">INDICATIONS</td>
									<td class="formTitle" colSpan="4">USAGE</td>
								</tr>
								<tr>
									<td class="formTitle">Indication</td>
									<td class="formTitle">Intent&#160;Of Use</td>
									<td class="formTitle">Maximum Dose</td>
									<td class="formTitle" colSpan="4">Conditions &amp; Limitations Of Use</td>
								</tr>
								<!-- Repeat Me -->
								<xsl:for-each select="$indicationSection//v3:excerpt/v3:highlight/v3:subject">
									<tr class="formTableRowAlt">
										<td class="formItem" valign="top">
											<strong><xsl:value-of select="./v3:substanceAdministration/v3:reason/v3:indicationObservationCriterion/v3:value/@displayName"/> (<xsl:value-of
												select="./v3:substanceAdministration/v3:reason/v3:indicationObservationCriterion/v3:code/@displayName"/>)</strong>
										</td>
										<td class="formItem" valign="top">
											<xsl:value-of select="./v3:substanceAdministration/v3:reason/@typeCode"/>
										</td>
										<td class="formItem" valign="top">
											<xsl:choose>
												<xsl:when test="./v3:substanceAdministration/v3:maxDoseQuantity">
													<xsl:value-of select="./v3:substanceAdministration/v3:maxDoseQuantity/v3:numerator/@value"/>&#160; <xsl:value-of
														select="./v3:substanceAdministration/v3:maxDoseQuantity/v3:numerator/@unit"/>&#160;per&#160; <xsl:value-of
														select="./v3:substanceAdministration/v3:maxDoseQuantity/v3:denominator/@value"/>&#160; <xsl:value-of
														select="./v3:substanceAdministration/v3:maxDoseQuantity/v3:denominator/@unit"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:for-each select="//v3:maxDoseQuantity[ancestor::v3:section/v3:code/@code = $dosageAndAdministrationSectionCode]">
														<xsl:value-of select="./v3:numerator/@value"/>&#160; <xsl:value-of select="./v3:numerator/@unit"/>&#160;per&#160; <xsl:value-of
															select="./v3:denominator/@value"/>&#160; <xsl:value-of select="./v3:denominator/@unit"/>
													</xsl:for-each>
												</xsl:otherwise>
											</xsl:choose>
										</td>
										<td class="formItem" colSpan="3">
											<table class="formTablePetite" cellSpacing="0" cellPadding="5" width="100%">
												<tbody>
													<tr class="formTable">
														<td class="formTitle" colSpan="4">Conditions Of Use</td>
													</tr>
													<tr class="formTable">
														<td class="formTitle">Use Category</td>
														<td class="formTitle">Precondition Category</td>
														<td class="formTitle">Precondition</td>
														<td class="formTitle">Labeling Section</td>
													</tr>
													<!-- Repeat Each precondition for the indication subject -->
													<!-- PCR 593 Displaying all the preconditions that are specifict to this indication and those that may be in other sections such
																 as the Dosage forms and Strengths.
														-->
													<!-- PCR 593 Displaying all the preconditions that are specifict to this indication and those that may be in other sections such
																 as the Dosage forms and Strengths.
														-->
													<!-- PCR 606 In order to remove the duplicates each section whose ancestor is anything other than $indicationSectionCode.
																 A not (!) in the predicate will not do since a precondition axis can have multiple section tags as ancestors, of which any may be an Indication Section.
														-->
													<xsl:for-each select="./v3:substanceAdministration/v3:precondition">
														<xsl:call-template name="displayConditionsOfUse"> </xsl:call-template>
													</xsl:for-each>
													<xsl:for-each select="//v3:excerpt/v3:highlight/v3:subject/v3:substanceAdministration/v3:precondition">
														<xsl:if test="count(ancestor::v3:section[v3:code/@code=$indicationSectionCode]) = 0">
															<xsl:call-template name="displayConditionsOfUse"> </xsl:call-template>
														</xsl:if>
													</xsl:for-each>
													<xsl:for-each select="./v3:substanceAdministration/v3:componentOf">
														<tr>
															<xsl:attribute name="class">
																<xsl:choose>
																	<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
																	<xsl:otherwise>formTableRowAlt</xsl:otherwise>
																</xsl:choose>
															</xsl:attribute>
															<td class="formItem">Condition of use</td>
															<td class="formItem">Screening/monitoring test</td>
															<td class="formItem">
																<xsl:for-each select="./v3:protocol/v3:component">
																	<xsl:value-of select="./v3:monitoringObservation/v3:code/@displayName"/>
																	<xsl:call-template name="printSeperator"/>
																</xsl:for-each>
															</td>
															<td class="formItem">
																<xsl:variable name="sectionNumberSequence">
																	<xsl:apply-templates mode="sectionNumber" select="$indicationSection/ancestor-or-self::v3:section"/>
																</xsl:variable>
																<a href="#section-{substring($sectionNumberSequence,2)}">
																	<xsl:value-of select="$indicationSection/v3:title"/>
																</a>
															</td>
														</tr>
													</xsl:for-each>
													<!-- end repeat -->
													<tr>
														<td>&#160;</td>
													</tr>
													<tr class="formTable">
														<td class="formTitle" colSpan="4">Limitations Of Use</td>
													</tr>
													<tr class="formTable">
														<td class="formTitle">Use Category</td>
														<td class="formTitle">Precondition Category</td>
														<td class="formTitle">Precondition</td>
														<td class="formTitle">Labeling Section</td>
													</tr>
													<!-- Repeat Each Limitation of Use -->
													<!-- apply all limitation of use templates for issues within this subject -->
													<!-- now apply all limitation of use templates for issues that are NOT within any indication section or subsection -->
													<!-- PCR 593 Since the limitation of use can have multiple ancestors called section, we process all children limitations of the current context.
																 and then all other limitations with specified named ancestors. All possible ancestors other than indication section are used in the predicate.
																 Also made a call to a named template in a loop rather than a matched template-->
													<xsl:for-each select="./v3:substanceAdministration/v3:subjectOf/v3:issue">
														<xsl:call-template name="displayLimitationsOfUse"> </xsl:call-template>
													</xsl:for-each>
													<xsl:for-each select="//v3:excerpt/v3:highlight/v3:subject/v3:substanceAdministration/v3:subjectOf/v3:issue[v3:subject/v3:observationCriterion]">
														<xsl:if test="count(ancestor::v3:section[v3:code/@code=$indicationSectionCode]) = 0">
															<xsl:call-template name="displayLimitationsOfUse"> </xsl:call-template>
														</xsl:if>
													</xsl:for-each>
													<!-- end repeat -->
												</tbody>
											</table>
										</td>
									</tr>
								</xsl:for-each>
								<!--/xsl:for-each-->
								<!-- end repeat -->
							</tbody>
						</table>
					</td>
				</tr>
			</tbody>
		</table>
	</xsl:if>
</xsl:template>
<xsl:template mode="indication" match="v3:value[@xsi:type='IVL_PQ']">
	<xsl:choose>
		<xsl:when test="v3:low and v3:high">
			<xsl:value-of select="v3:low/@value"/><xsl:value-of select="v3:low/@unit"/>&#160;to&#160;<xsl:value-of select="v3:high/@value"/><xsl:value-of select="v3:high/@unit"/>
		</xsl:when>
		<xsl:when test="v3:low and not(v3:high)"> &#8805; <xsl:value-of select="v3:low/@value"/><xsl:value-of select="v3:low/@unit"/>
		</xsl:when>
		<xsl:when test="not(v3:low) and v3:high"> &#8804;<xsl:value-of select="v3:high/@value"/><xsl:value-of select="v3:high/@unit"/>
		</xsl:when>
	</xsl:choose>
</xsl:template>
<xsl:template mode="indication" match="v3:value[@xsi:type='CE']">
	<xsl:param name="currentNode" select="."/>
	<xsl:value-of select="@displayName"/>
</xsl:template>
<xsl:template name="displayConditionsOfUse">
	<tr>
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
				<xsl:otherwise>formTableRowAlt</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:choose>
			<xsl:when test="./v3:observationCriterion">
				<td class="formItem">Condition of use</td>
				<td class="formItem">
					<xsl:value-of select="./v3:observationCriterion/v3:code/@displayName"/>
				</td>
				<td class="formItem">
					<xsl:apply-templates mode="indication" select="./v3:observationCriterion/v3:value"/>
				</td>
			</xsl:when>
			<xsl:when test="./v3:substanceAdministrationCriterion">
				<td class="formItem">Condition of use</td>
				<td class="formItem">Adjunct</td>
				<td class="formItem">
					<xsl:value-of select="./v3:substanceAdministrationCriterion/v3:consumable/v3:administrableMaterial/v3:administrableMaterialKind/v3:code/@displayName"/>
				</td>
			</xsl:when>
		</xsl:choose>
		<td class="formItem">
			<!--PCR 593 Instead of using the variable $indicationSection the section number is being uniquely determined. for conditionsl of use.
				-->
			<xsl:variable name="sectionNumberSequence">
				<xsl:apply-templates mode="sectionNumber" select="ancestor::v3:section[parent::v3:component[parent::v3:structuredBody]]"/>
			</xsl:variable>
			<a href="#section-{substring($sectionNumberSequence,2)}">
				<xsl:value-of select="ancestor::v3:section[parent::v3:component[parent::v3:structuredBody]]/v3:title/text()"/>
			</a>
		</td>
	</tr>
</xsl:template>
<!-- PCR593 Using a named template instead of a matched template for  v3:issue[v3:subject/v3:observationCriterion] See where it is
			 being called from, for more details.-->
<xsl:template name="displayLimitationsOfUse">
	<tr>
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
				<xsl:otherwise>formTableRowAlt</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<td class="formItem">
			<xsl:value-of select="./v3:code/@displayName"/>
		</td>
		<td class="formItem">
			<xsl:for-each select="./v3:subject">
				<xsl:value-of select="./v3:observationCriterion/v3:code/@displayName"/>
				<xsl:call-template name="printSeperator">
					<xsl:with-param name="lastDelimiter">, </xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</td>
		<td class="formItem">
			<xsl:for-each select="./v3:subject">
				<xsl:apply-templates mode="indication" select="./v3:observationCriterion/v3:value"/>
				<xsl:call-template name="printSeperator"/>
			</xsl:for-each>
		</td>
		<td class="formItem">
			<xsl:variable name="sectionNumberSequence">
				<xsl:apply-templates mode="sectionNumber" select="ancestor::v3:section[parent::v3:component[parent::v3:structuredBody]]"/>
			</xsl:variable>
			<a href="#section-{substring($sectionNumberSequence,2)}">
				<xsl:value-of select="ancestor::v3:section[parent::v3:component[parent::v3:structuredBody]]/v3:title/text()"/>
			</a>
		</td>
	</tr>
</xsl:template>
<!-- Interactions template -->
<xsl:template mode="interactions" match="v3:issue[v3:subject[v3:substanceAdministrationCriterion]]">
	<tr>
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
				<xsl:otherwise>formTableRowAlt</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<td class="formItem">
			<xsl:for-each select="v3:subject">
				<xsl:value-of select="./v3:substanceAdministrationCriterion/v3:consumable/v3:administrableMaterial/v3:administrableMaterialKind/v3:code/@displayName"/>
				<xsl:call-template name="printSeperator"/>
			</xsl:for-each>
		</td>
		<td class="formItem">
			<xsl:for-each select="v3:risk">
				<xsl:value-of select="v3:consequenceObservation/v3:code/@displayName"/>
				<xsl:call-template name="printSeperator"/>
			</xsl:for-each>
		</td>
		<td class="formItem">
			<xsl:for-each select="v3:risk">
				<xsl:value-of select="v3:consequenceObservation/v3:value/@displayName"/>
				<xsl:call-template name="printSeperator"/>
			</xsl:for-each>
		</td>
		<td class="formItem">
			<xsl:variable name="sectionNumberSequence">
				<xsl:apply-templates mode="sectionNumber" select="ancestor::v3:section[parent::v3:component[parent::v3:structuredBody]]"/>
			</xsl:variable>
			<a href="#section-{substring($sectionNumberSequence,2)}">
				<xsl:value-of select="ancestor::v3:section[parent::v3:component[parent::v3:structuredBody]]/v3:title"/>
			</a>
		</td>
	</tr>
</xsl:template>
<!-- Adverse Reactions template -->
<xsl:template mode="adverseReactions" match="v3:issue[not(./v3:subject) and v3:risk]">
	<xsl:param name="addEmptyTd">false</xsl:param>
	<tr>
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
				<xsl:otherwise>formTableRowAlt</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="$addEmptyTd = 'true'">
			<td>&#160;</td>
		</xsl:if>
		<td class="formItem">
			<xsl:for-each select="v3:risk">
				<xsl:value-of select="./v3:consequenceObservation/v3:code/@displayName"/>
				<xsl:call-template name="printSeperator">
					<xsl:with-param name="lastDelimiter">, </xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</td>
		<td class="formItem">
			<xsl:for-each select="v3:risk">
				<xsl:value-of select="v3:consequenceObservation/v3:value/@displayName"/>
				<xsl:call-template name="printSeperator"/>
			</xsl:for-each>
		</td>
		<td class="formItem">
			<xsl:variable name="sectionNumberSequence">
				<xsl:apply-templates mode="sectionNumber" select="ancestor::v3:section[parent::v3:component[parent::v3:structuredBody]]"/>
			</xsl:variable>
			<a href="#section-{substring($sectionNumberSequence,2)}">
				<xsl:value-of select="ancestor::v3:section[parent::v3:component[parent::v3:structuredBody]]/v3:title"/>
			</a>
		</td>
	</tr>
</xsl:template>
<!-- Other Interaction template -->
<xsl:template mode="otherInteraction" match="v3:issue">
	<xsl:param name="addEmptyTd">false</xsl:param>
	<tr>
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
				<xsl:otherwise>formTableRowAlt</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="$addEmptyTd = 'true'">
			<td>&#160;</td>
		</xsl:if>
		<td class="formItem">
			<xsl:value-of select="v3:code/@displayName"/>
		</td>
		<td class="formItem">
			<xsl:value-of select="v3:subject/v3:observationCriterion/v3:code/@displayName"/>
		</td>
		<td class="formItem">
			<xsl:value-of select="v3:subject/v3:observationCriterion/v3:value/@displayName"/>
		</td>
		<td class="formItem">
			<xsl:variable name="sectionNumberSequence">
				<xsl:apply-templates mode="sectionNumber" select="ancestor::v3:section[parent::v3:component[parent::v3:structuredBody]]"/>
			</xsl:variable>
			<a href="#section-{substring($sectionNumberSequence,2)}">
				<xsl:value-of select="ancestor::v3:section[parent::v3:component[parent::v3:structuredBody]]/v3:title"/>
			</a>
		</td>
	</tr>
</xsl:template>
<xsl:template name="PharmacologicalClass">
	<xsl:if test="//v3:generalizedMaterialKind[v3:code/@codeSystem='2.16.840.1.113883.3.26.1.5']">
		<table cellSpacing="0" cellPadding="3" width="100%" class="formTablePetite">
			<tbody>
				<tr>
					<td class="formHeadingTitle">Pharmacologic Class</td>
				</tr>
				<tr class="formTableRowAlt">
					<td class="formItem">
						<table class="formTablePetite" cellSpacing="0" cellPadding="3" width="100%">
							<tbody>
								<tr>
									<td class="formHeadingTitle" width="30%">Substance</td>
									<td class="formHeadingTitle" width="70%">Pharmacologic Class</td>
								</tr>
								<xsl:for-each select="//*[v3:asSpecializedKind]">
									<tr>
										<xsl:attribute name="class">
											<xsl:choose>
												<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
												<xsl:otherwise>formTableRowAlt</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
										<td class="formItem">
											<strong>
												<xsl:value-of select="v3:name"/>
											</strong>
										</td>
										<td class="formItem">
											<xsl:for-each select="v3:asSpecializedKind">
												<xsl:value-of select="v3:generalizedMaterialKind/v3:code/@displayName"/>
												<xsl:if test="contains(v3:generalizedMaterialKind/v3:code/@displayName,'[EPC]')">
													<xsl:value-of select="concat('(', v3:generalizedMaterialKind/v3:name[@use='L'], ')')"/>
												</xsl:if>
												<xsl:call-template name="printSeperator"/>
											</xsl:for-each>
										</td>
									</tr>
								</xsl:for-each>
							</tbody>
						</table>
					</td>
				</tr>
			</tbody>
		</table>
	</xsl:if>
</xsl:template>

</xsl:transform>