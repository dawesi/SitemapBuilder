component name="SitemapBuilder"
	output="false"
{
	public any function init(required website = "", array filter = []) {
		VARIABLES.website = ARGUMENTS.website;
		VARIABLES.filter = ARGUMENTS.filter;

		return THIS;
	}

	public struct function createSitemap(string path = expandPath("./Sitemap.xml"), string changefreq = "monthly", numeric priority = 0.8)
		output="false"
	{
		var startTime = getTickCount();
		var links = [];
		var data = var link = "";
		var result = {status: "", urls: [], file: "", time: 0};

		try {
			links = scrapeLinks();
			savecontent variable="data" {
				writeOutput('
					<?xml version="1.0" encoding="UTF-8"?>
					<urlset
						xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
						xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
						xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
						http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
				');
				for (link in links) {
					writeOutput('
						<url>
						  <loc>#link#</loc>
						  <changefreq>#ARGUMENTS.changefreq#</changefreq>
						  <priority>#ARGUMENTS.priority#</priority>
						</url>
					');
				}
				writeOutput('
					</urlset>
				');
			}
			fileWrite(ARGUMENTS.path, data);
			result = {
				status: "Done!",
				urls: links,
				file: ARGUMENTS.path,
				time: (getTickCount() - startTime) / 1000
			};
		}
		catch(any e) {
			result.status = e.message;
		}

		return result;
	}

	public array function scrapeLinks()
		output="false"
	{
		var jsoup = createObject("java", "org.jsoup.Jsoup");
		var link = var href = var value = "";
		var lengths = {};
		var links = var lts = var ltns = var match = var result = [];
		var i = 0;

        if (!reFindNoCase(left(VARIABLES.website, 7), "http://")) {
            VARIABLES.website = "http://" & VARIABLES.website;
        }
        links = jsoup.connect(VARIABLES.website).timeout(100000).get().select("a[href]");
		//Initial pass over first page to gather starting links to scrape.
		for (href in links) {
			link = href.attr("abs:href");
			if (find(VARIABLES.website, link) && !urlFilter(value = link, filterList = VARIABLES.filter) && !arrayContains(lts, link)) {
				arrayAppend(lts, link);
			}
		}
		//Pass over each link URL initially collected and continue to scrape "unique" links found on those pages.
		while (arrayLen(lts)) {
			arrayEach(
				lts,
				function(x) {
					if (!urlFilter(value = x, filterList = VARIABLES.filter) && !arrayContains(ltns, x)) {
						ltns.append(x);
						//"ignoreContentType" is used in case we hit a non-HTML page like XML.
						match = jsoup.connect(x).timeout(100000).ignoreContentType(true).get().select("a[href]");
						for (href in match) {
							link = href.attr("abs:href");
							if (find(VARIABLES.website, link) && !arrayContains(ltns, link)) {
								arrayAppend(lts, link);
							}
						}
					}
					arrayDelete(lts, x);
				}
			);
		}
		//Attempt a more ordered sort for the final array of urls.
		for (i = 1; i <= arrayLen(ltns); i++) {
    		lengths[i] = listLen(ltns[i], "/");
		}
		lengths = structSort(lengths, "numeric", "asc");
		for (value in lengths) {
    		arrayAppend(result, ltns[value]);
		}

		return result;
	}

	private boolean function urlFilter(required string value = "", required array filterList = [])
		output="false"
	{
		var item = "";
		var result = false;

		for (item in ARGUMENTS.filterList) {
			if (find(item, ARGUMENTS.value)) {
				result = true;
			}
		}

		return result;
	}
}
