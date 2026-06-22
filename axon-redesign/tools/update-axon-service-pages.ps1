$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$servicePages = Get-Content -LiteralPath "PAGES_ADDED.txt" |
  Where-Object { $_ -match '^[a-z0-9-]+\.html\s+-' } |
  ForEach-Object { ($_ -split '\s+-\s+', 2)[0] }

$newPages = @(
  "website-optimization-audit.html",
  "mobile-app-technical-assistance.html"
)

$excludedFromBulk = @(
  "use-cases.html"
)

$servicePagesForBulk = $servicePages | Where-Object { $_ -notin $excludedFromBulk }

$defaultQuestions = @{
  "Technology & AI Advisory" = @(
    @("Decision", "Not sure which tool is right?", "We compare options in plain business language before you commit time or budget."),
    @("AI fit", "Where can AI actually help?", "We identify useful AI cases for staff, customers, documents, support and operations."),
    @("Risk", "Will this expose private data?", "We review access, data handling, user roles and safer ways to test AI tools."),
    @("Budget", "Are we spending on the wrong thing?", "We help prioritize what matters now and what can wait until the basics are stable."),
    @("Adoption", "Will staff know how to use it?", "We prepare simple workflows, training notes and realistic usage rules."),
    @("Roadmap", "What should we fix first?", "Axon turns the discussion into a practical action list for setup, cleanup and support.")
  )
  "Cloud & Email Solutions" = @(
    @("Email", "Are emails going to spam?", "We check DNS, SPF, DKIM, DMARC, aliases and mailbox settings so mail is trusted."),
    @("Migration", "Can we move without losing mail?", "We plan mail, calendar, contacts and files before changing providers."),
    @("Access", "Who can access company files?", "We review users, groups, shared drives, permissions and offboarding controls."),
    @("Devices", "Will email work on phones and laptops?", "We configure accounts, apps and security settings across common devices."),
    @("Licenses", "Are we paying for the right plan?", "Axon checks licenses against actual usage and business needs."),
    @("Backup", "Can we recover deleted emails or files?", "We explain retention, backup options and realistic recovery limits.")
  )
  "Websites & Digital Presence" = @(
    @("Search", "Why is my website not found on Google?", "We check indexing, page titles, descriptions, sitemap, robots and Search Console basics."),
    @("Analytics", "Do I have proper tracking installed?", "We verify Google Analytics, Tag Manager, conversion events and traffic data quality."),
    @("Content", "Do my pages explain the service clearly?", "We review headings, service copy, calls to action and trust signals."),
    @("Mobile", "Does the site work properly on phones?", "We check mobile layout, menu behavior, forms, speed and visible contact paths."),
    @("Enquiry", "Where do form leads actually go?", "We test forms, email routing, WhatsApp links, SMTP and spam protection."),
    @("AI build", "AI made the page, but is it ready?", "We complete hosting, SSL, DNS, backend, integrations and handover checks.")
  )
  "Hosting, Domains & Infrastructure" = @(
    @("DNS", "Is the domain pointing to the right place?", "We check nameservers, DNS records, redirects and propagation issues."),
    @("SSL", "Why is the site showing not secure?", "We configure SSL, redirects and certificate renewal so visitors see a trusted site."),
    @("Hosting", "Which hosting is enough for this site?", "We match cPanel, cloud, VPS or app hosting to the website and support needs."),
    @("Email", "Will changing DNS break email?", "We review MX, SPF, DKIM and existing mail services before changes."),
    @("Backup", "Can we restore the site if it breaks?", "Axon checks backup frequency, restore access and emergency recovery steps."),
    @("Deploy", "How do we publish code from AI tools?", "We deploy Lovable, Bolt, Replit or custom code with domain, SSL and monitoring.")
  )
  "AI & Business Automation" = @(
    @("Workflow", "Which manual task should we automate first?", "We find repeatable work in emails, forms, sheets, CRM and support flows."),
    @("Data", "What information can AI safely use?", "We prepare approved documents, permissions and review steps before automation."),
    @("Accuracy", "How do we stop wrong AI answers?", "We add human review, testing prompts, logs and boundaries for safer output."),
    @("Integration", "Can AI connect to my existing tools?", "We connect forms, email, spreadsheets, WhatsApp, CRM, files and APIs where practical."),
    @("Private AI", "Do we need local or private AI?", "Axon explains when private AI, Ollama or controlled workspaces make sense."),
    @("Support", "Who maintains the automation later?", "We document the workflow, monitor failures and adjust as business processes change.")
  )
  "Security, Recovery & Performance" = @(
    @("Hack", "Has my website been hacked?", "We check suspicious files, redirects, admin users, malware warnings and search results."),
    @("Cleanup", "Can the site be cleaned safely?", "We remove malware, update weak components and protect the site after cleanup."),
    @("Speed", "Why is my website slow?", "We review hosting, images, scripts, caching, database load and Core Web Vitals basics."),
    @("Backup", "Do we have a working backup?", "We test whether backups exist, whether they can restore, and how old they are."),
    @("Monitoring", "Will we know if the site goes down?", "We set up uptime checks, health checks and alert paths for support."),
    @("Prevention", "What should we fix before it breaks?", "Axon prioritizes updates, access, SSL, backups and performance risks.")
  )
}

$pageQuestions = @{
  "corporate-websites.html" = @(
    @("Search", "Why is my website not found on Google?", "We check indexing, titles, descriptions, sitemap, robots and Search Console setup."),
    @("Forms", "Why are enquiries not reaching me?", "We test forms, SMTP, business email, spam protection and WhatsApp handover."),
    @("Trust", "Does the page explain my business clearly?", "We improve service copy, headings, proof points, contact paths and credibility signals."),
    @("Mobile", "Does it look right on phones?", "We review mobile layout, menu behavior, tap targets, speed and visible contact options."),
    @("Analytics", "Can I measure visits and leads?", "We install or verify Analytics, Tag Manager and simple conversion tracking."),
    @("Launch", "Is the site ready to publish?", "Axon checks hosting, DNS, SSL, backups, security and post-launch support.")
  )
  "websites-digital-presence.html" = @(
    @("Search", "Why is my website not appearing on Google?", "We check crawling, indexing, metadata, sitemap, robots and Search Console basics."),
    @("Analytics", "Do I know what visitors are doing?", "We verify Analytics, Tag Manager, events, forms and lead source tracking."),
    @("Content", "Do customers understand the offer?", "We review homepage, service pages, calls to action and proof points."),
    @("Local", "Are my business details consistent?", "We check name, address, phone, links and basic local presence signals."),
    @("Speed", "Is the site too slow for users?", "We review images, scripts, hosting, cache and mobile performance."),
    @("Next step", "Should I do SEO or fix basics first?", "We organize the site and track organic search for a month before judging SEO/SEM spend.")
  )
  "website-monitoring-health-checks.html" = @(
    @("Uptime", "Will we know if the site goes down?", "We set up uptime alerts and practical escalation paths."),
    @("Search", "Did Google indexing suddenly drop?", "We check Search Console signals, sitemap access and important page availability."),
    @("Forms", "Are forms still sending leads?", "We test forms, SMTP, spam filtering and recipient routing."),
    @("Security", "Are there warning signs of compromise?", "We watch for malware alerts, suspicious redirects and unexpected file changes."),
    @("Speed", "Is the site getting slower?", "We review performance trends, hosting load and heavy page assets."),
    @("Report", "What should we fix this month?", "Axon summarizes issues into a simple priority list for maintenance.")
  )
  "application-deployment.html" = @(
    @("Publish", "AI built it, but how do I put it online?", "We deploy Lovable, Bolt, Replit or custom code to suitable hosting."),
    @("Domain", "Can it use my real domain?", "We configure DNS, SSL, redirects and launch checks."),
    @("Backend", "Does it need login or a database?", "We set up backend services, database access and environment variables where needed."),
    @("Email", "Will forms and notifications work?", "We configure SMTP, API keys, sender records and delivery testing."),
    @("Mobile app", "Can an AI-made app be packaged?", "We review whether the build is ready for app-style deployment or needs technical cleanup."),
    @("Support", "Who fixes it after launch?", "Axon documents the setup and supports updates, errors and hosting issues.")
  )
  "business-applications.html" = @(
    @("Process", "What business process should the app handle?", "We map the users, roles, forms, approvals and reports before building."),
    @("AI build", "Can AI generate the first version?", "We help turn AI-made screens into a working tool with data and access control."),
    @("Database", "Where should the data live?", "We advise on simple databases, cloud tools or hosted application backends."),
    @("Login", "Who can access each area?", "We configure user roles, admin access and safer account handover."),
    @("Integration", "Can it connect to email, WhatsApp or CRM?", "We link practical services and test the full workflow."),
    @("Mobile", "Should it be a web app or mobile app?", "Axon explains when a responsive web app is enough and when app packaging needs specialist work.")
  )
}

function Get-PageCategory {
  param([string]$Html)
  $match = [regex]::Match($Html, '<span class="axon-standard-kicker">([^<]+)</span>')
  if ($match.Success) {
    return $match.Groups[1].Value -replace '&amp;', '&'
  }
  return "Websites & Digital Presence"
}

function New-QuestionSection {
  param(
    [string]$PageName,
    [string]$Category
  )

  $cards = if ($pageQuestions.ContainsKey($PageName)) { $pageQuestions[$PageName] } else { $defaultQuestions[$Category] }
  if (-not $cards) { $cards = $defaultQuestions["Technology & AI Advisory"] }

  $htmlCards = ($cards | ForEach-Object {
    '<article class="axon-standard-card"><span>{0}</span><h3>{1}</h3><p>{2}</p></article>' -f $_[0], $_[1], $_[2]
  }) -join "`r`n"

  return @"
<div class="axon-standard-section">
<div class="axon-standard-section-head"><h2>Top questions clients ask</h2></div>
<div class="axon-standard-card-grid">
$htmlCards
</div>
"@
}

function Update-QuestionCards {
  param([string]$PageName)

  $html = Get-Content -Raw -LiteralPath $PageName
  $category = Get-PageCategory $html
  $sectionStart = $html.IndexOf('<div class="axon-standard-section">')
  if ($sectionStart -lt 0) { return }

  $gridStart = $html.IndexOf('<div class="axon-standard-card-grid">', $sectionStart)
  if ($gridStart -lt 0) { return }

  $gridEnd = $html.IndexOf('</div>', $gridStart)
  if ($gridEnd -lt 0) { return }
  $gridEnd += '</div>'.Length

  $headStart = $html.IndexOf('<div class="axon-standard-section-head">', $sectionStart)
  if ($headStart -lt 0 -or $headStart -gt $gridStart) { return }

  $replacement = New-QuestionSection $PageName $category
  $updated = $html.Substring(0, $sectionStart) + $replacement + $html.Substring($gridEnd)
  Set-Content -LiteralPath $PageName -Value $updated -Encoding UTF8
}

foreach ($page in $servicePagesForBulk) {
  if (Test-Path -LiteralPath $page) {
    Update-QuestionCards $page
  }
}

$aiStuckSection = @'
<div class="axon-standard-section">
<div class="axon-standard-section-head"><h2>Built it with AI but stuck?</h2></div>
<div class="axon-standard-card-grid">
<article class="axon-standard-card"><span>SMTP</span><h3>Forms not sending email?</h3><p>We configure business email, SMTP, DNS records and spam protection so enquiries reach you.</p></article>
<article class="axon-standard-card"><span>API</span><h3>Need to connect payment, CRM or WhatsApp?</h3><p>We help connect the site to the right services and test the handover properly.</p></article>
<article class="axon-standard-card"><span>Backend</span><h3>Need login, admin or database?</h3><p>We complete the backend, database, access control and hosting setup when the AI tool stops at the front-end.</p></article>
<article class="axon-standard-card"><span>Hosting</span><h3>Not sure how to publish it?</h3><p>We deploy AI-made sites from tools like Lovable, Bolt, Replit or custom code with domain, SSL, backup and support.</p></article>
<article class="axon-standard-card"><span>Search</span><h3>Why is it not showing on Google?</h3><p>We check page titles, descriptions, sitemap, robots, Search Console and indexing before SEO/SEM spending.</p></article>
<article class="axon-standard-card"><span>Analytics</span><h3>Can we measure visits and leads?</h3><p>We install or verify Analytics, Tag Manager and conversion events so decisions are based on real traffic.</p></article>
</div>
'@

$corp = Get-Content -Raw -LiteralPath "corporate-websites.html"
$builtStart = $corp.IndexOf('<div class="axon-standard-section">', $corp.IndexOf('Built it with AI but stuck?'))
if ($builtStart -ge 0) {
  $builtGridStart = $corp.IndexOf('<div class="axon-standard-card-grid">', $builtStart)
  $builtGridEnd = $corp.IndexOf('</div>', $builtGridStart) + '</div>'.Length
  $builtHeadStart = $corp.IndexOf('<div class="axon-standard-section-head">', $builtStart)
  $corp = $corp.Substring(0, $builtStart) + $aiStuckSection + $corp.Substring($builtGridEnd)
  Set-Content -LiteralPath "corporate-websites.html" -Value $corp -Encoding UTF8
}

function Update-NavAndFooter {
  param([string]$Path)
  $html = Get-Content -Raw -LiteralPath $Path

  $oldWebsiteLinks = @'
<a class="mega-menu-link" href="corporate-websites.html">Corporate Websites</a>
<a class="mega-menu-link" href="website-revamps-modernization.html">Website Revamps &amp; Modernization</a>
<a class="mega-menu-link" href="e-commerce-solutions.html">E-Commerce Solutions</a>
<a class="mega-menu-link" href="customer-member-portals.html">Customer &amp; Member Portals</a>
<a class="mega-menu-link" href="business-applications.html">Business Applications</a>
<a class="mega-menu-link" href="website-maintenance-support.html">Website Maintenance &amp; Support</a>
'@
  $newWebsiteLinks = @'
<a class="mega-menu-link" href="corporate-websites.html">Corporate Websites</a>
<a class="mega-menu-link" href="website-optimization-audit.html">Website Optimization Audit</a>
<a class="mega-menu-link" href="website-revamps-modernization.html">Website Revamps &amp; Modernization</a>
<a class="mega-menu-link" href="e-commerce-solutions.html">E-Commerce Solutions</a>
<a class="mega-menu-link" href="customer-member-portals.html">Customer &amp; Member Portals</a>
<a class="mega-menu-link" href="business-applications.html">Business Applications</a>
<a class="mega-menu-link" href="mobile-app-technical-assistance.html">Mobile App Technical Assistance</a>
<a class="mega-menu-link" href="website-maintenance-support.html">Website Maintenance &amp; Support</a>
'@
  $html = $html.Replace($oldWebsiteLinks, $newWebsiteLinks)

  $oldHelp = '<div class="axon-search-help"><strong>Common help requests</strong><div><a href="websites-digital-presence.html">Website not found on Google</a><a href="website-security.html">Website hacked</a><a href="performance-optimization.html">Website slow</a><a href="website-recovery.html">Website recovery</a><a href="application-deployment.html">AI-made website hosting</a><a href="corporate-hosting.html">cPanel / WHM hosting</a></div></div>'
  $newHelp = '<div class="axon-search-help"><strong>Common help requests</strong><div><a href="website-optimization-audit.html">Website optimization check</a><a href="websites-digital-presence.html">Website not found on Google</a><a href="mobile-app-technical-assistance.html">AI-made mobile app help</a><a href="website-security.html">Website hacked</a><a href="performance-optimization.html">Website slow</a><a href="website-recovery.html">Website recovery</a><a href="application-deployment.html">AI-made website hosting</a><a href="corporate-hosting.html">cPanel / WHM hosting</a></div></div>'
  $html = $html.Replace($oldHelp, $newHelp)

  Set-Content -LiteralPath $Path -Value $html -Encoding UTF8
}

foreach ($page in Get-ChildItem -File -Filter "*.html") {
  Update-NavAndFooter $page.FullName
}

function New-ServicePage {
  param(
    [string]$TemplatePath,
    [string]$OutputPath,
    [string]$Title,
    [string]$Description,
    [string]$Hero,
    [string]$HeroText,
    [string]$HeroAlt,
    [string]$HeroImage,
    [string]$QuestionSection,
    [string]$NoteHeading,
    [string]$NoteText
  )

  $html = Get-Content -Raw -LiteralPath $TemplatePath
  $templateTitle = [regex]::Match($html, '<title>[^<]+</title>').Value
  $html = $html.Replace($templateTitle, "<title>$Title | Axon 1ProIT</title>")
  $html = [regex]::Replace($html, '<meta content="[^"]*" name="description"/>', "<meta content=""$Description"" name=""description""/>", 1)
  $html = [regex]::Replace($html, '<link rel="canonical" href="https://axon.com.sg/[^"]+"/>', "<link rel=""canonical"" href=""https://axon.com.sg/$OutputPath""/>")
  $html = [regex]::Replace($html, '<meta property="og:url" content="https://axon.com.sg/[^"]+"/>', "<meta property=""og:url"" content=""https://axon.com.sg/$OutputPath""/>")
  $html = [regex]::Replace($html, '<meta property="og:title" content="[^"]*"/>', "<meta property=""og:title"" content=""$Title | Axon 1ProIT""/>")
  $html = [regex]::Replace($html, '<meta property="og:description" content="[^"]*"/>', "<meta property=""og:description"" content=""$Description""/>")
  $html = [regex]::Replace($html, '<meta name="twitter:url" content="https://axon.com.sg/[^"]+"/>', "<meta name=""twitter:url"" content=""https://axon.com.sg/$OutputPath""/>")
  $html = [regex]::Replace($html, '<meta name="twitter:title" content="[^"]*"/>', "<meta name=""twitter:title"" content=""$Title | Axon 1ProIT""/>")
  $html = [regex]::Replace($html, '<meta name="twitter:description" content="[^"]*"/>', "<meta name=""twitter:description"" content=""$Description""/>")

  $heroPattern = '<div class="axon-standard-hero">.*?</div>\s*</div>\s*<div class="axon-standard-section">'
  $newHero = @"
<div class="axon-standard-hero">
<div>
<span class="axon-standard-kicker">Websites & Digital Presence</span>
<h1>$Hero</h1>
<p>$HeroText</p>
<div class="axon-standard-actions"><a href="contact.html">Talk to Axon</a></div>
</div>
<div class="axon-standard-visual"><img alt="$HeroAlt" src="$HeroImage"/></div>
</div>
<div class="axon-standard-section">
"@
  $heroRegex = [System.Text.RegularExpressions.Regex]::new($heroPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  $html = $heroRegex.Replace($html, $newHero, 1)

  $sectionPattern = '<div class="axon-standard-section-head">.*?<div class="axon-standard-note">.*?</div>\s*</div>'
  $section = @"
<div class="axon-standard-section-head"><h2>Top questions clients ask</h2></div>
<div class="axon-standard-card-grid">
$QuestionSection
</div>
<div class="axon-standard-note"><h2>$NoteHeading</h2><p>$NoteText</p></div>
</div>
"@
  $sectionRegex = [System.Text.RegularExpressions.Regex]::new($sectionPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  $html = $sectionRegex.Replace($html, $section, 1)
  Set-Content -LiteralPath $OutputPath -Value $html -Encoding UTF8
}

$optimizationCards = @'
<article class="axon-standard-card"><span>Indexing</span><h3>Why is my website not found on Google?</h3><p>We check Search Console, sitemap, robots, crawl access and whether important pages are indexed.</p></article>
<article class="axon-standard-card"><span>Tags</span><h3>Are my titles and descriptions correct?</h3><p>We review page titles, meta descriptions, headings, canonical tags and social sharing previews.</p></article>
<article class="axon-standard-card"><span>Analytics</span><h3>Is Google Analytics tracking properly?</h3><p>We verify Analytics, Tag Manager, page views, events, lead forms and conversion signals.</p></article>
<article class="axon-standard-card"><span>Content</span><h3>Do my pages match what people search?</h3><p>We organize service pages, internal links, calls to action and basic search intent before paid SEO/SEM.</p></article>
<article class="axon-standard-card"><span>Technical</span><h3>Is the site technically healthy?</h3><p>We check mobile layout, speed basics, image weight, broken links, SSL and redirects.</p></article>
<article class="axon-standard-card"><span>Measure</span><h3>Should we watch organic search first?</h3><p>We fix the basics and review roughly one month of organic search data before judging SEO/SEM tools.</p></article>
'@

New-ServicePage `
  -TemplatePath "websites-digital-presence.html" `
  -OutputPath "website-optimization-audit.html" `
  -Title "Website Optimization Audit" `
  -Description "Website optimization checks for tags, analytics, Search Console, indexing, mobile speed and organic search readiness before SEO or SEM spend." `
  -Hero "Website Optimization Audit" `
  -HeroText "Before spending on SEO or SEM, Axon checks whether the website basics are measurable, crawlable and ready: tags, analytics, Search Console, sitemap, speed, mobile layout and enquiry tracking." `
  -HeroAlt "Website analytics and search optimization review" `
  -HeroImage "assets/legacy/corporate-next-website.png" `
  -QuestionSection $optimizationCards `
  -NoteHeading "SEO and SEM only make sense after the website basics are working." `
  -NoteText "Axon helps organize the site, verify tags and analytics, connect Search Console and observe organic search signals for about one month. This gives a cleaner baseline before deciding whether specialist SEO, SEM or paid tools are worth the spend."

$mobileCards = @'
<article class="axon-standard-card"><span>Scope</span><h3>Do I really need a mobile app?</h3><p>We first check whether a responsive web app or portal can solve the need faster and with less maintenance.</p></article>
<article class="axon-standard-card"><span>AI build</span><h3>AI generated an app, but will it work?</h3><p>We review the code, screens, data flow, API keys and backend requirements before any launch plan.</p></article>
<article class="axon-standard-card"><span>Backend</span><h3>Where will login and data live?</h3><p>We help with databases, authentication, storage, admin access and environment setup.</p></article>
<article class="axon-standard-card"><span>Publish</span><h3>Can it be packaged or deployed?</h3><p>Axon assists with technical readiness, hosting, test builds and handover to app specialists when store release is needed.</p></article>
<article class="axon-standard-card"><span>Integration</span><h3>Can it connect to payments, email or WhatsApp?</h3><p>We configure practical APIs, notifications, SMTP and workflow connections around the app.</p></article>
<article class="axon-standard-card"><span>Support</span><h3>Who will maintain it after AI creates it?</h3><p>We document setup, review risks, monitor failures and support practical fixes as requirements change.</p></article>
'@

New-ServicePage `
  -TemplatePath "business-applications.html" `
  -OutputPath "mobile-app-technical-assistance.html" `
  -Title "Mobile App Technical Assistance" `
  -Description "Technical assistance for AI-made mobile app ideas, app backends, APIs, login, databases, hosting and deployment readiness." `
  -Hero "Mobile App Technical Assistance" `
  -HeroText "Axon does not position itself as a specialist mobile app development agency. But when AI tools create an app idea, we help clients understand the technical setup: backend, login, database, API, hosting, testing and realistic next steps." `
  -HeroAlt "Mobile app technical planning and backend assistance" `
  -HeroImage "assets/legacy/real-business-apps-team-asian.png" `
  -QuestionSection $mobileCards `
  -NoteHeading "AI can create an app draft. Axon helps check whether it can become a working system." `
  -NoteText "We assist with the technical pieces around the app and advise when a dedicated mobile app specialist is required for native development, app store release or advanced device features."

$pagesAdded = Get-Content -Raw -LiteralPath "PAGES_ADDED.txt"
if ($pagesAdded -notmatch 'website-optimization-audit\.html') {
  $pagesAdded = $pagesAdded.Replace("website-maintenance-support.html - Website Maintenance & Support", "website-maintenance-support.html - Website Maintenance & Support`r`nwebsite-optimization-audit.html - Website Optimization Audit`r`nmobile-app-technical-assistance.html - Mobile App Technical Assistance")
}
if ($pagesAdded -notmatch 'credit-top-up\.html') {
  $pagesAdded = $pagesAdded.Replace("use-cases.html - Use Cases", "use-cases.html - Use Cases`r`ncredit-top-up.html - Credit Top-up")
}
Set-Content -LiteralPath "PAGES_ADDED.txt" -Value $pagesAdded -Encoding UTF8

$htmlFiles = Get-ChildItem -File -Filter "*.html" | Select-Object -ExpandProperty Name | Sort-Object
$sitemapLines = @(
  '<?xml version="1.0" encoding="UTF-8"?>',
  '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
)
foreach ($file in $htmlFiles) {
  $loc = if ($file -eq "index.html") { "https://axon.com.sg/" } else { "https://axon.com.sg/$file" }
  $priority = if ($file -eq "index.html") { "1.0" } elseif ($file -in @("contact.html","corporate-websites.html","websites-digital-presence.html","website-optimization-audit.html")) { "0.9" } else { "0.8" }
  $sitemapLines += "  <url><loc>$loc</loc><changefreq>weekly</changefreq><priority>$priority</priority></url>"
}
$sitemapLines += '</urlset>'
Set-Content -LiteralPath "sitemap.xml" -Value ($sitemapLines -join "`r`n") -Encoding UTF8

Write-Host "Updated $($servicePagesForBulk.Count) service pages, added $($newPages.Count) new pages, refreshed nav/footer and sitemap."
