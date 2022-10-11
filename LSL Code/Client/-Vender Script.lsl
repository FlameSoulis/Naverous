//Stores the Item's Primary Name
string PrimaryName;
//Stores the Item's Secondary Name
string SecondaryName;
//Stores the Item's Item Name
string ItemName;
//Stores the Item's Object Name
string ObjectName;
//Stores the Item's Price
integer Price;
//Stores the land's name
string sLandName;

default
{
    state_entry()
    {
        //State our starting point
        llSay(0,"Vendor Initializing...");
        //First grab our location
        list ParcelDetails = llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_NAME]);
        sLandName = llList2String(ParcelDetails,0);
        if(llStringTrim(sLandName,STRING_TRIM)=="") sLandName=llGetObjectName();
        llSay(0,"Land Name: "+sLandName);
        //Reset all nodes
        llMessageLinked(LINK_SET,51,"RESETALL","PACKET");
        //Wait for nodes to catch up
        llSleep(10.0);
        llSay(0,"Vendor Setting up...");
        //Send out the delcaration to the data node
        llMessageLinked(LINK_SET,52,"DATASTORAGE","INITIATE");
    }
    
    link_message(integer c, integer num, string msg, key k)
    {
        //Is it a datastorage manager packet
        if(num == 52)
        {
            //Are we done?
            if(k == "COMPLETE")
            {
                //YAY! So declare it!
                llSay(0,"Data download complete!");
                //We should wait awhile for the nodes to catch up and cool off
                llSay(0,"Waiting for data nodes to cool off...");
                llSleep(5.0);
                //Setup the vender for first use
                llMessageLinked(LINK_SET,53,"","1STSETUPBUTTONS");
                //Enter the Vender Mode
                state Vender;
            }
        }
    }
}

//The main vender mode!
state Vender
{
    on_rez(integer duh)
    {
        //RESET THE SCRIPT
        llResetScript();
    }
    state_entry()
    {
        //We have begun, so tell us
        llSay(0,"Vendor mode activated!");
    }
    
    link_message(integer c, integer num, string msg, key k)
    {
        //Is it an item info packet?
        if(num == 58)
        {
            //Does it say we need to set something?
            if(k == "CURRENTITEM")
            {
                //Decode the data
                list lDecode = llParseString2List(msg,["--"],[]);
                //Set the status to what we need
                PrimaryName = llList2String(lDecode,0);
                SecondaryName = llList2String(lDecode,1);
                ItemName = llList2String(lDecode,2);
                ObjectName = llList2String(lDecode,4);
                Price = llList2Integer(lDecode,3);
            }
            //Was something baught?
            else if(k == "DOPURCHASE")
            {
                //WOOT, BRING IT DOWN NOW
                list lDecode = llParseString2List(msg,["--"],[]);
                //Inform our purchaser kindly
                llSay(0,"Thank you for your purchase of the "+ItemName+", "+llList2String(lDecode,1)+"! We are informing the server about your purchase. Your item should be sent to you shortly!");
                //Send the message to our Purchaser
                llMessageLinked(LINK_SET,60,msg+"--"+PrimaryName+"--"+
                    SecondaryName+"--"+
                    ItemName+"--"+
                    ObjectName+"--"+
                    (string)Price+"--"+
                    llGetRegionName()+"--"+
                    sLandName,"DOPURCHASE");
            }
        }
    }
}