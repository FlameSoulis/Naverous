//Notecard Setup Data Handler
key kSetupData;
//Address of the PHP Script
string sScriptAddress;
//Holder for the items
integer holder;
//Keys for the http requests
key kHttpRequestPrimary;
key kHttpRequestSecondary;
key kHttpRequestItem;
key kHttpRequestPurchase;
//v1.1 - 11 fucking years later
float fSleepTimer = 1.0;

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
            //Is it a request to get our intel?
            if(k == "REQUESTDATA")
            {
                //QUICK! TO THE BLU BASE!!!
                kHttpRequestPrimary=llHTTPRequest(sScriptAddress,
                    [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                    "cmd=VIEWPRIMARY");
            }
            //Is it a purchase?
            else if(k == "DOPURCHASE")
            {
                //Break it down
                list lDecode = llParseString2List(msg,["--"],[]);
                //Send the message
                kHttpRequestPurchase=llHTTPRequest(sScriptAddress,
                    [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                    "cmd=ADDPURCHASE&name="+llList2String(lDecode,1)+"&uuid="+llList2String(lDecode,0)+
                    "&ammount="+llList2String(lDecode,6)+"&item="+llList2String(lDecode,4)+
                    "&object="+llList2String(lDecode,5)+"&sim="+llList2String(lDecode,7)+
                    "&land="+llList2String(lDecode,8));
            }
        }
    }
    http_response(key reqID, integer status, list data, string body)
    {
        integer iShouldSleep = TRUE;
        //If the message does NOT have any errors...
        if(status == 200)
        {
            //Is it a response involving Primary Data?
            if(reqID == kHttpRequestPrimary)
            {
                //Let the Storage Manager handle it...
                llMessageLinked(LINK_SET,52,body,"GOTPRIMARYDATA");
                //Start requesting Secondary Data
                kHttpRequestSecondary=llHTTPRequest(sScriptAddress,
                        [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                        "cmd=VIEWSECONDARY&point=0");
            }
            //Is it a response involving Secondary Data?
            else if(reqID == kHttpRequestSecondary)
            {
                //TOKI-FIX: Fixes Secondary Overload
                //Are we done requesting?
                if(body != "COMPLETE!")
                {
                    //Let the Storage Manager handle it...
                    llMessageLinked(LINK_SET,52,body,"GOTSECONDARYDATA");
                    //Begin loading the NEXT part
                    list lTemp = llParseString2List(body,["\n"],[]);
                    holder+=llGetListLength(lTemp);
                    kHttpRequestSecondary=llHTTPRequest(sScriptAddress,
                        [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                        "cmd=VIEWSECONDARY&point="+(string)holder);
                } else {
                    //Reset the holder
                    holder=0;
                    //Start requesting Item Data
                    kHttpRequestItem=llHTTPRequest(sScriptAddress,
                            [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                            "cmd=VIEWITEMS&point="+(string)holder);
                }
            }
            //Is it a response involving Secondary Data?
            else if(reqID == kHttpRequestItem)
            {
                //Are we done requesting?
                if(body != "COMPLETE!")
                {
                    //Give the server a break
                    llSleep(1.0);
                    //Let the Storage Manager handle it...
                    llMessageLinked(LINK_SET,52,body,"GOTITEMSDATA");
                    list lTemp = llParseString2List(body,["\n"],[]);
                    holder+=llGetListLength(lTemp);
                    //Since there's ALOT of items, we need to do another request until it says we're done
                    kHttpRequestItem=llHTTPRequest(sScriptAddress,
                        [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                        "cmd=VIEWITEMS&point="+(string)holder);
                }
                else
                {
                    //Then we are DONE!
                    llMessageLinked(LINK_SET,52,"","DATACOMPLETE");
                }
            }
            //Is it a responce involving a purchase?
            else if(reqID == kHttpRequestPurchase)
            {
                if(body != "")
                {
                    llSay(0,"There was an error with your purchase! Please contact the "+llKey2Name(llGetOwner())+" for help.");
                    llSay(0,"ERROR: "+body);
                }
            }
            else
            {
                iShouldSleep = FALSE;
            }
        }
        else
        {
            //Make sure there was NOTHING wrong with the purchase
            if(reqID == kHttpRequestPurchase)
            {
                llSay(0,"There was an error with your purchase! Please contact the "+llKey2Name(llGetOwner())+" for help.");
            }
            else
            {
                iShouldSleep = FALSE;
            }
        }
        
        if(iShouldSleep) llSleep(fSleepTimer);
    }
}
