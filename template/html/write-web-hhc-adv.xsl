<?xml version="1.0" encoding="windows-1252"?>
<xsl:stylesheet
    version="1.0"
    xmlns:ext="urn:gehtsoft-exslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" />
    <xsl:namespace-alias stylesheet-prefix="ext" result-prefix="#default"/>
    <xsl:template match="/" >
<!--Sitemap 1.0-->
<html><head><title>Content</title>
<style type="text/css">
<xsl:text>
<![CDATA[
/* Put this inside a @media qualifier so Netscape 4 ignores it */
@media screen, print {
    /* Turn off list bullets */
    ul.mktree  li { list-style: none; }
    /* Control how "spaced out" the tree is */
    ul.mktree, ul.mktree ul , ul.mktree li { margin-left:10px; padding:0px; font-family : Verdana, Trebuchet MS, Arial; font-size: 12pt; }
    /* Provide space for our own "bullet" inside the LI */
    ul.mktree  li           .bullet { padding-left: 15px; }
    /* Show "bullets" in the links, depending on the class of the LI that the link's in */
    ul.mktree  li.liOpen    .bullet { cursor: pointer; background: url(menu/minus.png)  center left no-repeat; }
    ul.mktree  li.liClosed  .bullet { cursor: pointer; background: url(menu/plus.png)   center left no-repeat; }
    ul.mktree  li.liBullet  .bullet { cursor: default; background: url(menu/bullet.png) center left no-repeat; }
    /* Sublists are visible or not based on class of parent LI */
    ul.mktree  li.liOpen    ul { display: block; }
    ul.mktree  li.liClosed  ul { display: none; }

    a.select {font-weight:bold;}
}
body
{
    background-color: #f1f1f1;
    font-size: 13px;
}
div.HelpCaption
{
    background-image: url(pageImages/header-bg.gif);
    height: 43px;
}
A:link
{
    color:#0068be;
}
]]>
</xsl:text>
</style>
</head>
<script language="javascript" type="text/javascript">
function getQueryParam(name) {
<xsl:text disable-output-escaping="yes">
<![CDATA[
  var query = window.parent.location.search.substring(1);
  var params = query.split("&");
  for (var i = 0;i < params.length; i++) {
    var pair = params[i].split("=");
    if (pair[0] == name) {
      return pair[1];
    }
  }
  return null;
}
addEvent(window,"load",convertTrees);
var src = getQueryParam('key') || 'index.html';
parent.docframe.location = src;

// ===================================================================
// Author: Matt Kruse <matt@mattkruse.com>
// WWW: http://www.mattkruse.com/
//
// NOTICE: You may use this code for any purpose, commercial or
// private, without any further permission from the author. You may
// remove this notice from your final code if you wish, however it is
// appreciated by the author if at least my web site address is kept.
//
// You may *NOT* re-distribute this code in any way except through its
// use. That means, you can include it in your product, or your web
// site, or any other form where the code is actually being used. You
// may not put the plain javascript up on your site for download or
// include it in your javascript libraries for download.
// If you wish to share this code with others, please just point them
// to the URL instead.
// Please DO NOT link directly to my .js files from your site. Copy
// the files to your server and use them there. Thank you.
// ===================================================================

// HISTORY
// ------------------------------------------------------------------
// December 9, 2003: Added script to the Javascript Toolbox
// December 10, 2003: Added the preProcessTrees variable to allow user
//      to turn off automatic conversion of UL's onLoad
// March 1, 2004: Changed it so if a <li> has a class already attached
//      to it, that class won't be erased when initialized. This allows
//      you to set the state of the tree when painting the page simply
//      by setting some <li>'s class name as being "liOpen" (see example)
/*
This code is inspired by and extended from Stuart Langridge's aqlist code:
        http://www.kryogenix.org/code/browser/aqlists/
        Stuart Langridge, November 2002
        sil@kryogenix.org
        Inspired by Aaron's labels.js (http://youngpup.net/demos/labels/)
        and Dave Lindquist's menuDropDown.js (http://www.gazingus.org/dhtml/?id=109)
*/
function addEvent(o,e,f){if(o.addEventListener){o.addEventListener(e,f,true);return true;}else if(o.attachEvent){return o.attachEvent("on"+e,f);}else{return false;}}
function setDefault(name,val){if(typeof(window[name])=="undefined" || window[name]==null){window[name]=val;}}
function expandTree(treeId){var ul = document.getElementById(treeId);if(ul == null){return false;}expandCollapseList(ul,nodeOpenClass);}
function collapseTree(treeId){var ul = document.getElementById(treeId);if(ul == null){return false;}expandCollapseList(ul,nodeClosedClass);}
function expandToItem(treeId,itemId){var ul = document.getElementById(treeId);if(ul == null){return false;}var ret = expandCollapseList(ul,nodeOpenClass,itemId);if(ret){var o = document.getElementById(itemId);if(o.scrollIntoView){o.scrollIntoView(false);}}}
function expandCollapseList(ul,cName,itemId){if(!ul.childNodes || ul.childNodes.length==0){return false;}for(var itemi=0;itemi<ul.childNodes.length;itemi++){var item = ul.childNodes[itemi];if(itemId!=null && item.id==itemId){return true;}if(item.nodeName == "LI"){var subLists = false;for(var sitemi=0;sitemi<item.childNodes.length;sitemi++){var sitem = item.childNodes[sitemi];if(sitem.nodeName=="UL"){subLists = true;var ret = expandCollapseList(sitem,cName,itemId);if(itemId!=null && ret){item.className=cName;return true;}}}if(subLists && itemId==null){item.className = cName;}}}}
function convertTrees(){setDefault("treeClass","mktree");setDefault("nodeClosedClass","liClosed");setDefault("nodeOpenClass","liOpen");setDefault("nodeBulletClass","liBullet");setDefault("nodeLinkClass","bullet");setDefault("preProcessTrees",true);if(preProcessTrees){if(!document.createElement){return;}uls = document.getElementsByTagName("ul");for(var uli=0;uli<uls.length;uli++){var ul=uls[uli];if(ul.nodeName=="UL" && ul.className==treeClass){processList(ul);}}}}
function processList(ul){if(!ul.childNodes || ul.childNodes.length==0){return;}for(var itemi=0;itemi<ul.childNodes.length;itemi++){var item = ul.childNodes[itemi];if(item.nodeName == "LI"){var subLists = false;for(var sitemi=0;sitemi<item.childNodes.length;sitemi++){var sitem = item.childNodes[sitemi];if(sitem.nodeName=="UL"){subLists = true;processList(sitem);}}var s= document.createElement("SPAN");var t= '\u00A0';s.className = nodeLinkClass;if(subLists){if(item.className==null || item.className==""){item.className = nodeClosedClass;}if(item.firstChild.nodeName=="#text"){t = t+item.firstChild.nodeValue;item.removeChild(item.firstChild);}s.onclick = function(){this.parentNode.className =(this.parentNode.className==nodeOpenClass) ? nodeClosedClass : nodeOpenClass;return false;}}else{item.className = nodeBulletClass;s.onclick = function(){return false;}}s.appendChild(document.createTextNode(t));item.insertBefore(s,item.firstChild);}}}

// Auxilary function to support "expand tree on right frame navigation" functionality
var selectedItem = null;

function getFileFromURL(url) {var f = url.split('/');return f[f.length - 1];}
function createIds() {var lis = document.getElementsByTagName("li");for(var lisi=0;lisi<lis.length;lisi++) {var li = lis[lisi];if (li.firstChild.nodeName == "A") {var h = li.firstChild.href;if (h) {li.id = getFileFromURL(h);}}}var as = document.getElementsByTagName("a");for(var asi=0;asi<as.length;asi++) {var a = as[asi];a.onclick = function(event) {event = event || window.event;selectLink(event.target);}}}
function selectLink(lnk) {if (selectedItem) {selectedItem.className='';}lnk.className="select";selectedItem=lnk;}
function selectItem(fid, tid) {var id  = getFileFromURL(fid);var tid = tid || id;expandToItem('hhc_tree', tid);window.parent.parent.location.hash = id;var childs = document.getElementById(tid).childNodes;for(var ci=0;ci<childs.length;ci++) {if (childs[ci].nodeName == "A") {selectLink(childs[ci]);}}}
]]>
</xsl:text>
</script>
<body>
<ul class="mktree" id="hhc_tree">
    <xsl:apply-templates select="/root/node" />
    <li><a href="web-hhk.html" target="docframe"><xsl:value-of select="ext:get('_string_index')" /></a></li>
</ul>
<script language="javascript" type="text/javascript">createIds();</script>
</body>
</html>
    </xsl:template>
    <xsl:template match="node">
        <xsl:choose>
        <xsl:when test="count(./@local)>0">
            <li><xsl:element name="a">
                <xsl:attribute name="href"><xsl:value-of select="./@local" /></xsl:attribute>
                <xsl:attribute name="target">docframe</xsl:attribute>
                <xsl:value-of select="./@name" disable-output-escaping="yes" /></xsl:element><xsl:if test="count(./node)>0"><ul><xsl:apply-templates select="./node" /></ul></xsl:if></li>
        </xsl:when>
        <xsl:otherwise>
            <li><xsl:value-of select="./@name" disable-output-escaping="yes" /><xsl:if test="count(./node)>0"><ul><xsl:apply-templates select="./node" /></ul></xsl:if></li>
        </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>