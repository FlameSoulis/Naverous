//The UUID of a button without anything loaded
key BlankKey = "bd7d7770-39c2-d4c8-e371-0342ecf20921";
//What sides will be used?
integer Sides = ALL_SIDES;

default
{
    state_entry()
    {
        //Check to see if we need to use another texture
        if(llGetObjectDesc() != "")
        {
            //Decode the description
            list lDecode = llParseString2List(llGetObjectDesc(),["--"],[]);
            //Use the data to set our ACTUAL data
            BlankKey = llList2Key(lDecode,0);
            Sides = llList2Integer(lDecode,1);
        }
        llSetTexture(BlankKey,Sides);
    }
    link_message(integer link, integer num, string msg, key k)
    {
        //Is it the master reset packet?
        if(num == 51)
        {
            //Reset the script
            llResetScript();
        }
        //Is it a previewer packet?
        else if(num == 59)
        {
            if(k == "SETPREVIEW")
            {
                //Do what the master says
                llSetTexture((key)msg,Sides);
            }
        }
    }
}
