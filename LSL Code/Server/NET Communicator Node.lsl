//Notecard Setup Data Handler
key kSetupData;
//Address of the PHP Script
string sScriptAddress;
//Http Request Handler for Add Primary
key kHttpAddPrimary;
//Http Request Handler for Clear Primary
key kHttpClearPrimary;
//Http Request Handler for Add Secondary
key kHttpAddSecondary;
//Http Request Handler for Clear Primary
key kHttpClearSecondary;
//Http Request Handler for Add Items
key kHttpAddItems;
//Http Request Handler for Clear Items
key kHttpClearItems;
//Http Request Handler for Purchase Data
key kHttpPurchaseData;
//Http Request Handler for Manager Data
key kHttpManagerData;

default
{
    state_entry()
    {
        //Get our address
        if(llGetInventoryType("*Settings") == INVENTORY_NOTECARD)
            kSetupData = llGetNotecardLine("*Settings",0);
        else
            llSay(0,"No notecard named *Settings found!");
    }
    dataserver(key id, string data)
    {
        if(id ==  kSetupData)
        {
            sScriptAddress = data;
        }
    }
    link_message(integer c, integer num, string msg, key k)
    {
        //Is it a master Reset Packet?
        if(num == 51)
        {
            //Reset the script then
            llResetScript();
        }
        else if(num == 55)
        {
            //Do we need to add data to the primary table?
            if(k == "ADDPRIMARY")
            {
                //First break it into a list
                list lDecode = llParseString2List(msg,["--"],[]);
                kHttpAddPrimary=llHTTPRequest(sScriptAddress,
                    [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                    "cmd=ADDPRIMARY&primarycategory="+llList2String(lDecode,0)+"&primaryuuid="+llList2String(lDecode,1));
            }
            //Do we need to clear the primary table data
            else if(k == "CLEARPRIMARY")
            {
                kHttpClearPrimary=llHTTPRequest(sScriptAddress,
                    [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                    "cmd=CLEARPRIMARY");
            }
            //Do we need to add data to the secondary table?
            else if(k == "ADDSECONDARY")
            {
                //First break it into a list
                list lDecode = llParseString2List(msg,["--"],[]);
                kHttpAddSecondary=llHTTPRequest(sScriptAddress,
                    [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                    "cmd=ADDSECONDARY&primarycategory="+llList2String(lDecode,0)+"&secondarycategory="+llList2String(lDecode,1)+
                    "&secondaryuuid="+llList2String(lDecode,2));
            }
            //Do we need to clear the secondary table data
            else if(k == "CLEARSECONDARY")
            {
                kHttpClearSecondary=llHTTPRequest(sScriptAddress,
                    [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                    "cmd=CLEARSECONDARY");
            }
            //Do we need to add data to the secondary table?
            else if(k == "ADDITEMS")
            {
                //First break it into a list
                list lDecode = llParseString2List(msg,["--"],[]);
                kHttpAddItems=llHTTPRequest(sScriptAddress,
                    [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                    "cmd=ADDITEM&primarycategory="+llList2String(lDecode,0)+"&secondarycategory="+llList2String(lDecode,1)+
                    "&itemname="+llList2String(lDecode,2)+"&itemprice="+llList2String(lDecode,3)+
                    "&itemobject="+llList2String(lDecode,4)+"&itempicturemain="+llList2String(lDecode,5)+
                    "&itempicturesub="+llList2String(lDecode,6));
            }
            //Do we need to clear the secondary table data
            else if(k == "CLEARITEMS")
            {
                kHttpClearItems=llHTTPRequest(sScriptAddress,
                    [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                    "cmd=CLEARITEMS");
            }
            //Do we need to see if we have any new purchases?
            else if(k == "CHECKFORUPDATE")
            {
                kHttpPurchaseData=llHTTPRequest(sScriptAddress,
                    [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                    "cmd=UPDATEPURCHASE");
            }
        }
    }
    http_response(key reqID, integer status, list data, string body)
    {
        //If the message does NOT have any errors...
        if(status == 200)
        {
            //Is it an add primary response?
            if(reqID == kHttpAddPrimary)
            {
                //Did we have an error?
                if(body != "\n" && body != "")
                    llSay(0,"(AddPrimary):"+body);
            }
            //Is it a clear priamry response?
            else if(reqID == kHttpClearPrimary)
            {
                //Did we have an error?
                if(body != "\n" && body != "")
                    llSay(0,"(ClearPrimary):"+body);
            }
            //Is it an add secondary response?
            if(reqID == kHttpAddSecondary)
            {
                //Did we have an error?
                if(body != "\n" && body != "")
                    llSay(0,"(AddSecondary):"+body);
            }
            //Is it a clear secondary response?
            else if(reqID == kHttpClearSecondary)
            {
                //Did we have an error?
                if(body != "\n" && body != "")
                    llSay(0,"(ClearSecondary):"+body);
            }
            //Is it an add secondary response?
            if(reqID == kHttpAddItems)
            {
                //Did we have an error?
                if(body != "\n" && body != "")
                    llSay(0,"(AddItems):"+body);
            }
            //Is it a clear secondary response?
            else if(reqID == kHttpClearItems)
            {
                //Did we have an error?
                if(body != "\n" && body != "")
                    llSay(0,"(ClearItems):"+body);
            }
            else if(reqID == kHttpPurchaseData)
            {
                if(body != "")
                {
                    //Ok, break it into the format we can use
                    list lDecode = llParseString2List(body,["\n"],[]);
                    list lDecode2;
                    integer a;
                    for(a = 0;a<llGetListLength(lDecode);++a)
                    {
                        //Break it down agian
                        lDecode2=llParseString2List(llList2String(lDecode,a),["--"],[]);
                        //Send into the format we need (Some data is missing, but shouldn't be dangerous)
                        llMessageLinked(LINK_SET,54,llList2String(lDecode2,2)+"--"+llList2String(lDecode2,1)+"--"+
                        llList2String(lDecode2,8)+"--"+llList2String(lDecode2,9)+"--"+
                        llList2String(lDecode2,4)+"--"+llList2String(lDecode2,5)+"--"+llList2String(lDecode2,3)+"--"+
                        llList2String(lDecode2,6)+"--"+llList2String(lDecode2,7),"");
                        //Tell the server we got it managed
                        kHttpManagerData=llHTTPRequest(sScriptAddress,
                            [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                            "cmd=MANAGEPURCHASE&num="+llList2String(lDecode2,0));
                    }
                }
            }
        }
    }
}
