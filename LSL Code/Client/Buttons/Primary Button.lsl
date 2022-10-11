//The UUID of a button without anything loaded
key BlankKey = "bd7d7770-39c2-d4c8-e371-0342ecf20921";
//What sides will be used?
integer Sides = ALL_SIDES;
//The color that will be used when selected
vector vSelColor = <1,1,1>;
//The color that will be used when unselected
vector vUnSelColor = <0.5,0.5,0.5>;

//SYSTEM DATA - NO TOUCH

//Stores the Button's picture
key ButtonPic;
//Stores the Button's Primary Name
string PrimaryName;
//Stores whether we are in use or not
key InUse = NULL_KEY;

default
{
    state_entry()
    {
        //Check to see if we need to use customs
        if(llGetObjectDesc() != "")
        {
            //Decode the description
            list lDecode = llParseString2List(llGetObjectDesc(),["--"],[]);
            //Use the data to set our ACTUAL data
            BlankKey = llList2Key(lDecode,0);
            Sides = llList2Integer(lDecode,1);
        }
        //Set us at the default point
        llSetTexture(BlankKey,Sides);
        llSetColor(vUnSelColor,Sides);
    }
    touch_start(integer duh)
    {
        //Are we even valid?
        if(PrimaryName != "")
        {
            //Check to see if we are selected?
            if(InUse == NULL_KEY || InUse == llDetectedKey(0))
            {
                //First tell the InUse Node
                llMessageLinked(LINK_SET,56,(string)llDetectedKey(0),"NEWUSER");
                //Inform the system we need to update
                llMessageLinked(LINK_SET,53,PrimaryName+"--"+(string)ButtonPic,"UPDATESECONDARY");
                //Inform all other Primary's we've been changed
                llMessageLinked(LINK_SET,200,llGetObjectName(),"BUTTONSELECTED");
            }
            //Otherwise...COMPLAIN TO THE SYSTEM
            else
            {
                //TATTLE ON THEM
                llMessageLinked(LINK_SET,56,(string)llDetectedKey(0),"BADUSER");
            }
        }
    }
    link_message(integer link, integer num, string msg, key k)
    {
        //Is it the master reset packet?
        if(num == 51)
        {
            //Reset the script
            llResetScript();
        }
        //Is it a master packet?
        else if(num == 200)
        {
            //Do we need to clear?
            if(k == "CLEARALL")
            {
                //Resetting causes us to clear anyways
                llResetScript();
            }
            //Do we need to set a new user?
            else if(k == "NEWUSER")
            {
                //Record the new user
                InUse = (key)msg;
            }
            //Do we need to remove the user?
            else if(k == "NOUSER")
            {
                //Remove the user then
                InUse = NULL_KEY;
            }
            //Did someone click a button?
            else if(k == "BUTTONSELECTED")
            {
                //Check to see if it was us
                if(llGetObjectName() == msg)
                {
                    //Set the color
                    llSetColor(vSelColor,Sides);
                }
                else
                {
                    //Set the color
                    llSetColor(vUnSelColor,Sides);
                }
            }
        }
        //Is it OUR packet?
        else if(num == (200+(integer)llGetObjectName()))
        {
            //If the packet name is SETBUTTON
            if(k == "SETBUTTON")
            {
                //Create a list (decoding from the data)
                list lDecode = llParseString2List(msg,["--"],[]);
                //Set the status to what we need
                PrimaryName = llList2String(lDecode,0);
                ButtonPic   = llList2Key(lDecode,1);
                //Now set our texture
                llSetTexture(ButtonPic,Sides);
            }
        }
    }
}
