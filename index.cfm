<cfsetting requesttimeout="50000">

<h1>SitemapBuilder : Sitemap Generator Built on ColdFusion &amp; jSoup</h1>

<cfset siteAddress = "">

<cfscript>
	writeDump(createObject("component", "SitemapBuilder").init(website = siteAddress, filter = [chr(35)]).createSitemap());
</cfscript>