SitemapBuilder
===========================

A "Proof of Concept" Sitemap.xml generator built on ColdFusion 10 and jSoup that will scrape all absolute links from a supplied website address that match the base href and output a Sitemap.xml file containing the collected links.

Becuase of how many links that could be, use at your own risk. Preferably in a dev environment first.

This POC is based on the LinkScraper repository.

This version requires ColdFusion 10 or the Railo equivalent.

The example call in index.cfm grabs the raw return from the createSitemap() method in SitemapBuilder.cfc which returns a struct containing execution time, build status and a array of collected links; as well as generates the xml file in the root folder by default.

The init() method allows for an array of values to be passed in as filters against what to return.

NOTE: Filters are your friend as in some cases you could be thrown into the equivalent of a infinite loop. Imagine scraping a calender app with links to future and past dates. Ouch ;)
