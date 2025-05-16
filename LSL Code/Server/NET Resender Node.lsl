//Notecard Setup Data Handler
key kSetupData;
//Address of the PHP Script
string sScriptAddress;
//Http Request Handler for ReSender
key kHttpResender;

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
        //Is it the server's CHECKFORUPDATE packet?
        if(k == "CHECKFORUPDATE" && num == 55)
        {
            kHttpResender=llHTTPRequest(sScriptAddress,
                [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                "cmd=CHECKFORRESEND");
        }
    }
    http_response(key reqID, integer status, list data, string body)
    {
        //If the message does NOT have any errors...
        if(status == 200 && reqID==kHttpResender)
        {
            //If there is no data, just exit
            if(body == "" || body == "\n")
                return;
            //Otherwise, lets decode
            list lDecode=llParseString2List(body,["\n"],[]);
            //Make a temporary list
            list lTemp;
            //Begin the loop
            integer a;
            for(a=0;a<llGetListLength(lDecode);++a)
            {
                //Decode part of the decode =P
                lTemp = llParseString2List(llList2String(lDecode,a),["--"],[]);
                //Format - PurchaseNumber,CustomerName,CustomerUUID,ItemName,Object,SimName,LandName,PurchaseDate
                //Send an IM to the person
                llInstantMessage(llList2Key(lTemp,2),"(#"+llList2String(lTemp,0)+")You purchased the "+
                    llList2String(lTemp,3)+" on "+llList2String(lTemp,7)+" in "+llList2String(lTemp,6)+", "+
                    llList2String(lTemp,5)+".");
                //Resend them the item just to be safe
                llGiveInventory(llList2Key(lTemp,2),llList2String(lTemp,4));
                //Tell the server we got it managed
                llHTTPRequest(sScriptAddress,
                    [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
                    "cmd=MANAGEPURCHASE&num="+llList2String(lTemp,0));
            }
        }
    }
}
