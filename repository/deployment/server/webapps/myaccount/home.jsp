<!--
~    Copyright (c) 2022, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
~
~    This software is the property of WSO2 Inc. and its suppliers, if any.
~    Dissemination of any information or reproduction of any material contained
~    herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
~    You may not alter or remove any copyright or other notice from copies of this content."
-->

<%@ page import="static org.wso2.carbon.identity.core.util.IdentityUtil.getServerURL" %>
<%@ page import="static org.wso2.carbon.utils.multitenancy.MultitenantConstants.TENANT_AWARE_URL_PREFIX"%>
<%@ page import="static org.wso2.carbon.utils.multitenancy.MultitenantConstants.SUPER_TENANT_DOMAIN_NAME"%>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<% String is_cookiepro_enabled = System.getenv("is_cookiepro_enabled"); %>
<% String initialScriptType = (Boolean.TRUE.toString()).equals(is_cookiepro_enabled) ? "text/plain" : "text/javascript"; %>
<% String cookiepro_domain_script_id = System.getenv("cookiepro_domain_script_id"); %>

<jsp:scriptlet>
    session.setAttribute("authCode",request.getParameter("code"));
    session.setAttribute("sessionState", request.getParameter("session_state"));
    if(request.getParameter("state") != null) {session.setAttribute("state", request.getParameter("state"));}
</jsp:scriptlet>

<!DOCTYPE html>
<html>
    <head>
        <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
        <meta name="referrer" content="no-referrer" />

        <link href="/myaccount/libs/themes/wso2is/theme.89d6b53f.min.css" rel="stylesheet" type="text/css"/>
        <link rel="shortcut icon" href="/myaccount/libs/themes/wso2is/assets/images/branding/favicon.ico" data-react-helmet="true" />

        <% if ((Boolean.TRUE.toString()).equals(is_cookiepro_enabled)) { %>
             <!-- CookiePro Cookies Consent Notice start for asgardeo.io -->
            <script src="https://cookie-cdn.cookiepro.com/scripttemplates/otSDKStub.js"  type="text/javascript" charset="UTF-8" data-domain-script="<%= cookiepro_domain_script_id %>" ></script>
            <script type="text/javascript">
            function OptanonWrapper() {
                // Get initial OnetrustActiveGroups ids
                if(typeof OptanonWrapperCount == "undefined"){
                    otGetInitialGrps();
                }

                //Delete cookies
                otDeleteCookie(otInitialConsentedGroups);

                // Assign OnetrustActiveGroups to custom variable
                function otGetInitialGrps(){
                    OptanonWrapperCount = '';
                    otInitialConsentedGroups =  OnetrustActiveGroups;
                }

                function otDeleteCookie(iniOptGrpIdsListStr)
                {
                    var otDomainGrps = JSON.parse(JSON.stringify(Optanon.GetDomainData().Groups));
                    // publish custom event to announce the cookie consent change
                    const cookiePrefChangeEvent = new CustomEvent('cookie-pref-change', { pref: OnetrustActiveGroups });
                    window.dispatchEvent(cookiePrefChangeEvent)
                    // return consent revoked group id list
                    var otRevokedGrpIds = otGetInactiveId(iniOptGrpIdsListStr, OnetrustActiveGroups);
                    if(otRevokedGrpIds.length != 0 && otDomainGrps.length !=0){
                        for(var i = 0; i < otDomainGrps.length; i++){
                            //Check if CustomGroupId matches
                        if(otDomainGrps[i]['CustomGroupId'] != '' && otRevokedGrpIds.includes(otDomainGrps[i]['CustomGroupId'])){
                                for(var j = 0; j < otDomainGrps[i]['Cookies'].length; j++){
                                    console.info("Deleting cookie ",otDomainGrps[i]['Cookies'][j]['Name'])
                                    //Delete cookie
                                    eraseCookie(otDomainGrps[i]['Cookies'][j]['Name']);
                                }
                            }

                            //Check if Hostid matches
                            if(otDomainGrps[i]['Hosts'].length != 0){
                                for(var j=0; j < otDomainGrps[i]['Hosts'].length; j++){
                                    //Check if HostId presents in the deleted list and cookie array is not blank
                                    if(otRevokedGrpIds.includes(otDomainGrps[i]['Hosts'][j]['HostId']) && otDomainGrps[i]['Hosts'][j]['Cookies'].length !=0){
                                        for(var k = 0; k < otDomainGrps[i]['Hosts'][j]['Cookies'].length; k++){
                                            //Delete cookie
                                            eraseCookie(otDomainGrps[i]['Hosts'][j]['Cookies'][k]['Name']);
                                        }
                                    }
                                }
                            }

                        }
                    }
                    otGetInitialGrps(); //Reassign new group ids
                }

                //Get inactive ids
                function otGetInactiveId(prevGroupIdListStr, otActiveGrp){
                    prevGroupIdList = prevGroupIdListStr.split(",");
                    prevGroupIdList = prevGroupIdList.filter(Boolean);

                    //After action OnetrustActiveGroups
                    otActiveGrp = otActiveGrp.split(",");
                    otActiveGrp = otActiveGrp.filter(Boolean);

                    var result = [];
                    for (var i = 0; i < prevGroupIdList.length; i++){
                        if ( otActiveGrp.indexOf(prevGroupIdList[i]) <= -1 ){
                            result.push(prevGroupIdList[i]);
                        }
                    }
                    return result;
                }

                //Delete cookie
                function eraseCookie(name) {
                    //Delete root path cookies
                    domainName = window.location.hostname;
                    document.cookie = name + '=; Max-Age=-99999999; Path=/;Domain=' + domainName;
                    document.cookie = name + '=; Max-Age=-99999999; Path=/;';

                    //Delete LSO incase LSO being used, cna be commented out.
                    localStorage.removeItem(name);

                    //Check for the current path of the page
                    pathArray = window.location.pathname.split('/');
                    //Loop through path hierarchy and delete potential cookies at each path.
                    for (var i = 0; i < pathArray.length; i++){
                        if (pathArray[i]){
                            //Build the path string from the Path Array e.g /site/login
                            var currentPath = pathArray.slice(0,i+1).join('/');
                            document.cookie = name + '=; Max-Age=-99999999; Path=' + currentPath + ';Domain='+ domainName;
                            document.cookie = name + '=; Max-Age=-99999999; Path=' + currentPath + ';';
                            //Maybe path has a trailing slash!
                            document.cookie = name + '=; Max-Age=-99999999; Path=' + currentPath + '/;Domain='+ domainName;
                            document.cookie = name + '=; Max-Age=-99999999; Path=' + currentPath + '/;';

                        }
                    }
                }
            }
            </script>
        <% } %>

        <script>
            var contextPathGlobal = "/myaccount/";
            var serverOriginGlobal = "<%=getServerURL("", true, true)%>";
            var superTenantGlobal = "<%=SUPER_TENANT_DOMAIN_NAME%>";
            var tenantPrefixGlobal = "<%=TENANT_AWARE_URL_PREFIX%>";
        </script>

        <!-- Analytics -->
    
    
        <!-- Start VWO Async SmartCode -->
        <script type="<%= initialScriptType %>" class="optanon-category-C0002">
            var vwo_ac_id = ;
            if (vwo_ac_id !== null && vwo_ac_id) {
                window._vwo_code = window._vwo_code || (function(){
                var account_id = vwo_ac_id,
                settings_tolerance=2000,
                library_tolerance=2500,
                use_existing_jquery=false,
                is_spa=1,
                hide_element='body',

                /* DO NOT EDIT BELOW THIS LINE */
                f=false,d=document,code={use_existing_jquery:function(){return use_existing_jquery;},library_tolerance:function(){return library_tolerance;},finish:function(){if(!f){f=true;var a=d.getElementById('_vis_opt_path_hides');if(a)a.parentNode.removeChild(a);}},finished:function(){return f;},load:function(a){var b=d.createElement('script');b.src=a;b.type='text/javascript';b.innerText;b.onerror=function(){_vwo_code.finish();};d.getElementsByTagName('head')[0].appendChild(b);},init:function(){
                        window.settings_timer=setTimeout('_vwo_code.finish()',settings_tolerance);var a=d.createElement('style'),b=hide_element?hide_element+'{opacity:0 !important;filter:alpha(opacity=0) !important;background:none !important;}':'',h=d.getElementsByTagName('head')[0];a.setAttribute('id','_vis_opt_path_hides');a.setAttribute('type','text/css');if(a.styleSheet)a.styleSheet.cssText=b;else a.appendChild(d.createTextNode(b));h.appendChild(a);this.load('https://dev.visualwebsiteoptimizer.com/j.php?a='+account_id+'&u='+encodeURIComponent(d.URL)+'&f='+(+is_spa)+'&r='+Math.random());return settings_timer; }};window._vwo_settings_timer = code.init(); return code; }());
            } else {
                console.warn("VWO is disabled");
            }
        </script>
        <!-- End VWO Async SmartCode -->

        <!-- Start of custom stylesheets -->
        <link rel="stylesheet" type="text/css" href="/myaccount/extensions/stylesheet.css"/>
        <!-- End of custom stylesheets -->

        <!-- Start of custom scripts added to the head -->
        <script type="text/javascript" src="/myaccount/extensions/head-script.js"></script>
        <!-- End of custom scripts added to the head -->
    <script defer src="/myaccount/static/js/runtime.b92abbf3.js?7ee3ad9790c2af20"></script><script defer src="/myaccount/static/js/0.1a6cd493.js?7ee3ad9790c2af20"></script><script defer src="/myaccount/static/js/1.78c2a0c4.js?7ee3ad9790c2af20"></script><script defer src="/myaccount/static/js/vendor.87a679d4.js?7ee3ad9790c2af20"></script><script defer src="/myaccount/static/js/main.999f5ad5.js?7ee3ad9790c2af20"></script></head>
    <body>
        <noscript>
            You need to enable JavaScript to run this app.
        </noscript>
        <div id="root"></div>

        <!-- Start of custom scripts added to the body -->
        <script type="text/javascript" src="/myaccount/extensions/body-script.js"></script>
        <!-- End of custom scripts added to the body -->
    </body>
</html>
