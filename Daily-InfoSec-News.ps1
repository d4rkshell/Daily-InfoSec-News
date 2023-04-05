# Force TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get Atom Feed for TheRegister Security
$ElReg = Invoke-WebRequest -Uri "https://www.theregister.com/security/headlines.atom" -UseBasicParsing -ContentType "application/xml"

If ($ElReg.StatusCode -ne "200") {
    # Feed failed to respond.
    Write-Host "Message: $($ElReg.StatusCode) $($ElReg.StatusDescription)"
}

# Get RSS feed for ZDNet Security
$ZDNet = Invoke-WebRequest -Uri "https://www.zdnet.com/topic/security/rss.xml" -UseBasicParsing -ContentType "application/xml"

If ($ZDNet.StatusCode -ne "200") {
    # Feed fails to respond
    Write-Host "Message: $($ZDNet.StatusCode) $($ZDNet.StatusDescription)"
}

# Get RSS feed for KrebsOnSecurity
$Krebs = Invoke-WebRequest -Uri "https://krebsonsecurity.com/feed/" -UseBasicParsing -ContentType "application/xml"

If ($Krebs.StatusCode -ne "200") {
    # Feed failed to respond.
    Write-Host "Message: $($Krebs.StatusCode) $($Krebs.StatusDescription)"
}

# Get RSS feed for TheHackerNews
$THN = Invoke-WebRequest -Uri "https://feeds.feedburner.com/TheHackersNews?format=xml" -UseBasicParsing -ContentType "application/xml"

If ($THN.StatusCode -ne "200") {
    # Feed failed to respond.
    Write-Host "Message: $($THN.StatusCode) $($THN.StatusDescription)"
}

# Get RSS feed for ThreatPost
$TP = Invoke-WebRequest -Uri "https://threatpost.com/feed/" -UseBasicParsing -ContentType "application/xml"

If ($TP.StatusCode -ne "200") {
    # Feed failed to respond.
    Write-Host "Message: $($TP.StatusCode) $($TP.StatusDescription)"
}

# Set feed content
$ElRegFeedXml = [xml]$ElReg.Content
$ZDNetFeedXml = [xml]$ZDNet.Content
$KrebsFeedXml = [xml]$Krebs.Content
$THNFeedXml = [xml]$THN.Content
$TPFeedXml = [xml]$TP.Content
$Now = Get-Date

# Extract TheRegister Security articles updated within the last 26 hours
$items = $ElRegFeedXml.feed.entry

$ElRegNews = ForEach ($item in $items) {
    If (($Now - [datetime]$item.updated).TotalMinutes -le 1560) {
        $title = $item.title.'#text'
        $link = $item.link.href
        $desc = $item.summary.'#text'
        $updated = [datetime]$item.updated
        $source = $ElRegFeedXml.feed.title

        [PSCustomObject]@{title=$title;link=$link;source=$source;updated=$updated}
    }
}
$ElRegNews | Select-Object -Property Title, Link, Source, Updated #| Out-GridView

# Extract ZDNet Security articles updated within the last 26 hours
$items = $ZDNetFeedXml.rss.channel.Item

$ZDNetNews = ForEach ($item in $items) {
    If (($Now - [datetime]$item.pubDate).TotalMinutes -le 1560) {
        $title = $item.title
        $link = $item.link
        $desc = $item.description
        $updated = [datetime]$item.pubDate
        $source = $ZDNetFeedXml.rss.channel.generator + " " + $ZDNetFeedXml.rss.channel.category

        [PSCustomObject]@{title=$title;link=$link;source=$source;updated=$updated}
    }
}
$ZDNetNews | Select-Object -Property Title, Link, Source, Updated | Out-GridView

# Extract KrebsOnSecurity articles updated within the last 26 hours
$items = $KrebsFeedXml.rss.channel.item

$KrebsNews = ForEach ($item in $items) {
    If (($Now - [datetime]$item.pubDate).TotalMinutes -le 1560) {
        $title = $item.title
        $link = $item.link
        $desc = $item.description
        $updated = [datetime]$item.pubDate
        $source = $KrebsFeedXml.rss.channel.title

        [PSCustomObject]@{title=$title;link=$link;source=$source;updated=$updated}
    }
}
$KrebsNews | Select-Object -Property Title, Link, Source, Updated #| Out-GridView

# Extract TheHackerNews articles updated within the last 30 hours
$items = $THNFeedXml.rss.channel.Item

$THNNews = ForEach ($item in $items) {
    $item.link = $item.link -replace "http://", "https://"
    $time = $item.pubDate -replace '.{4}$'
    $time = $time.substring(5)
    If (($Now - [datetime]$time).TotalMinutes -le 1800) {
        $title = $item.title
        $link = $item.link
        $desc = $item.description
        $updated = $time
        $source = $THNFeedXml.rss.channel.title

        [PSCustomObject]@{title=$title;link=$link;source=$source;updated=$time}
    }
}
$THNnews | Select-Object -Property Title, Link, Source, Updated #| Out-GridView

# Extract ThreatPost articles updated within the last 26 hours
$items = $TPFeedXml.rss.channel.Item

$TPNews = ForEach ($item in $items) {
    If (($Now - [datetime]$item.pubDate).TotalMinutes -le 1560) {
        $title = $item.title
        $link = $item.link
        $updated = [datetime]$item.pubDate
        $source = $TPFeedXml.rss.channel.title

        [PSCustomObject]@{title=$title;link=$link;source=$source;updated=$updated}
    }
}
$TPNews | Select-Object -Property Title, Link, Source, Updated #| Out-GridView

# CSS 2.0 styling
$css = @'
<style>
table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

tr:nth-child(even) {
  background-color: #dddddd;
}
</style>
'@

If ($ElRegNews.Count -eq 0 -and $ZDNetNews.Count -eq 0 -and $KrebsNews.Count -eq 0 -and $THNNews.Count -eq 0 -and $TPNews.Count -eq 0) {
    #Write-Host "nothing to report"
    $emailNoNews = @{
        To         = "email-address-here"
        From       = "email-address-here"
        Subject    = "Security News: " + $(Get-Date -UFormat "%A %d %B %Y")
        Body       = "<span style='font-family:Calibri;font-size:11pt'>" + "Hello xxxxxxx" + "<br><br>" + "Nothing to report at the moment, check back tomorrow." + "<br><br>" + "</span>" | Out-String
        BodyAsHtml = $true
        SmtpServer = "smtp-server-here"
    }
    Send-MailMessage @emailNoNews
} else {
    $emailNewsBody = $ElRegNews + $ZDNetNews + $KrebsNews + $THNnews + $TPNews | ConvertTo-Html -Head $css

    # Replace some dodgy encodings
    $emailNewsBody = $emailNewsBody -replace "&#226;", "-"
    $emailNewsBody = $emailNewsBody -replace "&#194;", ""
    $emailNewsBody = $emailNewsBody -replace "&#163;", "`£"
    $emailNewsBody = $emailNewsBody -replace "&lt;i&gt;", ""
    $emailNewsBody = $emailNewsBody -replace "&lt;/i&gt;", ""
    $emailNewsBody = $emailNewsBody -replace "&#8216;", "'"
    $emailNewsBody = $emailNewsBody -replace "&#8217;", "'"

    # Send email
    $emailNews = @{
        To         = "email-address-here"
        From       = "email-address-here"
        Subject    = "Security News: " + $(Get-Date -UFormat "%A %d %B %Y")
        Body       = "<span style='font-family:Calibri;font-size:11pt'>" + "Hello xxxxxxx" + "<br><br>" + "Please find below a selection of Security news from the past 24 hours: " + "<br><br>" + $emailNewsBody + "</span>" | Out-String
        BodyAsHtml = $true
        SmtpServer = "smtp-server-here"
    }
    Send-MailMessage @emailNews
}