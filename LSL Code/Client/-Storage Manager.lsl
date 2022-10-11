default
{
    link_message(integer link, integer num, string msg, key k)
    {
        //Did we get a master reset?
        if(num == 51)
        {
            //Reset the script then
            llResetScript();
        }
        //Is it a database deal?
        else if(num == 52)
        {
            //Do we need to begin?
            if(k == "INITIATE")
            {
                //Start by requesting the primary data
                llMessageLinked(LINK_SET,55,"","REQUESTDATA");
            }
            //Did we get data about Primary Data?
            else if(k == "GOTPRIMARYDATA")
            {
                //WOOT! Break it down and store it
                
                //Make a temporary integer
                integer iTempInteger;
                //Now parse the string into a list
                list lDecode = llParseString2List(msg,["\n"],[]);
                //Go through the list to create out data for the nodes
                for(iTempInteger=0;iTempInteger < llGetListLength(lDecode);++iTempInteger)
                {
                    llMessageLinked(LINK_SET,53,llList2String(lDecode,iTempInteger),"ADDPRIMARY");
                }
            }
            //Did we get data about Secondary Data?
            else if(k == "GOTSECONDARYDATA")
            {
                //WOOT! Break it down and store it
                
                //Make a temporary integer
                integer iTempInteger;
                //Now parse the string into a list
                list lDecode = llParseString2List(msg,["\n"],[]);
                //Go through the list to create out data for the nodes
                for(iTempInteger=0;iTempInteger < llGetListLength(lDecode);++iTempInteger)
                {
                    llMessageLinked(LINK_SET,53,llList2String(lDecode,iTempInteger),"ADDSECONDARY");
                }
            }
            //Did we get Item Data?
            else if(k == "GOTITEMSDATA")
            {
                //WOOT! Break it down and store it
                
                //Make a temporary integer
                integer iTempInteger;
                //Now parse the string into a list
                list lDecode = llParseString2List(msg,["\n"],[]);
                //Go through the list to create out data for the nodes
                for(iTempInteger=0;iTempInteger < llGetListLength(lDecode);++iTempInteger)
                {
                    llMessageLinked(LINK_SET,53,llList2String(lDecode,iTempInteger),"ADDITEMS");
                }
            }
            //Are we done?
            else if(k == "DATACOMPLETE")
            {
                //FINALLY, about time!
                llMessageLinked(LINK_SET,52,"DATASTORAGE","COMPLETE");
            }
        }
    }
}
